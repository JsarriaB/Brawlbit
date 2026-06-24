import SwiftUI
import SwiftData

@Observable
final class AppState {
    var hasCompletedOnboarding: Bool = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }
    var isPro: Bool = UserDefaults.standard.bool(forKey: "isPro") {
        didSet { UserDefaults.standard.set(isPro, forKey: "isPro") }
    }
    var showDaySummary: Bool = false
    var showChallengeComplete: Bool = false
    var showDailyChest: Bool = false
    var dailyChestCoins: Int = 0
    var orbPending: Bool = false
    var revanchaOrbUsed: Bool = false

    /// Resets all tasks if the calendar day has changed since last reset.
    /// Also restores hero HP to full for the new day.
    func resetTasksIfNewDay(tasks: [MonsterTask], hero: Hero?, context: ModelContext) {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let lastReset = (UserDefaults.standard.object(forKey: "lastResetDate") as? Date)
            .map { cal.startOfDay(for: $0) } ?? .distantPast

        guard today > lastReset else { return }

        // Weekday index: 0=Mon, 1=Tue, …, 6=Sun
        // Calendar.weekday: 1=Sun, 2=Mon, …, 7=Sat → convert
        let rawWeekday = cal.component(.weekday, from: Date())
        let todayIndex = (rawWeekday - 2 + 7) % 7

        for task in tasks {
            let runsToday = task.daysOfWeek.isEmpty || task.daysOfWeek.contains(todayIndex)
            task.isCompleted = false
            task.completedAt = nil
            task.isActive = runsToday
        }
        hero?.hp = 1.0
        try? context.save()
        NotificationService.scheduleAll(tasks: tasks)

        UserDefaults.standard.set(Date(), forKey: "lastResetDate")
        UserDefaults.standard.removeObject(forKey: "lastSummaryDate")
        WidgetWriter.write(tasks: tasks, hero: hero)
    }

    /// Shows the daily chest on first open of the day, with a variable coin reward.
    func checkDailyChest() {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let lastChest = (UserDefaults.standard.object(forKey: "lastDailyChestDate") as? Date)
            .map { cal.startOfDay(for: $0) } ?? .distantPast
        guard today > lastChest else { return }
        UserDefaults.standard.set(Date(), forKey: "lastDailyChestDate")
        let roll = Int.random(in: 1...100)
        dailyChestCoins = switch roll {
        case 1...2:   150   // 2%  legendary
        case 3...10:  80    // 8%  epic
        case 11...35: 40    // 25% rare
        default:      15    // 65% common
        }
        showDailyChest = true
    }

    /// Returns true if the hero currently has an active vacation that covers today.
    func isOnVacation(hero: Hero?) -> Bool {
        let cal = Calendar.current
        guard let end = hero?.vacationEndDate else { return false }
        let today = cal.startOfDay(for: Date())
        let endDay = cal.startOfDay(for: end)
        if today <= endDay { return true }
        // Vacation expired — clear it
        hero?.vacationEndDate = nil
        return false
    }
}
