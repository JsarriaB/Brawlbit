import Foundation

enum BattleService {
    /// Returns .victory only if marked done at or before the deadline.
    static func resolve(markedDoneAt: Date?, deadline: Date) -> BattleResult {
        guard let markedAt = markedDoneAt, markedAt <= deadline else {
            return .defeat
        }
        return .victory
    }

    /// Day is won if strictly more than 50% of battles are victories.
    static func isDayWon(victories: Int, total: Int) -> Bool {
        guard total > 0 else { return false }
        return Double(victories) / Double(total) > 0.5
    }
}
