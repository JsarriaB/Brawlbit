import SwiftUI
import SwiftData

@Observable
final class AppState {
    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") }
        set { UserDefaults.standard.set(newValue, forKey: "hasCompletedOnboarding") }
    }
    var showDaySummary: Bool = false
    var showChallengeComplete: Bool = false
    var orbPending: Bool = false

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
