import SwiftUI

// MARK: - Step model

private struct TutorialStep {
    let tab: Int
    let title: String
    let message: String
    /// Returns the highlight rect given (screenSize, safeAreaTop, tabBarHeight)
    let highlight: (CGSize, CGFloat, CGFloat) -> CGRect
    let calloutBelow: Bool
    /// When tab == 1 (Progress), controls the Mountain(0) / Progress(1) sub-picker
    var progresoSubTab: Int = 0
}

private let tutorialSteps: [TutorialStep] = [
    // ── Today tab ──────────────────────────────────────────────────────────
    TutorialStep(
        tab: 0,
        title: "⚔️ Your Battle Arena",
        message: "This is where you fight. Every task becomes a monster — defeat it before the deadline.",
        highlight: { size, safeTop, _ in
            CGRect(x: 0, y: safeTop, width: size.width, height: 300)
        },
        calloutBelow: true
    ),
    TutorialStep(
        tab: 0,
        title: "📋 Today's Tasks",
        message: "Complete a task in real life, then tap its button here to trigger the battle and defeat the monster.",
        highlight: { size, safeTop, tabBarH in
            let y = safeTop + 300
            return CGRect(x: 0, y: y, width: size.width, height: size.height - y - tabBarH)
        },
        calloutBelow: false
    ),
    TutorialStep(
        tab: 0,
        title: "🗓️ Winning & Losing a Day",
        message: "Win at least half your battles → Day Won.\nLose more than half → Day Lost.\nIn Easy mode, a late revenge still counts. In Hard mode, a missed deadline is always a defeat.",
        highlight: { size, safeTop, _ in
            let y = safeTop + 300
            return CGRect(x: 0, y: y, width: size.width, height: 56)
        },
        calloutBelow: true
    ),
    TutorialStep(
        tab: 0,
        title: "🔥 Win Streak",
        message: "Win consecutive days to grow your streak. Every 3-day streak earns you a Shield Orb that protects you from one lost day.",
        highlight: { size, safeTop, _ in
            let y = safeTop + 300
            return CGRect(x: 0, y: y, width: size.width, height: 56)
        },
        calloutBelow: true
    ),
    // ── Progress tab — Mountain sub-tab ────────────────────────────────────
    TutorialStep(
        tab: 1,
        title: "🏔️ The 90-Day Mountain",
        message: "Your hero climbs one step for every day you win. Reach the summit in 90 days to complete your challenge.",
        highlight: { size, safeTop, tabBarH in
            CGRect(x: size.width * 0.1, y: safeTop + 60,
                   width: size.width * 0.8, height: size.height - safeTop - 60 - tabBarH - 40)
        },
        calloutBelow: false,
        progresoSubTab: 0
    ),
    TutorialStep(
        tab: 1,
        title: "⭐ Points & Levels",
        message: "Defeating a monster earns +10 XP. Win a full day → +15 coins. Level up every 200 XP for a +25 coins bonus. Your score is shown here on the mountain.",
        highlight: { size, safeTop, tabBarH in
            // Bottom-right HUD in MountainView
            CGRect(x: size.width - 130, y: size.height - tabBarH - 200,
                   width: 120, height: 140)
        },
        calloutBelow: false,
        progresoSubTab: 0
    ),
    // ── Progress tab — Progress sub-tab ────────────────────────────────────
    TutorialStep(
        tab: 1,
        title: "🛡️ Shield Orbs",
        message: "Earn a Shield Orb every 3-day streak. When you lose a day, the orb is consumed automatically — protecting your mountain progress. You can hold up to 3 at a time.",
        highlight: { size, safeTop, tabBarH in
            CGRect(x: 0, y: safeTop + 60,
                   width: size.width, height: size.height - safeTop - 60 - tabBarH)
        },
        calloutBelow: false,
        progresoSubTab: 1
    ),
    TutorialStep(
        tab: 1,
        title: "🏆 Achievements",
        message: "Unlock achievements by hitting milestones — first victory, long streaks, perfect days and more. Each achievement rewards XP.",
        highlight: { size, safeTop, tabBarH in
            CGRect(x: 0, y: safeTop + 60,
                   width: size.width, height: size.height - safeTop - 60 - tabBarH)
        },
        calloutBelow: false,
        progresoSubTab: 1
    ),
    // ── History tab ─────────────────────────────────────────────────────────
    TutorialStep(
        tab: 2,
        title: "📜 Battle History",
        message: "Every past day is recorded here. Tap any day to review each battle result in detail.",
        highlight: { size, safeTop, tabBarH in
            CGRect(x: 16, y: safeTop + 56,
                   width: size.width - 32, height: size.height - safeTop - 56 - tabBarH - 20)
        },
        calloutBelow: false
    ),
    // ── Profile tab ─────────────────────────────────────────────────────────
    TutorialStep(
        tab: 3,
        title: "⚙️ Profile & Settings",
        message: "Manage your routines, change game mode, set vacation days, and replay this tutorial whenever you want.",
        highlight: { size, safeTop, tabBarH in
            CGRect(x: 16, y: safeTop + 280,
                   width: size.width - 32, height: size.height - safeTop - 280 - tabBarH - 20)
        },
        calloutBelow: false
    ),
    TutorialStep(
        tab: 3,
        title: "🪙 Coins & Customization",
        message: "Win a full day → +15 coins. Level up → +25 coins bonus. Earn more from achievements.\n\nGo to Profile → Customization to spend coins on new hero classes and battle arenas.",
        highlight: { size, safeTop, tabBarH in
            CGRect(x: 16, y: safeTop + 280,
                   width: size.width - 32, height: size.height - safeTop - 280 - tabBarH - 20)
        },
        calloutBelow: false
    ),
]

// MARK: - Main overlay

struct TutorialOverlayView: View {
    @Binding var selectedTab: Int
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial: Bool = false
    @AppStorage("progresoSelectedTab") private var progresoSubTab: Int = 0

    @State private var stepIndex = 0
    @State private var visible = false

    private var step: TutorialStep { tutorialSteps[stepIndex] }
    private let tabBarHeight: CGFloat = 76

    var body: some View {
        GeometryReader { geo in
            let safeTop = geo.safeAreaInsets.top
            let size = geo.size
            let rect = step.highlight(size, safeTop, tabBarHeight)

            ZStack {
                // Spotlight overlay with cutout
                ZStack {
                    Color.black.opacity(0.78)
                        .ignoresSafeArea()
                    RoundedRectangle(cornerRadius: 14)
                        .frame(width: rect.width, height: rect.height)
                        .position(x: rect.midX, y: rect.midY)
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
                .allowsHitTesting(false)

                // Callout card
                let calloutY: CGFloat = step.calloutBelow
                    ? rect.maxY + 20
                    : rect.minY - 20

                calloutCard(step: step)
                    .frame(maxWidth: size.width - 48)
                    .position(x: size.width / 2, y: calloutY + (step.calloutBelow ? 60 : -60))
                    .animation(.spring(response: 0.4, dampingFraction: 0.85), value: stepIndex)

                // Progress dots
                HStack(spacing: 8) {
                    ForEach(0..<tutorialSteps.count, id: \.self) { i in
                        Circle()
                            .fill(i == stepIndex ? Color.orange : Color(white: 0.35))
                            .frame(width: i == stepIndex ? 8 : 6, height: i == stepIndex ? 8 : 6)
                            .animation(.easeInOut(duration: 0.2), value: stepIndex)
                    }
                }
                .position(x: size.width / 2, y: size.height - tabBarHeight - 16)
            }
        }
        .opacity(visible ? 1 : 0)
        .animation(.easeIn(duration: 0.3), value: visible)
        .onAppear {
            applyStep(tutorialSteps[stepIndex])
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { visible = true }
        }
    }

    @ViewBuilder
    private func calloutCard(step: TutorialStep) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(step.title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(step.message)
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(Color(white: 0.75))
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Spacer()
                Button {
                    advance()
                } label: {
                    Text(stepIndex == tutorialSteps.count - 1 ? "Got it! 🎉" : "Next →")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.orange)
                        .cornerRadius(10)
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.12))
                .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }

    private func applyStep(_ s: TutorialStep) {
        selectedTab = s.tab
        progresoSubTab = s.progresoSubTab
    }

    private func advance() {
        let next = stepIndex + 1
        if next >= tutorialSteps.count {
            withAnimation(.easeOut(duration: 0.3)) { visible = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                hasSeenTutorial = true
            }
        } else {
            withAnimation(.easeInOut(duration: 0.25)) { visible = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                stepIndex = next
                applyStep(tutorialSteps[next])
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeIn(duration: 0.25)) { visible = true }
                }
            }
        }
    }
}
