import Foundation

let widgetSuiteName = "group.com.jorgesarria.Brawlbit-game"
let widgetUDKey     = "brawlbit_widget_data"

struct WidgetTaskInfo: Codable {
    let id: String           // notifId — stable unique ID, no colisiones
    let taskName: String
    let monsterEmoji: String
    let deadlineHour: Int
    let deadlineMinute: Int
    let isCompleted: Bool
    let isActive: Bool

    var deadlineFormatted: String { String(format: "%02d:%02d", deadlineHour, deadlineMinute) }
}

struct WidgetData: Codable {
    let heroName: String
    let heroHP: Double       // 0.0–1.0
    let heroPoints: Int
    let todayTasks: [WidgetTaskInfo]
    let updatedAt: Date
}

enum WidgetDataProvider {
    static func read() -> WidgetData? {
        guard let raw = UserDefaults(suiteName: widgetSuiteName)?.data(forKey: widgetUDKey) else { return nil }
        return try? JSONDecoder().decode(WidgetData.self, from: raw)
    }
}
