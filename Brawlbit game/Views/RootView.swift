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
        } else {
            OnboardingView()
                .environment(appState)
        }
    }
}
