import SwiftUI

struct BeforeAfterView: View {
    let question: String
    let leftEmojis: String
    let leftLabel: String
    let rightEmojis: String
    let rightLabel: String
    let onContinue: () -> Void

    @State private var cardVisible = false

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            GlowBlobBackground()

            VStack(spacing: 0) {
                Spacer()

                // Pregunta
                Text(question)
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)

                Spacer().frame(height: 40)

                // Split card
                HStack(spacing: 0) {
                    // Lado gris — sin Brawlbit
                    ZStack {
                        Color(white: 0.12)
                        VStack(spacing: 12) {
                            Text(leftEmojis)
                                .font(.system(size: 44))
                                .grayscale(1.0)
                            Text(leftLabel)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(Color(white: 0.4))
                                .multilineTextAlignment(.center)
                        }
                        .padding(20)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .grayscale(1.0)

                    // Divisor
                    Rectangle()
                        .fill(Color(white: 0.2))
                        .frame(width: 1)

                    // Lado color — con Brawlbit
                    ZStack {
                        Color(red: 0.12, green: 0.07, blue: 0.04)
                        VStack(spacing: 12) {
                            Text(rightEmojis)
                                .font(.system(size: 44))
                            Text(rightLabel)
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.orange)
                                .multilineTextAlignment(.center)
                        }
                        .padding(20)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(white: 0.15), lineWidth: 1)
                )
                .padding(.horizontal, 24)
                .scaleEffect(cardVisible ? 1.0 : 0.92)
                .opacity(cardVisible ? 1.0 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.1), value: cardVisible)

                Spacer()

                OnboardingCTAButton(title: "Yes! 💪", icon: nil, action: onContinue)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 52)
            }
        }
        .onAppear { cardVisible = true }
    }
}
