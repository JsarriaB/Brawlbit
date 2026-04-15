import SwiftUI
import SwiftData
import SuperwallKit

@main
struct Brawlbit_gameApp: App {
    init() {
        Superwall.configure(apiKey: "pk_DqeulzREeHP16fpKZhYKQ")
    }

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
