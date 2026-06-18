import Foundation
import WebKit

struct TavernEndpoint: Identifiable, Hashable {
    let id: Int
    let title: String
    let subtitle: String
    let icon: String

    var url: URL {
        URL(string: "https://aaa.sillytavern.top:\(id)")!
    }

    static let all: [TavernEndpoint] = [
        .init(id: 8000, title: "阿里云 1 号云洞", subtitle: "8000 入口", icon: "airplane"),
        .init(id: 8443, title: "阿里云 2 号云洞", subtitle: "8443 入口", icon: "cloud.fill"),
        .init(id: 8888, title: "西西画家云洞", subtitle: "8888 入口", icon: "paintpalette.fill")
    ]
}

@MainActor
final class AppState: ObservableObject {
    @Published var activeEndpoint: TavernEndpoint?
    @Published var showSwitcher = false
    @Published var reloadToken = UUID()
    @Published var resetToken = UUID()

    private let lastPortKey = "lastEndpointPort"

    var lastPort: Int {
        UserDefaults.standard.integer(forKey: lastPortKey)
    }

    func open(_ endpoint: TavernEndpoint) {
        UserDefaults.standard.set(endpoint.id, forKey: lastPortKey)
        activeEndpoint = endpoint
        showSwitcher = false
    }

    func resetWebData() {
        let store = WKWebsiteDataStore.default()
        store.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            store.removeData(
                ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                for: records
            ) {
                Task { @MainActor in
                    self.resetToken = UUID()
                    self.reloadToken = UUID()
                }
            }
        }
    }
}
