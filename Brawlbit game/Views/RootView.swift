import SwiftUI
import SwiftData

struct RootView: View {
    @Query private var heroes: [Hero]
    @State private var appState = AppState()

    var body: some View {
        if appState.hasCompletedOnboarding && !heroes.isEmpty {
            MainTabView()
                .environment(appState)
                .sheet(isPresented: $appState.showDaySummary) {
                    DaySummaryView()
                }
                .sheet(isPresented: $appState.showChallengeComplete) {
                    ChallengeCompleteView()
                }
                .onReceive(NotificationCenter.default.publisher(for: .init("showChallengeComplete"))) { _ in
                    appState.showChallengeComplete = true
                }
        } else {
            OnboardingView()
                .environment(appState)
        }
    }
}
