import SwiftData
import Foundation

@Model
final class MonsterTask {
    var taskName: String
    var monsterType: MonsterType
    var deadlineHour: Int
    var deadlineMinute: Int
    var isActive: Bool
    var isCompleted: Bool
    var completedAt: Date?
    var order: Int
    var routineIndex: Int   // 0 = Routine 1, 1 = Routine 2
    var daysOfWeek: [Int]   // 0=Mon … 6=Sun; empty = every day
    var notifId: String = UUID().uuidString  // stable unique ID for notification identifiers

    init(taskName: String, monsterType: MonsterType, deadlineHour: Int, deadlineMinute: Int, order: Int,
         routineIndex: Int = 0, daysOfWeek: [Int] = []) {
        self.taskName = taskName
        self.monsterType = monsterType
        self.deadlineHour = deadlineHour
        self.deadlineMinute = deadlineMinute
        self.isActive = true
        self.isCompleted = false
        self.completedAt = nil
        self.order = order
        self.routineIndex = routineIndex
        self.daysOfWeek = daysOfWeek
    }

    var deadlineToday: Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = deadlineHour
        components.minute = deadlineMinute
        components.second = 0
        return calendar.date(from: components) ?? Date()
    }

    var deadlineFormatted: String {
        String(format: "%02d:%02d", deadlineHour, deadlineMinute)
    }
}

enum MonsterType: String, Codable, CaseIterable {
    case demon, dragon, jinn, lizard, medusa, smallDragon

    var displayName: String {
        switch self {
        case .demon: return "Demon"
        case .dragon: return "Dragon"
        case .jinn: return "Jinn"
        case .lizard: return "Lizard"
        case .medusa: return "Medusa"
        case .smallDragon: return "Small Dragon"
        }
    }

    var assetPrefix: String {
        switch self {
        case .demon: return "demon"
        case .dragon: return "dragon"
        case .jinn: return "jinn_animation"
        case .lizard: return "lizard"
        case .medusa: return "medusa"
        case .smallDragon: return "small_dragon"
        }
    }

    var previewAsset: String {
        switch self {
        case .demon: return "Demon/demon/Idle1"
        case .dragon: return "Dragon/dragon/Idle1"
        case .jinn: return "Jinn/jinn_animation/Idle1"
        case .lizard: return "Lizard/lizard/Idle1"
        case .medusa: return "Medusa/medusa/Idle1"
        case .smallDragon: return "SmallDragon/small_dragon/Idle1"
        }
    }

    var idleFrames: [String] {
        switch self {
        case .demon:       return (1...3).map { "Demon/demon/Idle\($0)" }
        case .dragon:      return (1...3).map { "Dragon/dragon/Idle\($0)" }
        case .jinn:        return (1...3).map { "Jinn/jinn_animation/Idle\($0)" }
        case .lizard:      return (1...3).map { "Lizard/lizard/Idle\($0)" }
        case .medusa:      return (1...3).map { "Medusa/medusa/Idle\($0)" }
        case .smallDragon: return (1...3).map { "SmallDragon/small_dragon/Idle\($0)" }
        }
    }

    var attackFrames: [String] {
        switch self {
        case .demon:       return (1...4).map { "Demon/demon/Attack\($0)" }
        case .dragon:      return (1...4).map { "Dragon/dragon/Attack\($0)" }
        case .jinn:        return (1...4).map { "Jinn/jinn_animation/Attack\($0)" }
        case .lizard:      return (1...5).map { "Lizard/lizard/Attack\($0)" }
        case .medusa:      return (1...6).map { "Medusa/medusa/Attack\($0)" }
        case .smallDragon: return (1...3).map { "SmallDragon/small_dragon/Attack\($0)" }
        }
    }

    // Scene display calibration (height + vertical offset)
    var sceneHeight: CGFloat {
        switch self {
        case .demon:       return 280
        case .dragon:      return 280
        case .jinn:        return 140
        case .lizard:      return 320
        case .medusa:      return 140
        case .smallDragon: return 140
        }
    }

    var sceneYOffset: CGFloat {
        switch self {
        case .demon:       return 40
        case .dragon:      return 40
        case .jinn:        return 15
        case .lizard:      return 58
        case .medusa:      return 21
        case .smallDragon: return 40
        }
    }

    var deathFrames: [String] {
        switch self {
        case .demon:       return (1...6).map { "Demon/demon/Death\($0)" }
        case .dragon:      return (1...5).map { "Dragon/dragon/Death\($0)" }
        case .jinn:        return (1...4).map { "Jinn/jinn_animation/Death\($0)" }
        case .lizard:      return (1...6).map { "Lizard/lizard/Death\($0)" }
        case .medusa:      return (1...6).map { "Medusa/medusa/Death\($0)" }
        case .smallDragon: return (1...4).map { "SmallDragon/small_dragon/Death\($0)" }
        }
    }

    // Non-combat ambient animation (walk / idle for jinn)
    var walkFrames: [String] {
        switch self {
        case .demon:       return (1...6).map { "Demon/demon/Walk\($0)" }
        case .dragon:      return (1...5).map { "Dragon/dragon/Walk\($0)" }
        case .jinn:        return idleFrames   // jinn has no walk
        case .lizard:      return (1...6).map { "Lizard/lizard/Walk\($0)" }
        case .medusa:      return (1...4).map { "Medusa/medusa/Walk\($0)" }
        case .smallDragon: return (1...4).map { "SmallDragon/small_dragon/Walk\($0)" }
        }
    }
}
