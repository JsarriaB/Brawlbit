import SwiftUI
import UserNotifications

struct PromiseView: View {
    let onContinue: () -> Void

    @State private var showingNotifications = false
    @State private var itemsVisible: [Bool] = [false, false, false, false]

    private let vows = [
        ("⚔️", "I will defeat every monster before the deadline"),
        ("🏔️", "I will climb the 90-day mountain"),
        ("🔥", "I will keep my winning streak"),
        ("🏆", "I will fight every day without excuses"),
    ]

    var body: some View {
        if showingNotifications {
            NotificationsPromptView(onContinue: onContinue)
        } else {
            promiseBody
        }
    }

    private var promiseBody: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            GlowBlobBackground()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 28) {
                    // Título
                    VStack(spacing: 8) {
                        Text("⚔️")
                            .font(.system(size: 48))
                        Text("Warrior's Oath")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Text("Before you begin your adventure,\ntake this oath.")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(Color(white: 0.45))
                            .multilineTextAlignment(.center)
                    }

                    // Votos
                    VStack(spacing: 12) {
                        ForEach(vows.indices, id: \.self) { i in
                            HStack(spacing: 14) {
                                Text(vows[i].0)
                                    .font(.system(size: 22))
                                    .frame(width: 32)
                                Text(vows[i].1)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 18))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(Color(white: 0.11))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.orange.opacity(0.25), lineWidth: 1)
                            )
                            .cornerRadius(14)
                            .opacity(itemsVisible[i] ? 1 : 0)
                            .offset(y: itemsVisible[i] ? 0 : 16)
                            .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(i) * 0.2), value: itemsVisible[i])
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()

                OnboardingCTAButton(title: "I swear it! 💪", icon: nil) {
                    withAnimation { showingNotifications = true }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 52)
            }
        }
        .onAppear {
            for i in vows.indices {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.25 + 0.3) {
                    itemsVisible[i] = true
                }
            }
        }
    }
}

// MARK: - Notifications prompt

private struct NotificationsPromptView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            GlowBlobBackground()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 24) {
                    Text("🔔")
                        .font(.system(size: 52))

                    VStack(spacing: 8) {
                        Text("Don't miss a single battle")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text("Enable reminders and we'll warn you\nbefore the monster defeats you.")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(Color(white: 0.45))
                            .multilineTextAlignment(.center)
                    }

                    // Mockup de notificación
                    HStack(spacing: 12) {
                        Image(systemName: "app.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("⚔️ Medusa · 5 minutes remaining")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("FINAL WARNING — attack now! ⚠️")
                                .font(.system(size: 11, design: .rounded))
                                .foregroundColor(Color(white: 0.5))
                        }
                        Spacer()
                        Text("Now")
                            .font(.system(size: 10))
                            .foregroundColor(Color(white: 0.4))
                    }
                    .padding(14)
                    .background(Color(white: 0.14))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                }

                Spacer()

                VStack(spacing: 12) {
                    OnboardingCTAButton(title: "Enable reminders 🔔", icon: nil) {
                        UNUserNotificationCenter.current()
                            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
                                DispatchQueue.main.async { onContinue() }
                            }
                    }

                    Button("Not now") {
                        onContinue()
                    }
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(Color(white: 0.35))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 52)
            }
        }
    }
}
