import Foundation
import WidgetKit

enum WidgetWriter {
    static func write(tasks: [MonsterTask], hero: Hero?) {
        guard let hero else { return }
        let cal = Calendar.current
        let rawWeekday = cal.component(.weekday, from: Date())
        let todayIndex = (rawWeekday - 2 + 7) % 7

        let todayTasks = tasks
            .filter { $0.daysOfWeek.isEmpty || $0.daysOfWeek.contains(todayIndex) }
            .sorted { ($0.deadlineHour * 60 + $0.deadlineMinute) < ($1.deadlineHour * 60 + $1.deadlineMinute) }
            .map { t in
                WidgetTaskInfo(
                    id: t.notifId,
                    taskName: t.taskName,
                    monsterEmoji: t.monsterType.widgetEmoji,
                    deadlineHour: t.deadlineHour,
                    deadlineMinute: t.deadlineMinute,
                    isCompleted: t.isCompleted,
                    isActive: t.isActive
                )
            }

        let data = WidgetData(
            heroName: hero.name,
            heroHP: hero.hp,
            heroPoints: hero.points,
            todayTasks: todayTasks,
            updatedAt: Date()
        )

        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults(suiteName: widgetSuiteName)?.set(encoded, forKey: widgetUDKey)
        }

        WidgetCenter.shared.reloadTimelines(ofKind: "NextBattleWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "WarStatusWidget")
    }
}
