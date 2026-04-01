import SwiftUI

struct WelcomeView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 16) {
                    Text("⚔️")
                        .font(.system(size: 64))

                    Text("BRAWLBIT")
                        .font(.system(size: 34, weight: .black))
                        .foregroundColor(.white)
                        .tracking(8)

                    Text("Every day is a battle.\nWin yours.")
                        .font(.callout)
                        .foregroundColor(Color(white: 0.45))
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                }

                Spacer()

                VStack(spacing: 10) {
                    Button(action: onContinue) {
                        HStack(spacing: 8) {
                            Text("Begin your journey")
                                .font(.system(size: 16, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }

                    Text("Free to start · No account needed")
                        .font(.caption)
                        .foregroundColor(Color(white: 0.3))
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 52)
            }
        }
    }
}
