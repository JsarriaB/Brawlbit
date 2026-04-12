import SwiftUI

struct DataInfoView: View {
    @Environment(\.dismiss) private var dismiss

    private let rows: [(icon: String, title: String, subtitle: String)] = [
        ("person.fill",         "Hero name",            "The name you give your hero — not your real name."),
        ("gamecontroller.fill", "Class & battleground", "Your chosen character and arena."),
        ("list.bullet",         "Tasks & routines",     "Task names, deadlines and which days they run."),
        ("chart.bar.fill",      "Battle history",       "Daily win/loss results and task completion times."),
        ("trophy.fill",         "Achievements",         "Which achievements you've unlocked and when."),
        ("star.fill",           "Points & coins",       "Your in-game progression data."),
        ("bell.fill",           "Notification prefs",   "Which notification types you have enabled."),
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
                                    Image(systemName: row.icon)
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 28, height: 28)
                                        .background(Color.orange.opacity(0.85))
                                        .cornerRadius(7)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(row.title)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white)
                                        Text(row.subtitle)
                                            .font(.system(size: 11))
                                            .foregroundColor(Color(white: 0.4))
                                            .fixedSize(horizontal: false, vertical: true)
                                    }

                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)

                                if i < rows.count - 1 {
                                    Rectangle()
                                        .fill(Color(white: 1, opacity: 0.06))
                                        .frame(height: 1)
                                        .padding(.leading, 58)
                                }
                            }
                        }
                        .background(Color(white: 0.12))
                        .cornerRadius(14)
                        .padding(.horizontal, 24)

                        VStack(alignment: .leading, spacing: 10) {
                            guaranteeRow("No email, phone number or real name collected")
                            guaranteeRow("No analytics, advertising or third-party SDKs")
                            guaranteeRow("No internet connection required")
                            guaranteeRow("Included in iCloud backup if you have it enabled")
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("What we store")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.orange)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    @ViewBuilder
    private func guaranteeRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 15))
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(Color(white: 0.65))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
