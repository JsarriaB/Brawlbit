import SwiftData
import Foundation

@Model
final class Battle {
    var taskName: String
    var monsterType: String
    var result: BattleResult
    var completedAt: Date?
    var deadline: Date

    init(taskName: String, monsterType: String, deadline: Date) {
        self.taskName = taskName
        self.monsterType = monsterType
        self.result = .pending
        self.deadline = deadline
    }
}

enum BattleResult: String, Codable {
    case pending, victory, defeat
}
