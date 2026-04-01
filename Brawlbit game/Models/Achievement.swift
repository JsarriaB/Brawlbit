import SwiftData
import Foundation

// MARK: - Static achievement definitions

struct AchievementDef: Identifiable {
    let id: String
    let title: String
    let desc: String
    let icon: String        // SF Symbol
    let points: Int
    let difficulty: Difficulty

    enum Difficulty {
        case easy, medium, hard
    }
}

struct AchievementCatalog {
    static let all: [AchievementDef] = [
        // ── First steps ──────────────────────────────────────────────────
        AchievementDef(id: "first_task",    title: "First Blood",
                       desc: "Complete your first task",
                       icon: "bolt.fill", points: 20, difficulty: .easy),

        AchievementDef(id: "perfect_day",   title: "Perfect Day",
                       desc: "Complete all tasks in a day without failing any",
                       icon: "star.fill", points: 20, difficulty: .easy),

        AchievementDef(id: "first_week",    title: "First Week",
                       desc: "Win 7 days in total",
                       icon: "calendar.badge.checkmark", points: 20, difficulty: .easy),

        AchievementDef(id: "two_routines",  title: "Double Life",
                       desc: "Create 2 task routines",
                       icon: "rectangle.split.2x1.fill", points: 20, difficulty: .easy),

        AchievementDef(id: "points_500",    title: "Hoarder",
                       desc: "Earn 500 points in total",
                       icon: "star.circle.fill", points: 20, difficulty: .easy),

        // ── Streaks ───────────────────────────────────────────────────────
        AchievementDef(id: "streak_3",      title: "Hat Trick",
                       desc: "Win 3 days in a row",
                       icon: "flame.fill", points: 25, difficulty: .easy),

        AchievementDef(id: "streak_7",      title: "On Fire",
                       desc: "Win 7 days in a row",
                       icon: "flame.fill", points: 50, difficulty: .medium),

        AchievementDef(id: "streak_30",     title: "Unstoppable",
                       desc: "Win 30 days in a row",
                       icon: "bolt.fill", points: 100, difficulty: .hard),

        AchievementDef(id: "clean_3",       title: "Triple Threat",
                       desc: "3 perfect days in a row (no failed tasks)",
                       icon: "checkmark.seal.fill", points: 40, difficulty: .medium),

        // ── Task & day counts ─────────────────────────────────────────────
        AchievementDef(id: "tasks_50",      title: "Monster Hunter",
                       desc: "Defeat 50 monsters in total",
                       icon: "shield.fill", points: 30, difficulty: .medium),

        AchievementDef(id: "tasks_200",     title: "Exterminator",
                       desc: "Defeat 200 monsters in total",
                       icon: "crown.fill", points: 60, difficulty: .hard),

        AchievementDef(id: "days_30",       title: "Veteran",
                       desc: "Win 30 days in total",
                       icon: "medal.fill", points: 30, difficulty: .medium),

        AchievementDef(id: "half_way",      title: "Halfway There",
                       desc: "Complete 45 of the 90-day goal",
                       icon: "chart.line.uptrend.xyaxis", points: 50, difficulty: .medium),

        AchievementDef(id: "days_90",       title: "The Summit",
                       desc: "Complete the full 90-day goal",
                       icon: "mountain.2.fill", points: 100, difficulty: .hard),

        // ── Special conditions ─────────────────────────────────────────────
        AchievementDef(id: "no_damage",     title: "Iron Will",
                       desc: "Win a day with 5 or more tasks",
                       icon: "shield.fill", points: 50, difficulty: .hard),

        AchievementDef(id: "seven_tasks",   title: "Seven Sins",
                       desc: "Win a day with 7 tasks without failing any",
                       icon: "7.circle.fill", points: 50, difficulty: .medium),

        AchievementDef(id: "comeback",      title: "Comeback",
                       desc: "Win a day after losing 3 in a row",
                       icon: "arrow.counterclockwise.circle.fill", points: 35, difficulty: .medium),

        // ── Level milestones ──────────────────────────────────────────────
        AchievementDef(id: "level_5",       title: "Level 5",
                       desc: "Reach level 5",
                       icon: "5.circle.fill", points: 20, difficulty: .easy),

        AchievementDef(id: "level_10",      title: "Level 10",
                       desc: "Reach level 10",
                       icon: "10.circle.fill", points: 40, difficulty: .medium),

        AchievementDef(id: "level_20",      title: "Level 20",
                       desc: "Reach level 20",
                       icon: "20.circle.fill", points: 80, difficulty: .hard),

        // ── Points milestone ──────────────────────────────────────────────
        AchievementDef(id: "points_2000",   title: "Millionaire",
                       desc: "Earn 2000 points in total",
                       icon: "trophy.fill", points: 60, difficulty: .hard),
    ]

    static func def(id: String) -> AchievementDef? { all.first { $0.id == id } }
}

// MARK: - SwiftData model

@Model
final class UnlockedAchievement {
    var achievementId: String
    var unlockedAt: Date

    init(achievementId: String) {
        self.achievementId = achievementId
        self.unlockedAt = Date()
    }
}
