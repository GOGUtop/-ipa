import SwiftUI

struct PortalView: View {
    @EnvironmentObject private var appState: AppState
    @State private var glow = false
    @State private var resetting = false

    var body: some View {
        ZStack {
            PortalBackground(glow: glow)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    header
                        .padding(.top, 46)
                        .padding(.bottom, 16)

                    ForEach(TavernEndpoint.all) { endpoint in
                        PortalCard(
                            endpoint: endpoint,
                            isLastUsed: appState.lastPort == endpoint.id
                        ) {
                            appState.open(endpoint)
                        }
                    }

                    resetButton
                        .padding(.top, 2)

                    Label("进入后点右下角水滴，可随时切换云洞", systemImage: "lightbulb.fill")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(.white.opacity(0.72))
                        .padding(.vertical, 20)
                }
                .padding(.horizontal, 22)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear { glow = true }
    }

    private var header: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.08))
                    .frame(width: 96, height: 96)
                    .blur(radius: 1)
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 50, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 1, green: 0.92, blue: 0.68), .white],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            Text("云洞酒馆")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 1, green: 0.95, blue: 0.78))

            Text("选一个云洞钻进去玩～")
                .font(.title3.weight(.medium))
                .foregroundStyle(.white.opacity(0.82))
        }
    }

    private var resetButton: some View {
        Button {
            resetting = true
            appState.resetWebData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                resetting = false
            }
        } label: {
            HStack(spacing: 16) {
                Image(systemName: resetting ? "hourglass" : "trash.slash.fill")
                    .font(.title2)
                    .frame(width: 38)
                VStack(alignment: .leading, spacing: 4) {
                    Text(resetting ? "正在清理…" : "重置酒馆")
                        .font(.headline)
                    Text("清空缓存、Cookie 和网页数据")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .padding(20)
            .background(
                LinearGradient(
                    colors: [Color.red.opacity(0.32), Color.orange.opacity(0.3)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 25, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .stroke(.white.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(PressableButtonStyle())
        .disabled(resetting)
    }
}

private struct PortalCard: View {
    let endpoint: TavernEndpoint
    let isLastUsed: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: endpoint.icon)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(iconColor)
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 5) {
                    Text(endpoint.title)
                        .font(.title3.weight(.semibold))
                    Text(endpoint.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.72))
                    if isLastUsed {
                        Label("上次使用", systemImage: "sparkles")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color(red: 1, green: 0.94, blue: 0.65))
                    }
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .font(.title3.bold())
            }
            .foregroundStyle(.white)
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 108)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 27, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 27, style: .continuous)
                    .stroke(
                        isLastUsed ? Color(red: 1, green: 0.94, blue: 0.68) : .white.opacity(0.28),
                        lineWidth: isLastUsed ? 2 : 1
                    )
            }
        }
        .buttonStyle(PressableButtonStyle())
    }

    private var iconColor: Color {
        switch endpoint.id {
        case 8000: return .cyan
        case 8443: return Color(red: 0.72, green: 0.84, blue: 1)
        default: return Color(red: 1, green: 0.72, blue: 0.42)
        }
    }
}

private struct PortalBackground: View {
    let glow: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.025, green: 0.07, blue: 0.13),
                    Color(red: 0.05, green: 0.14, blue: 0.24),
                    Color(red: 0.015, green: 0.035, blue: 0.07)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            Circle()
                .fill(Color.blue.opacity(0.34))
                .frame(width: 380, height: 380)
                .blur(radius: 90)
                .offset(x: glow ? 145 : 90, y: -290)

            Circle()
                .fill(Color.orange.opacity(0.2))
                .frame(width: 310, height: 310)
                .blur(radius: 105)
                .offset(x: glow ? -150 : -100, y: 300)

            Canvas { context, size in
                for index in 0..<42 {
                    let x = CGFloat((index * 83) % 101) / 101 * size.width
                    let y = CGFloat((index * 47) % 97) / 97 * size.height
                    let radius = CGFloat(index % 3 + 1)
                    context.fill(
                        Path(ellipseIn: CGRect(x: x, y: y, width: radius, height: radius)),
                        with: .color(.white.opacity(index % 5 == 0 ? 0.4 : 0.16))
                    )
                }
            }
        }
        .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: glow)
        .ignoresSafeArea()
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.975 : 1)
            .opacity(configuration.isPressed ? 0.88 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.72), value: configuration.isPressed)
    }
}
