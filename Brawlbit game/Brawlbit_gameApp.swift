import SwiftUI
import SwiftData

@main
struct Brawlbit_gameApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [
            Hero.self,
            MonsterTask.self,
            Battle.self,
            DayRecord.self,
            Goal90.self,
            UnlockedAchievement.self
        ])
    }
}
