import SwiftUI

struct PaywallView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 14) {
                    Text("⚔️")
                        .font(.system(size: 60))

                    Text("Unlock Brawlbit")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Text("Full access to all battles,\nyour 90-day journey, and more.")
                        .font(.callout)
                        .foregroundColor(Color(white: 0.45))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 32)

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        appState.hasCompletedOnboarding = true
                    } label: {
                        HStack(spacing: 8) {
                            Text("Start free trial")
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

                    Button {
                        appState.hasCompletedOnboarding = true
                    } label: {
                        Text("Maybe later")
                            .font(.system(size: 14))
                            .foregroundColor(Color(white: 0.35))
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 52)
            }
        }
    }
}
