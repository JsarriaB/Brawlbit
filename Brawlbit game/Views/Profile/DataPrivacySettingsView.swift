import SwiftUI
import SwiftData
import UserNotifications

struct DataPrivacySettingsView: View {
    @Query private var heroes: [Hero]
    @Query private var tasks: [MonsterTask]
    @Query private var dayRecords: [DayRecord]
    @Query private var battles: [Battle]
    @Query private var achievements: [UnlockedAchievement]
    @Query private var goals: [Goal90]
    @Environment(\.modelContext) private var modelContext

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var showDeleteConfirm = false
    @State private var showExportSheet = false
    @State private var showDataInfo = false
    @State private var exportURL: URL? = nil

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    sectionHeader("YOUR DATA")

                    VStack(spacing: 0) {
                        rowLink(
                            icon: "info.circle.fill", iconColor: .blue,
                            title: "What this app stores",
                            subtitle: "No accounts, no servers"
                        ) {
                            showDataInfo = true
                        }

                        rowDivider()

                        rowLink(
                            icon: "square.and.arrow.up.fill", iconColor: .green,
                            title: "Export my data",
                            subtitle: "Download a JSON file with your full history"
                        ) {
                            exportData()
                        }

                        rowDivider()

                        Button {
                            showDeleteConfirm = true
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 28, height: 28)
                                    .background(Color.red)
                                    .cornerRadius(7)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Delete all my data")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.red)
                                    Text("Permanently removes all progress and tasks")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color(white: 0.4))
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.plain)
                    }
                    .background(Color(white: 0.12))
                    .cornerRadius(14)
                    .padding(.horizontal, 24)
                }
                .padding(.top, 24)
                .padding(.bottom, 60)
            }
        }
        .navigationTitle("Data & Privacy")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .confirmationDialog(
            "Delete all data?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete everything", role: .destructive) { deleteAll() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This permanently deletes your hero, all tasks, battle history and achievements. This cannot be undone.")
        }
        .sheet(isPresented: $showDataInfo) {
            DataInfoView()
        }
        .sheet(isPresented: $showExportSheet, onDismiss: { exportURL = nil }) {
            if let url = exportURL {
                ShareSheet(items: [url])
            }
        }
    }

    // MARK: - Delete all

    private func deleteAll() {
        for h in heroes       { modelContext.delete(h) }
        for t in tasks        { modelContext.delete(t) }
        for b in battles      { modelContext.delete(b) }
        for d in dayRecords   { modelContext.delete(d) }
        for a in achievements { modelContext.delete(a) }
        for g in goals        { modelContext.delete(g) }
        try? modelContext.save()

        let keys = [
            "hasCompletedOnboarding", "lastResetDate", "lastSummaryDate",
            "notif_battle_start", "notif_3h", "notif_30min", "notif_5min",
            "notif_defeat", "notif_streak_warning",
            "routine1Name", "routine2Name", "reduceAnimations"
        ]
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        hasCompletedOnboarding = false
    }

    // MARK: - Export

    private func exportData() {
        var dict: [String: Any] = [:]
        let iso = ISO8601DateFormatter()

        if let hero = heroes.first {
            dict["hero"] = [
                "name":      hero.name,
                "class":     hero.heroClass.rawValue,
                "points":    hero.points,
                "coins":     hero.coins,
                "level":     AchievementService.level(for: hero.points),
                "createdAt": iso.string(from: hero.createdAt)
            ] as [String: Any]
        }

        dict["tasks"] = tasks.map { t in
            [
                "name":     t.taskName,
                "monster":  t.monsterType.rawValue,
                "deadline": "\(t.deadlineHour):\(String(format: "%02d", t.deadlineMinute))",
                "routine":  t.routineIndex,
                "days":     t.daysOfWeek
            ] as [String: Any]
        }

        dict["dayRecords"] = dayRecords.map { r in
            [
                "date":      iso.string(from: r.date),
                "won":       r.dayWon,
                "victories": r.victoriesCount,
                "defeats":   r.defeatsCount,
                "battles": r.battles.map { b in
                    [
                        "task":        b.taskName,
                        "result":      b.result.rawValue,
                        "deadline":    iso.string(from: b.deadline),
                        "completedAt": b.completedAt.map { iso.string(from: $0) } ?? ""
                    ] as [String: Any]
                }
            ] as [String: Any]
        }

        dict["achievements"] = achievements.map { a in
            [
                "id":         a.achievementId,
                "unlockedAt": iso.string(from: a.unlockedAt)
            ] as [String: Any]
        }

        dict["goals"] = goals.map { g in
            [
                "text":          g.goalText,
                "daysCompleted": g.daysCompleted,
                "isCompleted":   g.isCompleted,
                "startDate":     iso.string(from: g.startDate)
            ] as [String: Any]
        }

        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) else { return }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("brawlbit_data.json")
        try? data.write(to: url)
        exportURL = url
        showExportSheet = true
    }

    // MARK: - Helpers

    @ViewBuilder
    private func rowLink(icon: String, iconColor: Color, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(iconColor)
                    .cornerRadius(7)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(Color(white: 0.4))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(white: 0.3))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func rowDivider() -> some View {
        Rectangle()
            .fill(Color(white: 1, opacity: 0.06))
            .frame(height: 1)
            .padding(.leading, 58)
    }

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.orange)
            .tracking(1)
            .padding(.horizontal, 24)
            .padding(.bottom, 14)
    }
}

// MARK: - ShareSheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uvc: UIActivityViewController, context: Context) {}
}
