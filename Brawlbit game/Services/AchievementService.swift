import SwiftData
import Foundation

enum AchievementService {

    // MARK: - Level helpers

    static func level(for points: Int) -> Int {
        max(1, points / 200 + 1)
    }

    /// 0.0–1.0 progress towards next level
    static func xpProgress(for points: Int) -> Double {
        Double(points % 200) / 200.0
    }

    static func xpInCurrentLevel(for points: Int) -> Int { points % 200 }
    static let xpPerLevel = 200

    // MARK: - Check & unlock

    /// Evaluates all achievements and unlocks those newly earned.
    /// Awards bonus points to the hero for each new unlock.
    /// Returns the IDs of newly unlocked achievements.
    @discardableResult
    static func checkAll(
        hero: Hero,
        dayRecords: [DayRecord],
        unlocked: [UnlockedAchievement],
        hasTwoRoutines: Bool,
        goal90Days: Int,
        context: ModelContext
    ) -> [String] {
        let unlockedIds = Set(unlocked.map { $0.achievementId })
        var newIds: [String] = []

        func unlock(_ id: String, bonusPoints: Int) {
            guard !unlockedIds.contains(id), !newIds.contains(id) else { return }
            context.insert(UnlockedAchievement(achievementId: id))
            hero.points += bonusPoints
            newIds.append(id)
        }

        // ── Computed values ────────────────────────────────────────────────
        let allBattles   = dayRecords.flatMap { $0.battles }
        let totalVicts   = allBattles.filter { $0.result == .victory }.count
        let wonDays      = dayRecords.filter { $0.dayWon }
        let streak       = currentWinStreak(dayRecords)
        let losesBefore  = lossStreakBeforeLast(dayRecords)
        let currentLvl   = level(for: hero.points)

        // ── First steps ────────────────────────────────────────────────────
        if totalVicts >= 1                          { unlock("first_task",    bonusPoints: 20) }
        if wonDays.count >= 7                       { unlock("first_week",    bonusPoints: 20) }
        if hasTwoRoutines                           { unlock("two_routines",  bonusPoints: 20) }
        if hero.points >= 500                       { unlock("points_500",    bonusPoints: 20) }
        if hero.points >= 2000                      { unlock("points_2000",   bonusPoints: 60) }

        // ── Perfect day ────────────────────────────────────────────────────
        let hasPerfect = dayRecords.contains { r in
            !r.battles.isEmpty && r.battles.allSatisfy { $0.result == .victory }
        }
        if hasPerfect                               { unlock("perfect_day",   bonusPoints: 20) }

        // ── Streaks ────────────────────────────────────────────────────────
        if streak >= 3                              { unlock("streak_3",      bonusPoints: 25) }
        if streak >= 7                              { unlock("streak_7",      bonusPoints: 50) }
        if streak >= 30                             { unlock("streak_30",     bonusPoints: 100) }

        let perfectStreak = consecutivePerfectDays(dayRecords)
        if perfectStreak >= 3                       { unlock("clean_3",       bonusPoints: 40) }

        // ── Counts ────────────────────────────────────────────────────────
        if totalVicts >= 50                         { unlock("tasks_50",      bonusPoints: 30) }
        if totalVicts >= 200                        { unlock("tasks_200",     bonusPoints: 60) }
        if wonDays.count >= 30                      { unlock("days_30",       bonusPoints: 30) }

        // ── Goal progress ──────────────────────────────────────────────────
        if goal90Days >= 45                         { unlock("half_way",      bonusPoints: 50) }
        if goal90Days >= 90                         { unlock("days_90",       bonusPoints: 100) }

        // ── Special ────────────────────────────────────────────────────────
        // Iron Will: won a day that had 5 or more tasks
        let hasNoDamage = dayRecords.contains { r in
            r.dayWon && r.battles.count >= 5
        }
        if hasNoDamage                              { unlock("no_damage",     bonusPoints: 50) }

        // 7-task perfect day
        let hasSeven = dayRecords.contains { r in
            r.battles.count >= 7 && r.battles.allSatisfy { $0.result == .victory }
        }
        if hasSeven                                 { unlock("seven_tasks",   bonusPoints: 50) }

        // Comeback: most recent day won AND ≥3 losses before it
        if losesBefore >= 3 && dayRecords.sorted(by: { $0.date > $1.date }).first?.dayWon == true {
            unlock("comeback", bonusPoints: 35)
        }

        // ── Levels ─────────────────────────────────────────────────────────
        if currentLvl >= 5                          { unlock("level_5",       bonusPoints: 20) }
        if currentLvl >= 10                         { unlock("level_10",      bonusPoints: 40) }
        if currentLvl >= 20                         { unlock("level_20",      bonusPoints: 80) }

        if !newIds.isEmpty { try? context.save() }
        return newIds
    }

    // MARK: - Private helpers

    static func currentWinStreak(_ records: [DayRecord]) -> Int {
        var streak = 0
        for r in records.sorted(by: { $0.date > $1.date }) {
            if r.dayWon { streak += 1 } else { break }
        }
        return streak
    }

    /// Consecutive losses immediately before the most recent record.
    private static func lossStreakBeforeLast(_ records: [DayRecord]) -> Int {
        let sorted = records.sorted(by: { $0.date > $1.date })
        guard sorted.count >= 2 else { return 0 }
        var streak = 0
        for r in sorted.dropFirst() {
            if !r.dayWon { streak += 1 } else { break }
        }
        return streak
    }

    private static func consecutivePerfectDays(_ records: [DayRecord]) -> Int {
        var count = 0
        for r in records.sorted(by: { $0.date > $1.date }) {
            let perfect = !r.battles.isEmpty && r.battles.allSatisfy { $0.result == .victory }
            if perfect { count += 1 } else { break }
        }
        return count
    }
}
