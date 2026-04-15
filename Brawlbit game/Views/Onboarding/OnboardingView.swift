import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var step: OnboardingStep = .welcome
    @State private var heroName: String = ""
    @State private var heroClass: HeroClass = .knight
    @State private var heroBattleground: Battleground = .forest
    @State private var easyMode: Bool = true

    enum OnboardingStep {
        case welcome
        case heroSelection
        case beforeAfter1
        case beforeAfter2
        case featureSlides
        case quiz1, quiz2, quiz3
        case analyzing
        case chart
        case reviews
        case battleDemo
        case battleground
        case monsterSetup
        case goal
        case promise
        case subscription
    }

    var body: some View {
        switch step {
        case .welcome:
            WelcomeView { step = .heroSelection }

        case .heroSelection:
            HeroSelectionView(
                heroName: $heroName,
                heroClass: $heroClass
            ) { step = .beforeAfter1 }

        case .beforeAfter1:
            BeforeAfterView(
                question: "Want to plan your days better?",
                leftEmojis: "📱🍕🛋️",
                leftLabel: "No structure",
                rightEmojis: "⚔️🏆🔥",
                rightLabel: "With Brawlbit"
            ) { step = .beforeAfter2 }

        case .beforeAfter2:
            BeforeAfterView(
                question: "Want to become\nwho you want to be?",
                leftEmojis: "💔",
                leftLabel: "Monsters defeat you",
                rightEmojis: "⚔️✨",
                rightLabel: "You control every day"
            ) { step = .featureSlides }

        case .featureSlides:
            FeatureSlidesView { step = .quiz1 }

        case .quiz1:
            QuizView(
                question: "How often do you abandon\nyour own goals?",
                options: [
                    QuizOption(emoji: "😄", text: "I never give up"),
                    QuizOption(emoji: "🙂", text: "Rarely"),
                    QuizOption(emoji: "😐", text: "Sometimes"),
                    QuizOption(emoji: "😤", text: "Very often"),
                ],
                progress: 0.33,
                multiSelect: false
            ) { _ in step = .quiz2 }

        case .quiz2:
            QuizView(
                question: "What is your biggest enemy?",
                options: [
                    QuizOption(emoji: "🐢", text: "Procrastination"),
                    QuizOption(emoji: "🌀", text: "Lack of structure"),
                    QuizOption(emoji: "💤", text: "Low motivation"),
                    QuizOption(emoji: "⏰", text: "Forgetting to do it"),
                ],
                progress: 0.66,
                multiSelect: false
            ) { _ in step = .quiz3 }

        case .quiz3:
            QuizView(
                question: "What do you want to conquer?",
                options: [
                    QuizOption(emoji: "💪", text: "My fitness"),
                    QuizOption(emoji: "📚", text: "My studies"),
                    QuizOption(emoji: "💼", text: "My career"),
                    QuizOption(emoji: "🧘", text: "My mental wellbeing"),
                    QuizOption(emoji: "🎯", text: "My daily habits"),
                    QuizOption(emoji: "🎨", text: "My creativity"),
                ],
                progress: 1.0,
                multiSelect: true
            ) { _ in step = .analyzing }

        case .analyzing:
            AnalyzingView { step = .chart }

        case .chart:
            BattleChartView { step = .reviews }

        case .reviews:
            ReviewsView { step = .battleDemo }

        case .battleDemo:
            BattleDemoView { chosen in
                easyMode = chosen
                step = .battleground
            }

        case .battleground:
            BattlegroundSelectionView(battleground: $heroBattleground) {
                step = .monsterSetup
            }

        case .monsterSetup:
            MonsterSetupView(
                heroName: heroName,
                heroClass: heroClass,
                battleground: heroBattleground,
                easyMode: easyMode
            ) { step = .goal }

        case .goal:
            GoalSetupView { step = .promise }

        case .promise:
            PromiseView { step = .subscription }

        case .subscription:
            SubscriptionView { appState.hasCompletedOnboarding = true }
        }
    }
}
