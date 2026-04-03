import WidgetKit
import SwiftUI

// MARK: - Entry

struct BrawlbitEntry: TimelineEntry {
    let date: Date
    let data: WidgetData?
}

// MARK: - Provider

struct BrawlbitProvider: TimelineProvider {
    func placeholder(in context: Context) -> BrawlbitEntry {
        BrawlbitEntry(date: Date(), data: placeholderData)
    }
    func getSnapshot(in context: Context, completion: @escaping (BrawlbitEntry) -> Void) {
        completion(BrawlbitEntry(date: Date(), data: WidgetDataProvider.read() ?? placeholderData))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<BrawlbitEntry>) -> Void) {
        let entry = BrawlbitEntry(date: Date(), data: WidgetDataProvider.read())
        let next = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private var placeholderData: WidgetData {
        WidgetData(
            heroName: "Hero",
            heroHP: 0.75,
            heroPoints: 120,
            todayTasks: [
                WidgetTaskInfo(id: "a", taskName: "Study", monsterEmoji: "👹",
                               deadlineHour: 14, deadlineMinute: 0, isCompleted: true, isActive: true),
                WidgetTaskInfo(id: "b", taskName: "Exercise", monsterEmoji: "🐉",
                               deadlineHour: 17, deadlineMinute: 0, isCompleted: false, isActive: true),
            ],
            updatedAt: Date()
        )
    }
}

// MARK: - Next Battle (small)

struct NextBattleWidgetView: View {
    let entry: BrawlbitEntry

    private var nextTask: WidgetTaskInfo? {
        entry.data?.todayTasks.first { $0.isActive && !$0.isCompleted }
    }

    var body: some View {
        ZStack {
            Color(white: 0.07)
            if let task = nextTask {
                VStack(alignment: .leading, spacing: 6) {
                    Text("⚔️ NEXT BATTLE")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.orange)
                        .tracking(1)
                    Spacer()
                    Text(task.monsterEmoji)
                        .font(.system(size: 36))
                    Text(task.taskName)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(task.deadlineFormatted)
                        .font(.system(size: 11))
                        .foregroundColor(Color(white: 0.5))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
            } else {
                VStack(spacing: 6) {
                    Text("🏆")
                        .font(.system(size: 36))
                    Text("Day won!")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.orange)
                }
            }
        }
        .containerBackground(Color(white: 0.07), for: .widget)
    }
}

struct NextBattleWidget: Widget {
    let kind = "NextBattleWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BrawlbitProvider()) { entry in
            NextBattleWidgetView(entry: entry)
        }
        .configurationDisplayName("Next Battle")
        .description("Your next upcoming monster.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - War Status (medium)

struct WarStatusWidgetView: View {
    let entry: BrawlbitEntry

    var body: some View {
        ZStack {
            Color(white: 0.07)
            if let data = entry.data {
                VStack(alignment: .leading, spacing: 8) {
                    // Hero row
                    HStack(spacing: 8) {
                        Text("🧙")
                            .font(.system(size: 18))
                        Text(data.heroName)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color(white: 0.2))
                                    .frame(height: 6)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(data.heroHP > 0.4 ? Color.green : Color.red)
                                    .frame(width: geo.size.width * data.heroHP, height: 6)
                            }
                        }
                        .frame(width: 60, height: 6)
                    }

                    Divider().background(Color(white: 0.2))

                    ForEach(data.todayTasks.prefix(4), id: \.id) { task in
                        HStack(spacing: 6) {
                            Text(task.isCompleted ? "✅" : (task.isActive ? task.monsterEmoji : "💀"))
                                .font(.system(size: 12))
                            Text(task.taskName)
                                .font(.system(size: 11, weight: task.isCompleted ? .regular : .semibold))
                                .foregroundColor(task.isCompleted ? Color(white: 0.4) : .white)
                                .lineLimit(1)
                            Spacer()
                            Text(task.deadlineFormatted)
                                .font(.system(size: 10))
                                .foregroundColor(Color(white: 0.4))
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(14)
            } else {
                Text("Open Brawlbit to start")
                    .font(.system(size: 12))
                    .foregroundColor(Color(white: 0.4))
            }
        }
        .containerBackground(Color(white: 0.07), for: .widget)
    }
}

struct WarStatusWidget: Widget {
    let kind = "WarStatusWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BrawlbitProvider()) { entry in
            WarStatusWidgetView(entry: entry)
        }
        .configurationDisplayName("War Status")
        .description("Today's battles at a glance.")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Bundle

@main
struct BrawlbitWidgetBundle: WidgetBundle {
    var body: some Widget {
        NextBattleWidget()
        WarStatusWidget()
    }
}
