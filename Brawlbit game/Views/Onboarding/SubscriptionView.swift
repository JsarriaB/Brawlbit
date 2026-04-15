import SwiftUI
import SuperwallKit

struct SubscriptionView: View {
    let onContinue: () -> Void

    @State private var showPremiumWelcome = false

    private var challengeEndDate: String {
        let cal = Calendar.current
        let end = cal.date(byAdding: .day, value: 90, to: Date()) ?? Date()
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d, yyyy"
        return fmt.string(from: end)
    }

    var body: some View {
        ZStack {
        ZStack(alignment: .bottom) {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.06, blue: 0.14),
                    Color(red: 0.02, green: 0.10, blue: 0.18),
                    Color(red: 0.05, green: 0.08, blue: 0.16),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Subtle glow
            Circle()
                .fill(Color(red: 0.10, green: 0.45, blue: 0.65).opacity(0.18))
                .frame(width: 340, height: 340)
                .blur(radius: 80)
                .offset(x: 80, y: -180)
                .allowsHitTesting(false)

            Circle()
                .fill(Color(red: 0.80, green: 0.35, blue: 0.10).opacity(0.12))
                .frame(width: 260, height: 260)
                .blur(radius: 70)
                .offset(x: -90, y: 200)
                .allowsHitTesting(false)

            // Scrollable content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Header ────────────────────────────────────────────
                    VStack(spacing: 14) {
                        Text("⚔️")
                            .font(.system(size: 56))
                            .padding(.top, 52)

                        Text("Become the warrior\nyou were meant to be")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)

                        // Date pill
                        HStack(spacing: 6) {
                            Image(systemName: "flag.checkered")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.orange)
                            Text("Complete your challenge by \(challengeEndDate)")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(white: 0.85))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.orange.opacity(0.15))
                                .overlay(Capsule().stroke(Color.orange.opacity(0.35), lineWidth: 1))
                        )
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 28)

                    // ── Stars + rating ─────────────────────────────────
                    VStack(spacing: 6) {
                        Text("★★★★★")
                            .font(.system(size: 22))
                            .foregroundColor(Color(red: 1.0, green: 0.78, blue: 0.1))
                        Text("4.9 · Loved by warriors worldwide")
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(Color(white: 0.45))
                    }
                    .padding(.bottom, 24)

                    // ── Benefit pills ──────────────────────────────────
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 10
                    ) {
                        benefitPill(icon: "🏆", label: "Unlimited routines")
                        benefitPill(icon: "⚔️", label: "Premium monsters")
                        benefitPill(icon: "🔕", label: "No ads, ever")
                        benefitPill(icon: "🚀", label: "Future updates")
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)

                    dividerLine()

                    // ── Feature sections ───────────────────────────────
                    featureSection(
                        emoji: "⚔️",
                        title: "Daily battles that actually work",
                        bullets: [
                            ("Every task becomes a **monster** you must defeat before the deadline", "flame.fill"),
                            ("Miss the deadline and the monster **defeats you** — no shortcuts", "xmark.circle.fill"),
                            ("Hard mode or easy mode — **you choose** the challenge level", "dial.high.fill"),
                        ]
                    )

                    dividerLine()

                    featureSection(
                        emoji: "🏔️",
                        title: "The 90-Day Mountain",
                        bullets: [
                            ("Win every day and your hero **climbs one step** up the mountain", "mountain.2.fill"),
                            ("**Shield Orbs** protect you from a bad day — earn them from streaks", "shield.fill"),
                            ("Reach the summit in **90 days** and complete your challenge", "flag.checkered"),
                        ]
                    )

                    dividerLine()

                    featureSection(
                        emoji: "🔥",
                        title: "Streaks & progression",
                        bullets: [
                            ("Every victory earns **+10 XP** — reach 200 XP to level up your hero", "star.fill"),
                            ("Win a full day for **+15 coins** to unlock new arenas and classes", "dollarsign.circle.fill"),
                            ("**3-day streaks** reward you with a Shield Orb automatically", "arrow.up.circle.fill"),
                        ]
                    )

                    dividerLine()

                    // ── Testimonials ────────────────────────────────────
                    VStack(alignment: .leading, spacing: 16) {
                        Text("WARRIORS SPEAK")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(Color(white: 0.35))
                            .tracking(1.5)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        testimonialCard(
                            quote: "I've tried every productivity app. Brawlbit is the first one that made me feel **guilty** for skipping — in a good way.",
                            name: "Marcus T.",
                            stars: 5
                        )
                        testimonialCard(
                            quote: "The 90-day mountain finally made long-term goals feel **real**. I'm on day 47 and I've never been this consistent.",
                            name: "Sofia R.",
                            stars: 5
                        )
                        testimonialCard(
                            quote: "Hard mode is brutal. I've lost days, but that's what makes **winning days feel incredible**.",
                            name: "James K.",
                            stars: 5
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 28)

                    dividerLine()

                    // ── How it works ────────────────────────────────────
                    VStack(alignment: .leading, spacing: 20) {
                        Text("HOW BRAWLBIT WORKS")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(Color(white: 0.35))
                            .tracking(1.5)

                        howItWorksStep(number: "1", title: "Set your routines", body: "Create daily tasks and assign them a time slot. Each task spawns a monster with that exact deadline.")
                        howItWorksStep(number: "2", title: "Fight every day", body: "Complete the task in real life, then tap the battle button to defeat the monster before the clock runs out.")
                        howItWorksStep(number: "3", title: "Climb the mountain", body: "Win every day, grow your streak, collect Shield Orbs, and level up your hero on the path to the 90-day summit.")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 28)

                    dividerLine()

                    // ── Pro perks summary ───────────────────────────────
                    VStack(spacing: 0) {
                        Text("BRAWLBIT PRO INCLUDES")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(Color(white: 0.35))
                            .tracking(1.5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 16)

                        perkRow(icon: "checkmark.circle.fill", color: .green, text: "Unlimited routines & tasks")
                        perkRow(icon: "checkmark.circle.fill", color: .green, text: "No ads — ever")
                        perkRow(icon: "checkmark.circle.fill", color: .green, text: "Premium monster packs")
                        perkRow(icon: "checkmark.circle.fill", color: .green, text: "All future features & updates")
                        perkRow(icon: "checkmark.circle.fill", color: .green, text: "Priority support")
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 28)

                    // Bottom padding so content isn't hidden under sticky bar
                    Color.clear.frame(height: 200)
                }
            }

            // ── Sticky bottom bar ──────────────────────────────────────
            VStack(spacing: 0) {
                // Fade out gradient
                LinearGradient(
                    colors: [Color.clear, Color(red: 0.04, green: 0.06, blue: 0.14)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 32)

                VStack(spacing: 10) {
                    // Primary CTA — Superwall
                    Button {
                        Superwall.shared.register(placement: "main_paywall") {
                            DispatchQueue.main.async {
                                showPremiumWelcome = true
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Text("Get Brawlbit Pro")
                                .font(.system(size: 17, weight: .black, design: .rounded))
                            Text("🔥")
                                .font(.system(size: 17))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.95, green: 0.45, blue: 0.0), Color(red: 0.80, green: 0.25, blue: 0.05)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: Color.orange.opacity(0.4), radius: 10, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)

                    // Secondary CTA — skip to app for free
                    Button {
                        onContinue()
                    } label: {
                        Text("Continue for free")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(white: 0.5))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(Color(white: 0.10))
                            .cornerRadius(14)
                    }
                    .buttonStyle(.plain)

                    // Temporary skip button — remove at launch
                    Button {
                        onContinue()
                    } label: {
                        Text("Skip to app →")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(Color(white: 0.28))
                    }
                    .buttonStyle(.plain)

                    // Trust badges
                    HStack(spacing: 16) {
                        Label("Cancel Anytime", systemImage: "checkmark.seal.fill")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(Color(white: 0.35))
                        Label("Real discipline", systemImage: "bolt.fill")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(Color(white: 0.35))
                        Label("No hidden fees", systemImage: "lock.fill")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(Color(white: 0.35))
                    }
                    .padding(.bottom, 4)

                    Text("Free version includes ads. You can upgrade anytime in Profile.")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(Color(white: 0.22))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 36)
                }
                .padding(.horizontal, 24)
                .padding(.top, 6)
                .background(Color(red: 0.04, green: 0.06, blue: 0.14))
            }
        }
        .ignoresSafeArea(edges: .bottom)

        if showPremiumWelcome {
            PremiumWelcomeView { onContinue() }
                .transition(.opacity)
                .zIndex(10)
                .ignoresSafeArea()
        }
        }
        .animation(.easeInOut(duration: 0.35), value: showPremiumWelcome)
    }

    // MARK: - Sub-views

    @ViewBuilder
    private func benefitPill(icon: String, label: String) -> some View {
        HStack(spacing: 8) {
            Text(icon)
                .font(.system(size: 16))
            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(Color(white: 0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(white: 1, opacity: 0.06))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(white: 1, opacity: 0.09), lineWidth: 1))
    }

    @ViewBuilder
    private func featureSection(emoji: String, title: String, bullets: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Text(emoji)
                    .font(.system(size: 24))
                Text(title)
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 12) {
                ForEach(bullets, id: \.0) { bullet in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: bullet.1)
                            .font(.system(size: 13))
                            .foregroundColor(.orange)
                            .frame(width: 18, alignment: .center)
                            .padding(.top, 1)
                        boldMarkdown(bullet.0)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(Color(white: 0.72))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }

    @ViewBuilder
    private func testimonialCard(quote: String, name: String, stars: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(String(repeating: "★", count: stars))
                .font(.system(size: 13))
                .foregroundColor(Color(red: 1.0, green: 0.78, blue: 0.1))
            boldMarkdown(quote)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color(white: 0.75))
                .fixedSize(horizontal: false, vertical: true)
            Text("— \(name)")
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(Color(white: 0.35))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(white: 1, opacity: 0.05))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(white: 1, opacity: 0.08), lineWidth: 1))
    }

    @ViewBuilder
    private func howItWorksStep(number: String, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.18))
                    .frame(width: 34, height: 34)
                Text(number)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundColor(.orange)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(body)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(Color(white: 0.50))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder
    private func perkRow(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            Text(text)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color(white: 0.80))
            Spacer()
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func dividerLine() -> some View {
        Rectangle()
            .fill(Color(white: 1, opacity: 0.06))
            .frame(height: 1)
            .padding(.horizontal, 24)
    }

    // Minimal bold markdown: wraps **text** in bold, rest normal
    private func boldMarkdown(_ raw: String) -> Text {
        var result = Text("")
        let parts = raw.components(separatedBy: "**")
        for (i, part) in parts.enumerated() {
            if part.isEmpty { continue }
            if i % 2 == 1 {
                result = result + Text(part).bold().foregroundColor(.white)
            } else {
                result = result + Text(part)
            }
        }
        return result
    }
}
