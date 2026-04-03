import SwiftUI
import SwiftData
import Combine

struct StatsView: View {
    @Query private var heroes: [Hero]
    @Query private var dayRecords: [DayRecord]
    @Query private var unlocked: [UnlockedAchievement]
    @Query private var goals: [Goal90]

    var hero: Hero? { heroes.first }
    var goal: Goal90? { goals.first }

    // Hero sprite animation
    @State private var heroFrame: Int = 0
    private let animTimer = Timer.publish(every: 0.12, on: .main, in: .common).autoconnect()

    // MARK: - Computed stats

    private var allBattles: [Battle] { dayRecords.flatMap { $0.battles } }
    private var totalVictories: Int { allBattles.filter { $0.result == .victory }.count }
    private var totalDefeats: Int { allBattles.filter { $0.result == .defeat }.count }
    private var wonDays: Int { dayRecords.filter { $0.dayWon }.count }
    private var winRate: Double {
        guard !dayRecords.isEmpty else { return 0 }
        return Double(wonDays) / Double(dayRecords.count) * 100
    }
    private var taskHitRate: Double {
        // Average % of tasks completed per day
        guard !dayRecords.isEmpty else { return 0 }
        let avg = dayRecords.map { r -> Double in
            guard r.battles.count > 0 else { return 0 }
            return Double(r.victoriesCount) / Double(r.battles.count) * 100
        }.reduce(0, +) / Double(dayRecords.count)
        return avg
    }
    private var vdRatio: String {
        guard totalDefeats > 0 else { return totalVictories > 0 ? "∞" : "-" }
        let r = Double(totalVictories) / Double(totalDefeats)
        return String(format: "%.1f", r)
    }
    private var currentStreak: Int {
        var s = 0
        for r in dayRecords.sorted(by: { $0.date > $1.date }) {
            if r.dayWon { s += 1 } else { break }
        }
        return s
    }

    // Best/worst task (by win/loss count across all battles)
    private var taskStats: [(name: String, wins: Int, losses: Int)] {
        let grouped = Dictionary(grouping: allBattles.filter { $0.result != .pending },
                                 by: { $0.taskName })
        return grouped.map { (name: $0.key,
                              wins: $0.value.filter { $0.result == .victory }.count,
                              losses: $0.value.filter { $0.result == .defeat }.count) }
    }
    private var bestTask: (name: String, wins: Int)? {
        taskStats
            .sorted { a, b in a.wins != b.wins ? a.wins > b.wins : a.name < b.name }
            .first
            .map { ($0.name, $0.wins) }
    }
    private var worstTask: (name: String, losses: Int)? {
        taskStats
            .filter { $0.losses > 0 }
            .sorted { a, b in a.losses != b.losses ? a.losses > b.losses : a.name < b.name }
            .first
            .map { ($0.name, $0.losses) }
    }

    private var unlockedIds: Set<String> { Set(unlocked.map { $0.achievementId }) }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    if let hero {
                        profileCard(hero: hero)
                        shieldOrbsRow(hero: hero)
                        statsGrid
                        taskHighlights
                    }
                    achievementsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .onReceive(animTimer) { _ in
            guard let hero else { return }
            let frames = hero.heroClass.idleFrames
            heroFrame = (heroFrame + 1) % frames.count
        }
    }

    // MARK: - Profile card

    private func profileCard(hero: Hero) -> some View {
        let frames = hero.heroClass.idleFrames
        let pts = hero.points
        let lvl = AchievementService.level(for: pts)
        let xp = AchievementService.xpInCurrentLevel(for: pts)
        let xpMax = AchievementService.xpPerLevel

        return HStack(spacing: 18) {
            // Animated hero
            Image(frames[heroFrame])
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)

            VStack(alignment: .leading, spacing: 8) {
                Text(hero.name)
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Text("LVL \(lvl)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.orange)
                        .cornerRadius(6)

                    Text(hero.heroClass.displayName)
                        .font(.system(size: 12))
                        .foregroundColor(Color(white: 0.45))
                }

                // XP bar
                VStack(alignment: .leading, spacing: 3) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(white: 0.18))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.orange)
                                .frame(width: geo.size.width * AchievementService.xpProgress(for: pts),
                                       height: 6)
                        }
                    }
                    .frame(height: 6)

                    Text("\(xp) / \(xpMax) XP")
                        .font(.system(size: 10))
                        .foregroundColor(Color(white: 0.35))
                }
            }
            Spacer()
        }
        .padding(18)
        .background(Color(white: 0.12))
        .cornerRadius(16)
    }

    // MARK: - Shield orbs

    private func shieldOrbsRow(hero: Hero) -> some View {
        HStack(spacing: 10) {
            Text("SHIELD ORBS")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(white: 0.4))
                .tracking(1)
            Spacer()
            HStack(spacing: 6) {
                ForEach(0..<3) { i in
                    Image("+")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .opacity(i < hero.shieldOrbs ? 1.0 : 0.15)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(white: 0.12))
        .cornerRadius(12)
    }

    // MARK: - Stats grid

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(value: "\(totalVictories)",
                     label: "Monsters defeated",
                     icon: "bolt.fill", color: .orange)
            StatCard(value: "\(wonDays)",
                     label: "Days won",
                     icon: "calendar.badge.checkmark", color: .green)
            StatCard(value: "\(currentStreak)",
                     label: "Current streak",
                     icon: "flame.fill", color: .red)
            StatCard(value: String(format: "%.0f%%", winRate),
                     label: "Day win rate",
                     icon: "chart.pie.fill", color: .blue)
            StatCard(value: vdRatio,
                     label: "Victory / defeat ratio",
                     icon: "arrow.left.arrow.right", color: .purple)
            StatCard(value: String(format: "%.0f%%", taskHitRate),
                     label: "Task hit rate per day",
                     icon: "target", color: .cyan)
        }
    }

    // MARK: - Best / Worst task

    @ViewBuilder
    private var taskHighlights: some View {
        if bestTask != nil || worstTask != nil {
            VStack(spacing: 10) {
                if let best = bestTask {
                    TaskHighlightRow(title: "Best task",
                                     taskName: best.name,
                                     detail: "\(best.wins) victories",
                                     iconColor: .green,
                                     icon: "hand.thumbsup.fill")
                }
                if let worst = worstTask {
                    TaskHighlightRow(title: "Hardest task",
                                     taskName: worst.name,
                                     detail: "\(worst.losses) defeats",
                                     iconColor: .red,
                                     icon: "hand.thumbsdown.fill")
                }
            }
        }
    }

    // MARK: - Achievements

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("ACHIEVEMENTS")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.orange)
                    .tracking(1)
                Spacer()
                Text("\(unlockedIds.count)/\(AchievementCatalog.all.count)")
                    .font(.system(size: 11))
                    .foregroundColor(Color(white: 0.35))
            }

            // Unlocked first, then locked
            let sorted = AchievementCatalog.all.sorted { a, b in
                let aU = unlockedIds.contains(a.id)
                let bU = unlockedIds.contains(b.id)
                if aU != bU { return aU }
                return a.points > b.points
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(sorted) { def in
                    AchievementCard(def: def, isUnlocked: unlockedIds.contains(def.id),
                                    unlockedAt: unlocked.first { $0.achievementId == def.id }?.unlockedAt)
                }
            }
        }
    }
}

// MARK: - Stat Card

private struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 26, weight: .black))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color(white: 0.4))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(white: 0.12))
        .cornerRadius(14)
    }
}

// MARK: - Task Highlight Row

private struct TaskHighlightRow: View {
    let title: String
    let taskName: String
    let detail: String
    let iconColor: Color
    let icon: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
                .frame(width: 36, height: 36)
                .background(iconColor.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(white: 0.4))
                Text(taskName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            }
            Spacer()
            Text(detail)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(iconColor)
        }
        .padding(14)
        .background(Color(white: 0.12))
        .cornerRadius(14)
    }
}

// MARK: - Achievement Card

private struct AchievementCard: View {
    let def: AchievementDef
    let isUnlocked: Bool
    let unlockedAt: Date?

    private var tierColor: Color {
        switch def.difficulty {
        case .easy:   return Color(red: 0.8, green: 0.55, blue: 0.25)  // bronze
        case .medium: return Color(red: 0.75, green: 0.77, blue: 0.85) // silver
        case .hard:   return Color(red: 1.0, green: 0.82, blue: 0.1)   // gold
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? tierColor.opacity(0.18) : Color(white: 0.1))
                    .frame(width: 52, height: 52)
                Image(systemName: isUnlocked ? def.icon : "lock.fill")
                    .font(.system(size: 22))
                    .foregroundColor(isUnlocked ? tierColor : Color(white: 0.22))
            }

            VStack(spacing: 3) {
                Text(def.title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(isUnlocked ? .white : Color(white: 0.3))
                    .multilineTextAlignment(.center)
                Text(isUnlocked ? "+\(def.points) pts" : def.desc)
                    .font(.system(size: 10))
                    .foregroundColor(isUnlocked ? tierColor : Color(white: 0.25))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(isUnlocked ? Color(white: 0.13) : Color(white: 0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isUnlocked ? tierColor.opacity(0.4) : Color.clear, lineWidth: 1)
        )
        .cornerRadius(14)
    }
}
