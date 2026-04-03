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

                        Text("⚔️ Guerreros que\nya lo lograron")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text("★★★★★")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.1))

                        ReviewCard(
                            name: "Alejandro M.",
                            avatar: "🧑‍💻",
                            avatarColor: Color(red: 0.15, green: 0.08, blue: 0.35),
                            title: "Cambió mi rutina por completo",
                            reviewBody: "Llevaba años intentando ser más constante. Con Brawlbit lo convertí en un juego. Llevo 73 días sin fallar ni uno.",
                            days: "73 días"
                        )
                        .offset(x: card1Visible ? 0 : -40)
                        .opacity(card1Visible ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: card1Visible)

                        ReviewCard(
                            name: "Sara R.",
                            avatar: "👩‍🎤",
                            avatarColor: Color(red: 0.35, green: 0.08, blue: 0.08),
                            title: "La gamificación es adictiva",
                            reviewBody: "Ver cómo el monstruo se acerca cuando se acaba el tiempo me da un empuje que ninguna otra app me había dado. ¡Brutal!",
                            days: "51 días"
                        )
                        .offset(x: card2Visible ? 0 : 40)
                        .opacity(card2Visible ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.15), value: card2Visible)

                        Spacer().frame(height: 8)
                    }
                    .padding(.horizontal, 24)
                }

                OnboardingCTAButton(title: "Continuar", action: onContinue)
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
    let title: String
    let reviewBody: String
    let days: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(avatarColor)
                        .frame(width: 44, height: 44)
                    Text(avatar)
                        .font(.system(size: 22))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("★★★★★  · \(days) de racha")
                        .font(.system(size: 11))
                        .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.1))
                }
                Spacer()
                Text("✓")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.green)
            }

            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(reviewBody)
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
