import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var step: OnboardingStep = .welcome
    @State private var heroName: String = ""
    @State private var heroClass: HeroClass = .knight
    @State private var heroGender: Gender = .male
    @State private var heroBattleground: Battleground = .forest

    enum OnboardingStep {
        case welcome, heroSelection, battleground, monsterSetup, goal
    }

    var body: some View {
        switch step {
        case .welcome:
            WelcomeView { step = .heroSelection }
        case .heroSelection:
            HeroSelectionView(
                heroName: $heroName,
                heroClass: $heroClass,
                heroGender: $heroGender
            ) { step = .battleground }
        case .battleground:
            BattlegroundSelectionView(battleground: $heroBattleground) {
                step = .monsterSetup
            }
        case .monsterSetup:
            MonsterSetupView(
                heroName: heroName,
                heroClass: heroClass,
                heroGender: heroGender,
                battleground: heroBattleground
            ) { step = .goal }
        case .goal:
            GoalSetupView { appState.hasCompletedOnboarding = true }
        }
    }
}
