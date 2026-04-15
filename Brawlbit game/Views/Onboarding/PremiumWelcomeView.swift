import SwiftUI
import SwiftData

struct PremiumWelcomeView: View {
    let onBegin: () -> Void

    @Query private var heroes: [Hero]
    var hero: Hero? { heroes.first }

    @State private var heroFrame: Int = 0
    @State private var animTimer: Timer?
    @State private var waitTimer: Timer?

    @State private var glowScale: CGFloat = 1.0
    @State private var appeared = false
    @State private var crownScale: CGFloat = 0.4
    @State private var crownOpacity: Double = 0

    var body: some View {
        ZStack {
            // Background — rich dark gold
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.04, blue: 0.02),
                    Color(red: 0.10, green: 0.07, blue: 0.02),
                    Color(red: 0.05, green: 0.05, blue: 0.10),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Golden glow behind hero
            Circle()
                .fill(Color(red: 1.0, green: 0.72, blue: 0.1).opacity(0.22))
                .frame(width: 320, height: 320)
                .blur(radius: 70)
                .scaleEffect(glowScale)
                .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: glowScale)
                .offset(y: -30)
                .allowsHitTesting(false)

            // Outer soft red glow
            Circle()
                .fill(Color(red: 0.90, green: 0.25, blue: 0.0).opacity(0.10))
                .frame(width: 420, height: 420)
                .blur(radius: 90)
                .offset(y: 60)
                .allowsHitTesting(false)

            VStack(spacing: 0) {

                Spacer()

                // ── Crown / Pro badge ──────────────────────────────────
                Text("👑")
                    .font(.system(size: 48))
                    .scaleEffect(crownScale)
                    .opacity(crownOpacity)
                    .animation(.spring(response: 0.6, dampingFraction: 0.55), value: crownScale)
                    .padding(.bottom, 4)

                // ── Hero sprite ────────────────────────────────────────
                if let hero {
                    let frames = hero.heroClass.idleFrames
                    Image(frames[heroFrame % frames.count])
                        .resizable()
                        .scaledToFit()
                        .frame(height: 140)
                        .shadow(color: Color(red: 1.0, green: 0.72, blue: 0.1).opacity(0.55), radius: 20)
                        .padding(.bottom, 8)
                }

                // ── Title ──────────────────────────────────────────────
                VStack(spacing: 10) {
                    Text("You're a Pro Warrior!")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.easeOut(duration: 0.5).delay(0.15), value: appeared)

                    Text("Your journey to the summit begins now.\nNo excuses. No retreats. Only victory.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 1.0, green: 0.82, blue: 0.3))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)
                        .animation(.easeOut(duration: 0.5).delay(0.28), value: appeared)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 36)

                // ── Perks ──────────────────────────────────────────────
                VStack(spacing: 12) {
                    premiumPerk(icon: "crown.fill", color: Color(red: 1.0, green: 0.75, blue: 0.1), text: "Brawlbit Pro — unlocked")
                    premiumPerk(icon: "infinity", color: .orange, text: "Unlimited routines & monsters")
                    premiumPerk(icon: "xmark.circle.fill", color: Color(red: 0.4, green: 0.85, blue: 0.45), text: "No ads — ever")
                    premiumPerk(icon: "arrow.up.circle.fill", color: .cyan, text: "All future updates included")
                }
                .padding(.horizontal, 32)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
                .animation(.easeOut(duration: 0.5).delay(0.42), value: appeared)

                Spacer()

                // ── CTA ────────────────────────────────────────────────
                Button {
                    onBegin()
                } label: {
                    HStack(spacing: 10) {
                        Text("Begin My Journey")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                        Text("⚔️")
                            .font(.system(size: 18))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.60, blue: 0.0),
                                Color(red: 0.85, green: 0.30, blue: 0.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color.orange.opacity(0.55), radius: 14, x: 0, y: 5)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 28)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.58), value: appeared)

                Text("Thank you for supporting Brawlbit 🙏")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(Color(white: 0.28))
                    .padding(.top, 14)
                    .padding(.bottom, 50)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.65), value: appeared)
            }
        }
        .onAppear {
            startGlow()
            startAmbient()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                appeared = true
                crownScale = 1.0
                crownOpacity = 1.0
            }
        }
        .onDisappear {
            waitTimer?.invalidate()
            animTimer?.invalidate()
        }
    }

    // MARK: - Sub-views

    @ViewBuilder
    private func premiumPerk(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 26)
            Text(text)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(Color(white: 0.85))
            Spacer()
        }
    }

    // MARK: - Animation

    private func startGlow() {
        glowScale = 1.15
    }

    private func startAmbient() {
        guard let hero else { return }
        heroFrame = 0
        waitTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            playOnce(frames: hero.heroClass.idleFrames)
        }
        playOnce(frames: hero.heroClass.idleFrames)
    }

    private func playOnce(frames: [String]) {
        var i = 0
        animTimer?.invalidate()
        animTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { t in
            heroFrame = i % frames.count
            i += 1
            if i >= frames.count { t.invalidate() }
        }
    }
}
