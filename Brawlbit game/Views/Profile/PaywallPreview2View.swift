import SwiftUI
import SwiftData

// ── PAYWALL 2: Exit-intent "last chance" paywall with countdown ────────────────
// TEMP: reference for Superwall design. Remove before launch.

struct PaywallPreview2View: View {
    @Query private var heroes: [Hero]
    var hero: Hero? { heroes.first }

    @State private var secondsLeft: Int = 300   // 5 minutes
    @State private var countdownTimer: Timer?
    @State private var heroFrame: Int = 0
    @State private var heroWaitTimer: Timer?
    @State private var heroAnimTimer: Timer?
    @State private var pulse = false

    private var timeString: String {
        let m = secondsLeft / 60
        let s = secondsLeft % 60
        return String(format: "%d:%02d", m, s)
    }

    var body: some View {
        ZStack {
            // Background — darker, more urgent
            LinearGradient(
                colors: [Color(red: 0.08, green: 0.03, blue: 0.03),
                         Color(red: 0.05, green: 0.04, blue: 0.10)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            // Red glow
            Circle()
                .fill(Color.red.opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 70)
                .offset(y: -150)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // ── Urgency header ─────────────────────────────────────
                    VStack(spacing: 10) {
                        Text("⚠️ LIMITED OFFER")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundColor(.red)
                            .tracking(2)
                            .padding(.top, 32)

                        Text("Don't let this\nopportunity escape.")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                    }
                    .padding(.horizontal, 28)

                    // ── Countdown timer ────────────────────────────────────
                    VStack(spacing: 6) {
                        Text("Offer expires in")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(Color(white: 0.45))

                        Text(timeString)
                            .font(.system(size: 52, weight: .black, design: .monospaced))
                            .foregroundColor(secondsLeft <= 60 ? .red : .orange)
                            .scaleEffect(pulse ? 1.04 : 1.0)
                            .animation(.easeInOut(duration: 0.5), value: pulse)
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(white: 0.07))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(secondsLeft <= 60 ? Color.red.opacity(0.5) : Color.orange.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    // ── Hero ───────────────────────────────────────────────
                    if let hero {
                        let frames = hero.heroClass.idleFrames
                        Image(frames[heroFrame % frames.count])
                            .resizable()
                            .scaledToFit()
                            .frame(height: 110)
                            .shadow(color: .orange.opacity(0.35), radius: 10)
                            .padding(.top, 20)
                    }

                    // ── Offer card ─────────────────────────────────────────
                    VStack(spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Text("🔥 EXCLUSIVE DEAL")
                                        .font(.system(size: 10, weight: .black, design: .rounded))
                                        .foregroundColor(.orange)
                                        .tracking(1)
                                    Text("50% OFF")
                                        .font(.system(size: 10, weight: .black, design: .rounded))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.orange)
                                        .cornerRadius(4)
                                }
                                Text("Brawlbit Pro · Yearly")
                                    .font(.system(size: 18, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                Text("3-day free trial included")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(Color(white: 0.5))
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("$24.99")
                                    .font(.system(size: 13, design: .rounded))
                                    .foregroundColor(Color(white: 0.35))
                                    .strikethrough(true, color: Color(white: 0.35))
                                Text("$12.49")
                                    .font(.system(size: 24, weight: .black, design: .rounded))
                                    .foregroundColor(.orange)
                                Text("/ year")
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundColor(Color(white: 0.4))
                            }
                        }
                        .padding(18)
                        .background(Color(white: 0.11))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.orange.opacity(0.45), lineWidth: 1.5)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    // ── What you unlock ────────────────────────────────────
                    VStack(alignment: .leading, spacing: 10) {
                        Text("WHAT YOU UNLOCK")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(Color(white: 0.3))
                            .tracking(1.5)
                            .padding(.bottom, 4)

                        unlockRow("⚔️", "Unlimited routines & monsters", color: .orange)
                        unlockRow("🏔️", "Complete the 90-day mountain", color: .orange)
                        unlockRow("🏆", "All achievements unlocked", color: .orange)
                        unlockRow("🔕", "Zero ads, forever", color: .orange)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    // ── CTA ────────────────────────────────────────────────
                    VStack(spacing: 10) {
                        Button {
                            // TODO: Superwall purchase
                        } label: {
                            HStack(spacing: 8) {
                                Text("Claim My 50% Discount")
                                    .font(.system(size: 17, weight: .black, design: .rounded))
                                Text("🔥")
                                    .font(.system(size: 17))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 0.95, green: 0.3, blue: 0.0),
                                             Color(red: 0.75, green: 0.10, blue: 0.0)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.red.opacity(0.45), radius: 12, y: 4)
                        }
                        .buttonStyle(.plain)

                        Button {
                            // dismiss
                        } label: {
                            Text("No thanks, I don't want the deal")
                                .font(.system(size: 11, design: .rounded))
                                .foregroundColor(Color(white: 0.25))
                        }
                        .buttonStyle(.plain)

                        Text("Offer only available once. Payment charged to Apple ID on confirmation.")
                            .font(.system(size: 9, design: .rounded))
                            .foregroundColor(Color(white: 0.2))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                }
            }
        }
        .navigationTitle("Paywall Preview 2 (Exit)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            startCountdown()
            startAmbient()
        }
        .onDisappear {
            countdownTimer?.invalidate()
            heroWaitTimer?.invalidate()
            heroAnimTimer?.invalidate()
        }
    }

    // MARK: - Sub-views

    @ViewBuilder
    private func unlockRow(_ emoji: String, _ text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Text(emoji).font(.system(size: 16))
            Text(text)
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(Color(white: 0.72))
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(color)
        }
    }

    // MARK: - Timers

    private func startCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if secondsLeft > 0 {
                secondsLeft -= 1
                if secondsLeft % 2 == 0 { pulse.toggle() }
            } else {
                countdownTimer?.invalidate()
            }
        }
    }

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
