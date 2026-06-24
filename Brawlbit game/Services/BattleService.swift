import Foundation

enum BattleService {
    /// Returns .victory only if marked done at or before the deadline.
    static func resolve(markedDoneAt: Date?, deadline: Date) -> BattleResult {
        guard let markedAt = markedDoneAt, markedAt <= deadline else {
            return .defeat
        }
        return .victory
    }

    /// Day is won if at least 50% of battles are victories (ties go to the player).
    static func isDayWon(victories: Int, total: Int) -> Bool {
        guard total > 0 else { return false }
        return Double(victories) / Double(total) >= 0.5
    }

    struct BattleReward {
        let points: Int
        let coins: Int
        enum Tier { case normal, lucky, epic }
        let tier: Tier
    }

    /// Variable reward roll — 75% normal, 20% lucky, 5% epic.
    static func rollReward() -> BattleReward {
        let roll = Int.random(in: 1...100)
        switch roll {
        case 1...5:  return BattleReward(points: 25, coins: 15, tier: .epic)
        case 6...25: return BattleReward(points: 15, coins: 7,  tier: .lucky)
        default:     return BattleReward(points: 10, coins: 3,  tier: .normal)
        }
    }
}
