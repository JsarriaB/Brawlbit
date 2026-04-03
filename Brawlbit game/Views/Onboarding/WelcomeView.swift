import SwiftUI
import Combine

struct WelcomeView: View {
    let onContinue: () -> Void

    @State private var heroFrame = 0
    @State private var floatOffset: CGFloat = 0
    @State private var titleVisible = false
    @State private var subtitleVisible = false
    @State private var buttonVisible = false

    private let animTimer = Timer.publish(every: 0.12, on: .main, in: .common).autoconnect()
    private let heroClass: HeroClass = .knight

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            GlowBlobBackground()

            VStack(spacing: 0) {
                Spacer()

                // Hero sprite flotando
                Image(heroClass.idleFrames[heroFrame])
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .offset(y: floatOffset)
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: floatOffset)

                Spacer().frame(height: 32)

                // Título
                VStack(spacing: 10) {
                    Text("⚔️ BRAWLBIT ⚔️")
                        .font(.system(size: 32, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .tracking(4)
                        .shadow(color: Color.orange.opacity(0.6), radius: 12, x: 0, y: 0)

                    Text("Every day is a battle.")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Text("Are you ready to win it?")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(white: 0.6))
                }
                .opacity(titleVisible ? 1 : 0)
                .offset(y: titleVisible ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.3), value: titleVisible)

                Spacer().frame(height: 16)

                // Tags de contexto
                HStack(spacing: 10) {
                    TagChip(text: "🎮 Gamified", color: .orange)
                    TagChip(text: "🏆 90 days", color: Color(red: 0.85, green: 0.14, blue: 0.14))
                    TagChip(text: "⚡ Free", color: Color(red: 0.45, green: 0.1, blue: 0.75))
                }
                .opacity(subtitleVisible ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.6), value: subtitleVisible)

                Spacer()

                // CTA
                VStack(spacing: 10) {
                    OnboardingCTAButton(title: "Start my adventure", icon: "sword.fill") {
                        onContinue()
                    }

                    Text("No account · No card")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(Color(white: 0.3))
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 52)
                .opacity(buttonVisible ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.9), value: buttonVisible)
            }
        }
        .onAppear {
            floatOffset = -8
            titleVisible = true
            subtitleVisible = true
            buttonVisible = true
        }
        .onReceive(animTimer) { _ in
            heroFrame = (heroFrame + 1) % heroClass.idleFrames.count
        }
    }
}

private struct TagChip: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.25))
            .overlay(
                Capsule().stroke(color.opacity(0.5), lineWidth: 1)
            )
            .clipShape(Capsule())
    }
}
