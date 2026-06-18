import SwiftUI

struct SwitcherSheet: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("选择云洞") {
                    ForEach(TavernEndpoint.all) { endpoint in
                        Button {
                            appState.open(endpoint)
                            dismiss()
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: endpoint.icon)
                                    .frame(width: 30)
                                    .foregroundStyle(.yellow)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(endpoint.title)
                                        .foregroundStyle(.primary)
                                    Text(endpoint.url.absoluteString)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if appState.activeEndpoint == endpoint {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        appState.resetWebData()
                        dismiss()
                    } label: {
                        Label("清空缓存并重新加载", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("切换云洞")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
