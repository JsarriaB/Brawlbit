import SwiftUI
import SwiftData

struct NotificationsSettingsView: View {
    @Query(sort: \MonsterTask.order) private var tasks: [MonsterTask]

    @AppStorage("notif_battle_start")   private var notifBattleStart = true
    @AppStorage("notif_3h")             private var notif3h = true
    @AppStorage("notif_30min")          private var notif30min = true
    @AppStorage("notif_5min")           private var notif5min = true
    @AppStorage("notif_defeat")         private var notifDefeat = true
    @AppStorage("notif_streak_warning") private var notifStreakWarning = true

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    sectionHeader("ALERTS")

                    VStack(spacing: 0) {
                        notifRow(
                            icon: "flag.fill", iconColor: .green,
                            title: "Battle starts",
                            subtitle: "When a new task becomes your active battle",
                            binding: $notifBattleStart
                        )
                        rowDivider()
                        notifRow(
                            icon: "clock.fill", iconColor: .blue,
                            title: "3 hours before",
                            subtitle: "Mid-day reminder",
                            binding: $notif3h
                        )
                        rowDivider()
                        notifRow(
                            icon: "exclamationmark.triangle.fill", iconColor: .orange,
                            title: "30 minutes before",
                            subtitle: "Warning before deadline",
                            binding: $notif30min
                        )
                        rowDivider()
                        notifRow(
                            icon: "flame.fill", iconColor: .red,
                            title: "5 minutes before",
                            subtitle: "Last chance alert",
                            binding: $notif5min
                        )
                        rowDivider()
                        notifRow(
                            icon: "xmark.circle.fill", iconColor: Color(white: 0.4),
                            title: "Defeat",
                            subtitle: "When you miss a task deadline",
                            binding: $notifDefeat
                        )
                        rowDivider()
                        notifRow(
                            icon: "flame.fill", iconColor: .yellow,
                            title: "Streak at risk",
                            subtitle: "Evening reminder if you haven't won the day yet",
                            binding: $notifStreakWarning
                        )
                    }
                    .background(Color(white: 0.12))
                    .cornerRadius(14)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

                    Button {
                        if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Text("Open iOS notification settings")
                                .font(.system(size: 13))
                                .foregroundColor(Color(white: 0.4))
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 13))
                                .foregroundColor(Color(white: 0.3))
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.top, 24)
                .padding(.bottom, 60)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    @ViewBuilder
    private func notifRow(icon: String, iconColor: Color, title: String, subtitle: String, binding: Binding<Bool>) -> some View {
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

            Toggle("", isOn: binding)
                .tint(.orange)
                .labelsHidden()
                .onChange(of: binding.wrappedValue) { _, _ in
                    NotificationService.scheduleAll(tasks: tasks)
                }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
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
