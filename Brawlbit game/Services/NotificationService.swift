import UserNotifications
import Foundation

enum NotificationService {

    /// Requests notification permission. Safe to call multiple times.
    static func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    /// Cancels ALL pending notifications and re-schedules:
    ///   - Repeating weekly warnings (-3h, -30min, -5min) per task × day
    ///   - One-shot defeat notification at each task's deadline TODAY (if deadline is in the future)
    ///
    /// Weekday conversion: our 0=Mon…6=Sun → UNCalendar 1=Sun…7=Sat
    static func scheduleAll(tasks: [MonsterTask]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let cal = Calendar.current
        let now = Date()
        let rawWeekday = cal.component(.weekday, from: now)
        let todayIndex = (rawWeekday - 2 + 7) % 7  // 0=Mon…6=Sun

        // Read toggle preferences (default true if never set)
        let enabled3h     = UserDefaults.standard.object(forKey: "notif_3h")     as? Bool ?? true
        let enabled30min  = UserDefaults.standard.object(forKey: "notif_30min")  as? Bool ?? true
        let enabled5min   = UserDefaults.standard.object(forKey: "notif_5min")   as? Bool ?? true
        let enableDefeat  = UserDefaults.standard.object(forKey: "notif_defeat") as? Bool ?? true

        for task in tasks {
            let days = task.daysOfWeek.isEmpty ? Array(0...6) : task.daysOfWeek

            for dayIndex in days {
                // Convert to UNCalendar weekday (1=Sun…7=Sat)
                let raw = (dayIndex + 2) % 7
                let weekday = raw == 0 ? 7 : raw

                // --- Repeating weekly warnings ---
                let warningOffsets: [(Int, String, Bool)] = [
                    (-180, "3h",    enabled3h),
                    (-30,  "30min", enabled30min),
                    (-5,   "5min",  enabled5min),
                ]
                for (offsetMins, label, enabled) in warningOffsets {
                    guard enabled else { continue }
                    let totalMins = task.deadlineHour * 60 + task.deadlineMinute + offsetMins
                    guard totalMins >= 0 else { continue }
                    let notifyHour   = totalMins / 60
                    let notifyMinute = totalMins % 60
                    guard notifyHour < 24 else { continue }

                    var dc = DateComponents()
                    dc.weekday = weekday
                    dc.hour    = notifyHour
                    dc.minute  = notifyMinute

                    let content      = UNMutableNotificationContent()
                    content.title    = "⚔️ \(task.taskName)"
                    content.body     = warningBody(label: label)
                    content.sound    = .default

                    let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
                    let request = UNNotificationRequest(
                        identifier: "\(task.notifId)-day\(dayIndex)-\(label)",
                        content: content,
                        trigger: trigger
                    )
                    center.add(request, withCompletionHandler: nil)
                }

                // --- One-shot defeat notification for TODAY only ---
                guard enableDefeat, dayIndex == todayIndex else { continue }

                var deadlineDC = cal.dateComponents([.year, .month, .day], from: now)
                deadlineDC.hour   = task.deadlineHour
                deadlineDC.minute = task.deadlineMinute
                deadlineDC.second = 0
                guard let deadlineDate = cal.date(from: deadlineDC),
                      deadlineDate > now else { continue }

                let defeatContent      = UNMutableNotificationContent()
                defeatContent.title    = "💀 \(task.taskName)"
                defeatContent.body     = "Time's up — the monster defeated you!"
                defeatContent.sound    = .default

                let defeatTrigger = UNCalendarNotificationTrigger(dateMatching: deadlineDC, repeats: false)
                let defeatRequest = UNNotificationRequest(
                    identifier: defeatNotificationId(for: task),
                    content: defeatContent,
                    trigger: defeatTrigger
                )
                center.add(defeatRequest, withCompletionHandler: nil)
            }
        }
    }

    /// Schedules a one-shot 20:00 notification for today warning the streak is at risk.
    /// Call at day reset. Safe to call multiple times — cancels previous before scheduling.
    static func scheduleStreakWarning(streak: Int) {
        let enabled = UserDefaults.standard.object(forKey: "notif_streak_warning") as? Bool ?? true
        guard enabled, streak > 0 else { return }

        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["streak_warning_today"])

        var dc = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        dc.hour = 20
        dc.minute = 0
        dc.second = 0
        guard let fireDate = Calendar.current.date(from: dc), fireDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "🔥 Your streak is at risk!"
        content.body  = "\(streak)-day streak on the line — don't let the monsters win today."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: false)
        let request = UNNotificationRequest(identifier: "streak_warning_today",
                                            content: content,
                                            trigger: trigger)
        center.add(request, withCompletionHandler: nil)
    }

    /// Cancels today's streak-at-risk notification (call when the day is won).
    static func cancelStreakWarning() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["streak_warning_today"])
    }

    /// Cancel today's defeat notification when the user wins (completes the task before deadline).
    static func cancelDefeatNotification(for task: MonsterTask) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [defeatNotificationId(for: task)])
    }

    // MARK: - Private

    private static func defeatNotificationId(for task: MonsterTask) -> String {
        "\(task.notifId)-defeat-today"
    }

    private static func warningBody(label: String) -> String {
        switch label {
        case "3h":    return "3 hours left — stay focused, don't lose this battle!"
        case "30min": return "30 minutes left — prepare your attack!"
        case "5min":  return "5 minutes left — FINAL WARNING! ⚠️"
        default:      return "Deadline approaching!"
        }
    }
}
