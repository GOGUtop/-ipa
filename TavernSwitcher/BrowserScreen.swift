import SwiftUI
import WebKit

struct BrowserScreen: View {
    @EnvironmentObject private var appState: AppState
    let endpoint: TavernEndpoint

    @StateObject private var browser = BrowserModel()
    @State private var showControls = true

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            WebView(
                url: endpoint.url,
                browser: browser,
                reloadToken: appState.reloadToken
            )
            .ignoresSafeArea(edges: .bottom)

            if browser.isLoading {
                ProgressView(value: browser.progress)
                    .progressViewStyle(.linear)
                    .tint(Color(red: 1, green: 0.83, blue: 0.35))
                    .frame(maxHeight: .infinity, alignment: .top)
            }

            if let error = browser.errorMessage {
                errorCard(error)
            }

            controls
                .padding(.trailing, 16)
                .padding(.bottom, 18)
        }
        .background(Color(red: 0.025, green: 0.04, blue: 0.07))
    }

    private var controls: some View {
        VStack(alignment: .trailing, spacing: 10) {
            if showControls {
                HStack(spacing: 5) {
                    controlButton("chevron.backward", disabled: !browser.canGoBack) {
                        browser.webView?.goBack()
                    }
                    controlButton("arrow.clockwise") {
                        browser.webView?.reload()
                    }
                    controlButton("house.fill") {
                        appState.activeEndpoint = nil
                    }
                }
                .padding(6)
                .background(.ultraThinMaterial, in: Capsule())
                .transition(.scale.combined(with: .opacity))

                Button {
                    appState.showSwitcher = true
                } label: {
                    Label("切换云洞", systemImage: "arrow.triangle.2.circlepath")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .frame(height: 44)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(Capsule().stroke(.white.opacity(0.25)))
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.72)) {
                    showControls.toggle()
                }
            } label: {
                Image(systemName: showControls ? "drop.fill" : "drop")
                    .font(.title2.bold())
                    .foregroundStyle(Color(red: 1, green: 0.92, blue: 0.62))
                    .frame(width: 54, height: 54)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.05, green: 0.18, blue: 0.34), Color.black.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: Circle()
                    )
                    .overlay(Circle().stroke(.white.opacity(0.28)))
                    .shadow(color: .black.opacity(0.35), radius: 10, y: 5)
            }
        }
    }

    private func controlButton(
        _ icon: String,
        disabled: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .frame(width: 38, height: 38)
        }
        .foregroundStyle(disabled ? .white.opacity(0.3) : .white)
        .disabled(disabled)
    }

    private func errorCard(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.exclamationmark")
                .font(.largeTitle)
            Text("云洞连接失败")
                .font(.headline)
            Text(message)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("重新加载") {
                browser.errorMessage = nil
                browser.webView?.reload()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
        .frame(maxWidth: 300)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@MainActor
final class BrowserModel: ObservableObject {
    @Published var isLoading = false
    @Published var progress = 0.0
    @Published var canGoBack = false
    @Published var errorMessage: String?
    weak var webView: WKWebView?
}

struct WebView: UIViewRepresentable {
    let url: URL
    @ObservedObject var browser: BrowserModel
    let reloadToken: UUID

    func makeCoordinator() -> Coordinator {
        Coordinator(browser: browser)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        configuration.preferences.isElementFullscreenEnabled = true
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1 TavernSwitcher/1.0"
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }

        context.coordinator.observe(webView)
        browser.webView = webView
        webView.load(URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if context.coordinator.lastReloadToken != reloadToken {
            context.coordinator.lastReloadToken = reloadToken
            webView.reload()
        }
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        let browser: BrowserModel
        var observations: [NSKeyValueObservation] = []
        var lastReloadToken: UUID?

        init(browser: BrowserModel) {
            self.browser = browser
        }

        func observe(_ webView: WKWebView) {
            observations = [
                webView.observe(\.estimatedProgress, options: [.new]) { [weak self] view, _ in
                    Task { @MainActor in self?.browser.progress = view.estimatedProgress }
                },
                webView.observe(\.canGoBack, options: [.new]) { [weak self] view, _ in
                    Task { @MainActor in self?.browser.canGoBack = view.canGoBack }
                }
            ]
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            Task { @MainActor in
                browser.isLoading = true
                browser.errorMessage = nil
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            Task { @MainActor in
                browser.isLoading = false
                browser.canGoBack = webView.canGoBack
            }
        }

        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            show(error)
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            show(error)
        }

        private func show(_ error: Error) {
            let nsError = error as NSError
            guard nsError.code != NSURLErrorCancelled else { return }
            Task { @MainActor in
                browser.isLoading = false
                browser.errorMessage = nsError.localizedDescription
            }
        }

        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            if navigationAction.targetFrame == nil, let requestURL = navigationAction.request.url {
                webView.load(URLRequest(url: requestURL))
            }
            return nil
        }

        func webView(
            _ webView: WKWebView,
            runJavaScriptAlertPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping () -> Void
        ) {
            guard let controller = webView.window?.rootViewController else {
                completionHandler()
                return
            }
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好", style: .default) { _ in completionHandler() })
            controller.present(alert, animated: true)
        }

        func webView(
            _ webView: WKWebView,
            runJavaScriptConfirmPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping (Bool) -> Void
        ) {
            guard let controller = webView.window?.rootViewController else {
                completionHandler(false)
                return
            }
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel) { _ in completionHandler(false) })
            alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in completionHandler(true) })
            controller.present(alert, animated: true)
        }
    }
}
