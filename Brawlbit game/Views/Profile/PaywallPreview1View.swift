import SwiftUI
import SwiftData

// ── PAYWALL 1: Main onboarding paywall ────────────────────────────────────────
// TEMP: reference for Superwall design. Remove before launch.

struct PaywallPreview1View: View {
    @Query private var heroes: [Hero]
    var hero: Hero? { heroes.first }

    @State private var selectedPlan: Plan = .yearly
    @State private var heroFrame: Int = 0
    @State private var heroWaitTimer: Timer?
    @State private var heroAnimTimer: Timer?

    enum Plan { case yearly, monthly, weekly }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.05, blue: 0.10),
                         Color(red: 0.08, green: 0.04, blue: 0.12)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            // Glow behind hero
            Circle()
                .fill(Color.orange.opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(y: -180)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Hero animation ─────────────────────────────────────
                    ZStack {
                        // Battleground hint
                        if let hero {
                            Image(hero.battleground.assetName)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 220)
                                .clipped()
                                .overlay(
                                    LinearGradient(
                                        colors: [Color.clear, Color(red: 0.05, green: 0.05, blue: 0.10)],
                                        startPoint: .top, endPoint: .bottom
                                    )
                                )
                        }

                        // Hero sprite
                        if let hero {
                            let frames = hero.heroClass.idleFrames
                            Image(frames[heroFrame % frames.count])
                                .resizable()
                                .scaledToFit()
                                .frame(height: 120)
                                .shadow(color: .orange.opacity(0.4), radius: 12)
                                .offset(y: 30)
                        }
                    }
                    .frame(height: 220)
                    .clipped()

                    // ── Headlines ──────────────────────────────────────────
                    VStack(spacing: 8) {
                        Text("⚔️ Become Unstoppable")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text("Try **3 days FREE**, then unlock everything.\nCancel anytime.")
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(Color(white: 0.6))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 28)

                    // ── Plan selector ──────────────────────────────────────
                    VStack(spacing: 10) {
                        planCard(
                            plan: .yearly,
                            title: "Yearly",
                            badge: "BEST VALUE",
                            price: "$24.99 / year",
                            sub: "= $2.08 / month · 3-day free trial",
                            accentColor: .orange
                        )
                        planCard(
                            plan: .monthly,
                            title: "Monthly",
                            badge: nil,
                            price: "$8.99 / month",
                            sub: "Billed monthly",
                            accentColor: Color(white: 0.4)
                        )
                        planCard(
                            plan: .weekly,
                            title: "Weekly",
                            badge: nil,
                            price: "$4.99 / week",
                            sub: "Billed every 7 days",
                            accentColor: Color(white: 0.4)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)

                    // ── Feature list ───────────────────────────────────────
                    VStack(alignment: .leading, spacing: 12) {
                        featureRow("⚔️", "Unlimited routines & monsters")
                        featureRow("🏔️", "Full 90-day mountain challenge")
                        featureRow("🏆", "All achievements & leaderboards")
                        featureRow("🔕", "Zero ads, forever")
                        featureRow("🚀", "All future updates included")
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 28)
                    .padding(.bottom, 8)

                    // ── CTA ────────────────────────────────────────────────
                    VStack(spacing: 12) {
                        Button {
                            // TODO: Superwall purchase
                        } label: {
                            Text(selectedPlan == .yearly ? "Start 3-Day Free Trial 🔥" : "Subscribe Now 🔥")
                                .font(.system(size: 17, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    LinearGradient(
                                        colors: [Color(red: 0.95, green: 0.45, blue: 0.0),
                                                 Color(red: 0.80, green: 0.25, blue: 0.05)],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: .orange.opacity(0.45), radius: 10, y: 4)
                        }
                        .buttonStyle(.plain)

                        Button {
                            // TODO: restore
                        } label: {
                            Text("Restore purchases")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(Color(white: 0.3))
                        }
                        .buttonStyle(.plain)

                        // Trust badges
                        HStack(spacing: 20) {
                            trustBadge(icon: "checkmark.seal.fill", text: "Cancel Anytime")
                            trustBadge(icon: "lock.fill", text: "Secure")
                            trustBadge(icon: "arrow.counterclockwise", text: "Restore")
                        }

                        Text("Payment will be charged to your Apple ID. Subscription auto-renews unless cancelled at least 24h before the end of the period.")
                            .font(.system(size: 9, design: .rounded))
                            .foregroundColor(Color(white: 0.2))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 28)
                }
            }
        }
        .navigationTitle("Paywall Preview 1")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { startAmbient() }
        .onDisappear {
            heroWaitTimer?.invalidate()
            heroAnimTimer?.invalidate()
        }
    }

    // MARK: - Sub-views

    @ViewBuilder
    private func planCard(plan: Plan, title: String, badge: String?, price: String, sub: String, accentColor: Color) -> some View {
        let isSelected = selectedPlan == plan
        Button { selectedPlan = plan } label: {
            HStack(spacing: 14) {
                // Radio
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.orange : Color(white: 0.3), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 12, height: 12)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        if let badge {
                            Text(badge)
                                .font(.system(size: 9, weight: .black, design: .rounded))
                                .foregroundColor(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.orange)
                                .cornerRadius(4)
                        }
                    }
                    Text(sub)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(Color(white: 0.45))
                }

                Spacer()

                Text(price)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? .orange : Color(white: 0.5))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color(white: 0.13) : Color(white: 0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.orange.opacity(0.6) : Color(white: 0.12), lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: selectedPlan)
    }

    @ViewBuilder
    private func featureRow(_ emoji: String, _ text: String) -> some View {
        HStack(spacing: 14) {
            Text(emoji).font(.system(size: 18))
            Text(text)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color(white: 0.75))
            Spacer()
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.orange)
        }
    }

    @ViewBuilder
    private func trustBadge(icon: String, text: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(white: 0.35))
            Text(text)
                .font(.system(size: 9, design: .rounded))
                .foregroundColor(Color(white: 0.3))
        }
    }

    // MARK: - Animation

    private func startAmbient() {
        guard let hero else { return }
        heroWaitTimer?.invalidate()
        heroAnimTimer?.invalidate()
        heroFrame = 0
        heroWaitTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            playOnce(frames: hero.heroClass.idleFrames)
        }
    }

    private func playOnce(frames: [String]) {
        var i = 0
        heroAnimTimer?.invalidate()
        heroAnimTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { t in
            heroFrame = i % frames.count
            i += 1
            if i >= frames.count { t.invalidate() }
        }
    }
}
