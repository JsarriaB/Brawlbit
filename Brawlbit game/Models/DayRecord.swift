import SwiftData
import Foundation

@Model
final class DayRecord {
    var date: Date
    var battles: [Battle]
    var dayWon: Bool

    init(date: Date, battles: [Battle]) {
        self.date = date
        self.battles = battles
        self.dayWon = false
    }

    var victoriesCount: Int {
        battles.filter { $0.result == .victory }.count
    }

    var defeatsCount: Int {
        battles.filter { $0.result == .defeat }.count
    }

    var totalResolved: Int {
        battles.filter { $0.result != .pending }.count
    }
}
