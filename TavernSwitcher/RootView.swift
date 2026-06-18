import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            if let endpoint = appState.activeEndpoint {
                BrowserScreen(endpoint: endpoint)
                    .id("\(endpoint.id)-\(appState.resetToken)")
                    .transition(.opacity)
            } else {
                PortalView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.24), value: appState.activeEndpoint)
        .sheet(isPresented: $appState.showSwitcher) {
            SwitcherSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}
