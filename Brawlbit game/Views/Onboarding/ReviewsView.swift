import SwiftUI

struct ReviewsView: View {
    let onContinue: () -> Void

    @State private var card1Visible = false
    @State private var card2Visible = false

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            GlowBlobBackground()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer().frame(height: 24)

                        Text("⚔️ Warriors who\nalready made it")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text("Real discipline, real results.")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(Color(white: 0.4))

                        ReviewCard(
                            name: "Alejandro M.",
                            avatar: "🧑‍💻",
                            avatarColor: Color(red: 0.15, green: 0.08, blue: 0.35),
                            quote: "I'd been trying to be more consistent for years. With Brawlbit I turned it into a game — 73 days without missing a single one."
                        )
                        .offset(x: card1Visible ? 0 : -40)
                        .opacity(card1Visible ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: card1Visible)

                        ReviewCard(
                            name: "Sara R.",
                            avatar: "👩‍🎤",
                            avatarColor: Color(red: 0.35, green: 0.08, blue: 0.08),
                            quote: "Watching the monster approach as time runs out gives me a push no other app has given me. Brutal!"
                        )
                        .offset(x: card2Visible ? 0 : 40)
                        .opacity(card2Visible ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.15), value: card2Visible)

                        Spacer().frame(height: 8)
                    }
                    .padding(.horizontal, 24)
                }

                OnboardingCTAButton(title: "Continue", action: onContinue)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
            }
        }
        .onAppear {
            card1Visible = true
            card2Visible = true
        }
    }
}

private struct ReviewCard: View {
    let name: String
    let avatar: String
    let avatarColor: Color
    let quote: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(avatarColor)
                        .frame(width: 44, height: 44)
                    Text(avatar)
                        .font(.system(size: 22))
                }
                Text(name)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }

            Text(quote)
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(Color(white: 0.55))
                .lineSpacing(3)
        }
        .padding(18)
        .background(Color(white: 0.12))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(16)
    }
}
