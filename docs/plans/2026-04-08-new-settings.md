# New Settings Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add 7 new settings/features to Brawlbit: reduce animations toggle, vacation mode (max 7 days), streak-at-risk notification, delete all data, data info screen, export data, and an "About" section.

**Architecture:** All features use existing patterns — @AppStorage for simple toggles, Hero SwiftData model for vacation state, new view files following the current style (dark bg, orange accents). ProfileView gets two new sections. No new dependencies.

**Tech Stack:** SwiftUI, SwiftData, @AppStorage, UNUserNotificationCenter, UIActivityViewController

---

## Task 1: Reduce Animations toggle

**Files:**
- Modify: `Brawlbit game/Views/Profile/GameModeSettingsView.swift`
- Modify: `Brawlbit game/Views/Today/TodayView.swift` (frame timers)

The toggle is stored in `@AppStorage("reduceAnimations")`. When active, the sprite frame timers stop ticking — hero and monster stay on frame 0 (still visible, just frozen). Battle transitions still play but skip multi-frame idle loops.

**Step 1: Add the AppStorage key and toggle card in GameModeSettingsView**

Add below the Hard mode card, before `Spacer(minLength: 40)`:

```swift
// In GameModeSettingsView body, add this property at top of struct:
@AppStorage("reduceAnimations") private var reduceAnimations: Bool = false

// Add after the hard modeCard call:
Divider()
    .background(Color(white: 0.2))
    .padding(.vertical, 8)

modeCard(
    selected: reduceAnimations,
    icon: "✨",
    title: "Reduce Animations",
    description: "Stops sprite idle loops. Characters stay still between battles. Useful for older devices or if you prefer a calmer look.",
    accentColor: .cyan
) {
    reduceAnimations.toggle()
}
```

**Step 2: Read TodayView's frame timer setup and stop it when reduceAnimations is true**

In `TodayView.swift`, find the `onReceive` that drives `heroFrame` and `monsterFrame`. Add a guard:

```swift
// Find the timer receiver for idle animation frames and wrap with:
.onReceive(frameTimer) { _ in
    guard !reduceAnimations else { return }
    // existing frame tick logic
}
```

Add `@AppStorage("reduceAnimations") private var reduceAnimations: Bool = false` at the top of TodayView's state properties.

**Step 3: Build and test**
- Toggle on → hero sprite freezes on first idle frame in TodayView
- Toggle off → animation resumes

---

## Task 2: Vacation Mode (max 7 days)

**Files:**
- Modify: `Brawlbit game/Models/Hero.swift`
- Modify: `Brawlbit game/Services/AppState.swift`
- Modify: `Brawlbit game/Views/Profile/GameModeSettingsView.swift`

When vacation is active, `resetTasksIfNewDay` resets tasks normally but does NOT create a DayRecord for that day. The streak in AchievementService is calculated from DayRecord entries, so no new record = streak neither grows nor breaks.

**Step 1: Add vacationEndDate to Hero model**

In `Hero.swift`, add one property inside the `@Model` class body (after `easyMode`):

```swift
var vacationEndDate: Date? = nil
```

SwiftData handles the migration automatically for optional properties with a default.

**Step 2: Modify resetTasksIfNewDay in AppState.swift to skip DayRecord creation on vacation days**

The current method resets tasks and saves. We need to add a vacation check. Find `resetTasksIfNewDay` and add at the very start of the method body, after the `guard today > lastReset` line:

```swift
// Check vacation — if active, reset tasks normally but skip day record
let onVacation: Bool
if let end = hero?.vacationEndDate, today <= end {
    onVacation = true
} else {
    onVacation = true  // will be set to false below
    // Clear expired vacation
    if hero?.vacationEndDate != nil {
        hero?.vacationEndDate = nil
    }
    onVacation = false  // compiler trick — replace both lines with:
}
```

Actually, write it cleanly:

```swift
// After `guard today > lastReset else { return }`, add:
let onVacation: Bool = {
    guard let end = hero?.vacationEndDate else { return false }
    if today <= end { return true }
    hero?.vacationEndDate = nil   // expired, clear it
    return false
}()
```

Then find the part where `DayRecord` is created/saved (if it exists in this method) and wrap with `if !onVacation`. If DayRecord is created in TodayView instead, add an `AppState.onVacation` computed property:

```swift
// Add to AppState:
func isOnVacation(hero: Hero?) -> Bool {
    guard let end = hero?.vacationEndDate else { return false }
    return Calendar.current.startOfDay(for: Date()) <= Calendar.current.startOfDay(for: end)
}
```

**Step 3: Add Vacation Mode card in GameModeSettingsView**

Add after the Reduce Animations card. The card shows a stepper (1–7 days) or a button that activates vacation for 1-7 days. Use a sheet or inline stepper:

```swift
// Add state:
@State private var showVacationPicker = false
@State private var vacationDays: Int = 1

// Add card (after reduceAnimations card):
Divider()
    .background(Color(white: 0.2))
    .padding(.vertical, 8)

VStack(spacing: 0) {
    HStack(alignment: .top, spacing: 14) {
        Text("🏖️")
            .font(.system(size: 28))
            .frame(width: 40)
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Vacation Mode")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                if let end = hero.vacationEndDate,
                   Calendar.current.startOfDay(for: Date()) <= Calendar.current.startOfDay(for: end) {
                    Text("Active")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.cyan)
                }
            }
            Text("Pause your streak for up to 7 days. No wins or losses recorded while on vacation.")
                .font(.system(size: 13))
                .foregroundColor(Color(white: 0.5))
                .fixedSize(horizontal: false, vertical: true)

            if let end = hero.vacationEndDate,
               Calendar.current.startOfDay(for: Date()) <= Calendar.current.startOfDay(for: end) {
                // Active: show end date + cancel button
                let formatter: DateFormatter = {
                    let f = DateFormatter(); f.dateStyle = .medium; return f
                }()
                Text("Until \(formatter.string(from: end))")
                    .font(.system(size: 12))
                    .foregroundColor(.cyan)
                Button("Cancel vacation") {
                    hero.vacationEndDate = nil
                    try? modelContext.save()
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.red)
                .padding(.top, 4)
            } else {
                // Inactive: show stepper + activate button
                if showVacationPicker {
                    HStack(spacing: 12) {
                        Stepper("\(vacationDays) day\(vacationDays == 1 ? "" : "s")",
                                value: $vacationDays, in: 1...7)
                            .foregroundColor(.white)
                            .tint(.cyan)
                        Button("Activate") {
                            let end = Calendar.current.date(
                                byAdding: .day, value: vacationDays - 1,
                                to: Calendar.current.startOfDay(for: Date()))!
                            hero.vacationEndDate = end
                            try? modelContext.save()
                            showVacationPicker = false
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.cyan)
                    }
                    .padding(.top, 6)
                } else {
                    Button("Set vacation") {
                        showVacationPicker = true
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.cyan)
                    .padding(.top, 4)
                }
            }
        }
    }
    .padding(18)
    .background(RoundedRectangle(cornerRadius: 16).fill(Color(white: 0.10)))
    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(white: 0.15), lineWidth: 1))
}
```

**Step 4: Protect TodayView's checkIfDayComplete / defeat logic from running on vacation**

In `TodayView.swift`, find where `DayRecord` is created or `checkIfDayComplete` is called and add:

```swift
guard !appState.isOnVacation(hero: hero) else { return }
```

**Step 5: Test**
- Activate 2-day vacation → play through a day → no DayRecord created → streak unchanged
- Cancel vacation → next day resumes normally

---

## Task 3: Streak-at-risk notification

**Files:**
- Modify: `Brawlbit game/Services/NotificationService.swift`
- Modify: `Brawlbit game/Services/AppState.swift`
- Modify: `Brawlbit game/Views/Profile/NotificationsSettingsView.swift`

Schedule a one-shot daily notification at 20:00 (8 PM) that fires only if the user hasn't won the day yet. Since local notifications can't check runtime conditions, we schedule it each morning at reset time and cancel it in `checkIfDayComplete` when the day is won.

**Step 1: Add AppStorage key for the toggle**

In `NotificationsSettingsView.swift`, add:

```swift
@AppStorage("notif_streak_warning") private var notifStreakWarning = true
```

**Step 2: Add the row in NotificationsSettingsView**

After the "Defeat" row (before the iOS settings button), add:

```swift
rowDivider()
notifRow(
    icon: "flame.fill", iconColor: .yellow,
    title: "Streak at risk",
    subtitle: "Evening reminder if you haven't won the day yet",
    binding: $notifStreakWarning
)
```

**Step 3: Add scheduleStreakWarning to NotificationService**

Add a new static method at the bottom of `NotificationService` (before the closing `}`):

```swift
/// Schedules a one-shot 20:00 notification for today warning the streak is at risk.
/// Call at day reset. Cancel with cancelStreakWarning() when day is won.
static func scheduleStreakWarning(streak: Int) {
    let enabled = UserDefaults.standard.object(forKey: "notif_streak_warning") as? Bool ?? true
    guard enabled, streak > 0 else { return }

    let center = UNUserNotificationCenter.current()
    center.removePendingNotificationRequests(withIdentifiers: ["streak_warning_today"])

    var dc = Calendar.current.dateComponents([.year, .month, .day], from: Date())
    dc.hour = 20
    dc.minute = 0
    dc.second = 0
    guard let fireDate = Calendar.current.date(from: dc), fireDate > Date() else { return }

    let content = UNMutableNotificationContent()
    content.title = "🔥 Your streak is at risk!"
    content.body  = "\(streak)-day streak on the line — don't let the monsters win today."
    content.sound = .default

    let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: false)
    let request = UNNotificationRequest(identifier: "streak_warning_today", content: content, trigger: trigger)
    center.add(request, withCompletionHandler: nil)
}

static func cancelStreakWarning() {
    UNUserNotificationCenter.current()
        .removePendingNotificationRequests(withIdentifiers: ["streak_warning_today"])
}
```

**Step 4: Call scheduleStreakWarning at day reset**

In `AppState.resetTasksIfNewDay`, after the existing `NotificationService.scheduleAll(tasks: tasks)` call, add:

```swift
// Streak warning — needs DayRecord data, so caller must pass streak
// Instead, expose a method and call it from TodayView after reset
```

Actually, since AppState doesn't have access to DayRecord, call it from TodayView's `.onAppear`/reset trigger, passing the current streak:

```swift
// In TodayView, where resetTasksIfNewDay is called, add after:
let streak = AchievementService.currentWinStreak(dayRecords)
NotificationService.scheduleStreakWarning(streak: streak)
```

**Step 5: Cancel when day is won**

In `TodayView.checkIfDayComplete` (or wherever `dayWon` is determined to be true), add:

```swift
NotificationService.cancelStreakWarning()
```

**Step 6: Test**
- Reset → at 20:00 notification fires if day not won
- Win the day → notification is cancelled

---

## Task 4: Delete All Data

**Files:**
- Modify: `Brawlbit game/Views/Profile/ProfileView.swift`
- New: `Brawlbit game/Views/Profile/DataPrivacySettingsView.swift`

**Step 1: Create DataPrivacySettingsView.swift**

```swift
import SwiftUI
import SwiftData

struct DataPrivacySettingsView: View {
    @Query private var heroes: [Hero]
    @Query private var tasks: [MonsterTask]
    @Query private var dayRecords: [DayRecord]
    @Query private var battles: [Battle]
    @Query private var achievements: [UnlockedAchievement]
    @Query private var goals: [Goal90]
    @Environment(\.modelContext) private var modelContext

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
                        // What data
                        rowLink(icon: "info.circle.fill", iconColor: .blue,
                                title: "What data this app stores",
                                subtitle: "No accounts, no servers") {
                            showDataInfo = true
                        }
                        rowDivider()
                        // Export
                        rowLink(icon: "square.and.arrow.up.fill", iconColor: .green,
                                title: "Export my data",
                                subtitle: "Download a JSON file with everything") {
                            exportData()
                        }
                        rowDivider()
                        // Delete
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
        .sheet(isPresented: $showDataInfo) { DataInfoView() }
        .sheet(isPresented: $showExportSheet, onDismiss: { exportURL = nil }) {
            if let url = exportURL {
                ShareSheet(items: [url])
            }
        }
    }

    private func deleteAll() {
        for h in heroes { modelContext.delete(h) }
        for t in tasks { modelContext.delete(t) }
        for d in dayRecords { modelContext.delete(d) }
        for b in battles { modelContext.delete(b) }
        for a in achievements { modelContext.delete(a) }
        for g in goals { modelContext.delete(g) }
        try? modelContext.save()

        // Clear UserDefaults keys
        let keys = ["hasCompletedOnboarding","lastResetDate","lastSummaryDate",
                    "notif_battle_start","notif_3h","notif_30min","notif_5min",
                    "notif_defeat","notif_streak_warning","routine1Name","routine2Name",
                    "reduceAnimations"]
        keys.forEach { UserDefaults.standard.removeObject(forKey: $0) }

        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    private func exportData() {
        var dict: [String: Any] = [:]
        if let hero = heroes.first {
            dict["hero"] = ["name": hero.name,
                            "class": hero.heroClass.rawValue,
                            "points": hero.points,
                            "coins": hero.coins,
                            "level": AchievementService.level(for: hero.points),
                            "createdAt": ISO8601DateFormatter().string(from: hero.createdAt)]
        }
        dict["tasks"] = tasks.map { t in
            ["name": t.taskName,
             "monster": t.monsterType.rawValue,
             "deadline": "\(t.deadlineHour):\(String(format:"%02d",t.deadlineMinute))",
             "routine": t.routineIndex,
             "days": t.daysOfWeek] as [String: Any]
        }
        dict["dayRecords"] = dayRecords.map { r in
            ["date": ISO8601DateFormatter().string(from: r.date),
             "won": r.dayWon,
             "victories": r.victoriesCount,
             "defeats": r.defeatsCount] as [String: Any]
        }
        dict["achievements"] = achievements.map { a in
            ["id": a.achievementId,
             "unlockedAt": ISO8601DateFormatter().string(from: a.unlockedAt)] as [String: Any]
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
                    Text(title).font(.system(size: 14, weight: .medium)).foregroundColor(.white)
                    Text(subtitle).font(.system(size: 11)).foregroundColor(Color(white: 0.4))
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 12)).foregroundColor(Color(white: 0.3))
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder private func rowDivider() -> some View {
        Rectangle().fill(Color(white: 1, opacity: 0.06)).frame(height: 1).padding(.leading, 58)
    }

    @ViewBuilder private func sectionHeader(_ title: String) -> some View {
        Text(title).font(.system(size: 11, weight: .bold)).foregroundColor(.orange)
            .tracking(1).padding(.horizontal, 24).padding(.bottom, 14)
    }
}

// UIActivityViewController wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uvc: UIActivityViewController, context: Context) {}
}
```

**Step 2: Check which SwiftData model holds Battle separately**

Read `Models/Battle.swift` and `Models/DayRecord.swift` to confirm the `@Query` types and property names (`victoriesCount`, `defeatsCount`, `unlockedAt`) before implementing. Adjust the export dict if names differ.

**Step 3: Add the row in ProfileView**

In `ProfileView.swift`, after the Notifications `settingsRow`, add:

```swift
rowDivider()

settingsRow(
    icon: "lock.shield.fill",
    iconColor: Color(red: 0.2, green: 0.6, blue: 0.4),
    title: "Data & Privacy",
    subtitle: "Export, delete, or view your data"
) {
    DataPrivacySettingsView()
}
```

---

## Task 5: DataInfoView (what data this app stores)

**Files:**
- New: `Brawlbit game/Views/Profile/DataInfoView.swift`

Simple scrollable informational screen. Pure UI, no logic.

```swift
import SwiftUI

struct DataInfoView: View {
    @Environment(\.dismiss) private var dismiss

    private let rows: [(String, String, String)] = [
        ("person.fill",       "Hero name",           "Your chosen hero name. Not your real name."),
        ("gamecontroller.fill","Hero class & arena", "Your selected character and battleground."),
        ("list.bullet",       "Tasks",               "Task names, deadlines and routines you create."),
        ("chart.bar.fill",    "Battle results",      "Daily win/loss history and task completion times."),
        ("trophy.fill",       "Achievements",        "Which achievements you've unlocked and when."),
        ("star.fill",         "Points & coins",      "Your in-game progression data."),
        ("bell.fill",         "Notification prefs",  "Which notification types you have enabled."),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.07).ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        Text("All data is stored **only on your device**. Nothing is ever sent to a server.")
                            .font(.system(size: 14))
                            .foregroundColor(Color(white: 0.7))
                            .padding(.horizontal, 24)
                            .padding(.top, 8)

                        VStack(spacing: 0) {
                            ForEach(Array(rows.enumerated()), id: \.offset) { i, row in
                                HStack(alignment: .top, spacing: 14) {
                                    Image(systemName: row.0)
                                        .font(.system(size: 13))
                                        .foregroundColor(.white)
                                        .frame(width: 28, height: 28)
                                        .background(Color.orange.opacity(0.8))
                                        .cornerRadius(7)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(row.1).font(.system(size: 14, weight: .medium)).foregroundColor(.white)
                                        Text(row.2).font(.system(size: 11)).foregroundColor(Color(white: 0.4))
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 16).padding(.vertical, 12)
                                if i < rows.count - 1 {
                                    Rectangle().fill(Color(white:1,opacity:0.06)).frame(height:1).padding(.leading,58)
                                }
                            }
                        }
                        .background(Color(white: 0.12))
                        .cornerRadius(14)
                        .padding(.horizontal, 24)

                        VStack(alignment: .leading, spacing: 8) {
                            Label("No email, phone or real name collected", systemImage: "checkmark.circle.fill").foregroundColor(.green)
                            Label("No analytics or advertising SDKs", systemImage: "checkmark.circle.fill").foregroundColor(.green)
                            Label("No internet connection required", systemImage: "checkmark.circle.fill").foregroundColor(.green)
                            Label("Backed up with iCloud if you have it enabled", systemImage: "checkmark.circle.fill").foregroundColor(.green)
                        }
                        .font(.system(size: 13))
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 60)
                }
            }
            .navigationTitle("What we store")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(.orange)
                }
            }
        }
    }
}
```

---

## Task 6: About section

**Files:**
- New: `Brawlbit game/Views/Profile/AboutView.swift`
- Modify: `Brawlbit game/Views/Profile/ProfileView.swift`

**Step 1: Create AboutView.swift**

```swift
import SwiftUI
import StoreKit

struct AboutView: View {
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    // Replace with real App Store ID once published
    private let appStoreId = "XXXXXXXXXX"

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // Version
                    sectionHeader("APP")
                    VStack(spacing: 0) {
                        infoRow(icon: "info.circle.fill", iconColor: .gray,
                                title: "Version", value: "\(appVersion) (\(buildNumber))")
                    }
                    .background(Color(white: 0.12))
                    .cornerRadius(14)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                    // Actions
                    sectionHeader("SUPPORT")
                    VStack(spacing: 0) {
                        actionRow(icon: "star.fill", iconColor: .yellow,
                                  title: "Rate Brawlbit") {
                            if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appStoreId)?action=write-review") {
                                UIApplication.shared.open(url)
                            }
                        }
                        rowDivider()
                        actionRow(icon: "envelope.fill", iconColor: .blue,
                                  title: "Contact support") {
                            if let url = URL(string: "mailto:jsarriab28@gmail.com?subject=Brawlbit%20Support") {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    .background(Color(white: 0.12))
                    .cornerRadius(14)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)

                    // Legal
                    sectionHeader("LEGAL")
                    VStack(spacing: 0) {
                        actionRow(icon: "doc.text.fill", iconColor: Color(white: 0.4),
                                  title: "Terms and Conditions") {
                            // Replace with real hosted URL
                            if let url = URL(string: "https://yourwebsite.com/terms") {
                                UIApplication.shared.open(url)
                            }
                        }
                        rowDivider()
                        actionRow(icon: "lock.fill", iconColor: Color(white: 0.4),
                                  title: "Privacy Policy") {
                            if let url = URL(string: "https://yourwebsite.com/privacy") {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    .background(Color(white: 0.12))
                    .cornerRadius(14)
                    .padding(.horizontal, 24)

                    Text("Made with ☕ and way too many late nights.")
                        .font(.system(size: 11))
                        .foregroundColor(Color(white: 0.3))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 32)
                }
                .padding(.top, 24)
                .padding(.bottom, 60)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    @ViewBuilder
    private func infoRow(icon: String, iconColor: Color, title: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(iconColor)
                .cornerRadius(7)
            Text(title).font(.system(size: 14, weight: .medium)).foregroundColor(.white)
            Spacer()
            Text(value).font(.system(size: 13)).foregroundColor(Color(white: 0.4))
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }

    @ViewBuilder
    private func actionRow(icon: String, iconColor: Color, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(iconColor)
                    .cornerRadius(7)
                Text(title).font(.system(size: 14, weight: .medium)).foregroundColor(.white)
                Spacer()
                Image(systemName: "arrow.up.right").font(.system(size: 12)).foregroundColor(Color(white: 0.3))
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder private func rowDivider() -> some View {
        Rectangle().fill(Color(white: 1, opacity: 0.06)).frame(height: 1).padding(.leading, 58)
    }

    @ViewBuilder private func sectionHeader(_ title: String) -> some View {
        Text(title).font(.system(size: 11, weight: .bold)).foregroundColor(Color(white: 0.4))
            .tracking(1).padding(.horizontal, 24).padding(.bottom, 14)
    }
}
```

**Step 2: Add About row in ProfileView**

After the Data & Privacy row, add:

```swift
rowDivider()

settingsRow(
    icon: "ellipsis.circle.fill",
    iconColor: Color(white: 0.35),
    title: "About",
    subtitle: "Version, rate, contact, legal"
) {
    AboutView()
}
```

**Step 3: Update T&C and Privacy Policy URLs**

Once you host the .md files (GitHub Pages, Notion, etc.), update the two `URL(string:)` lines in `AboutView.swift`.

---

## Verification

1. **Reduce Animations** — Toggle on in GameMode settings → go to Today tab → hero sprite is frozen on first frame
2. **Vacation Mode** — Set 1-day vacation → force kill and reopen app → day resets but no battle loss shown, streak unchanged
3. **Streak notification** — Win a few days to build a streak → check Notification center at 8 PM → notification present; win the day → notification cancelled
4. **Delete all data** — Profile → Data & Privacy → Delete → app should show onboarding on next launch
5. **Export** — Profile → Data & Privacy → Export → share sheet opens with `brawlbit_data.json`
6. **Data info screen** — Profile → Data & Privacy → "What data" → info screen visible
7. **About** — Profile → About → version shown, mailto link opens Mail, legal links open browser
