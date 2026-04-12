import SwiftUI
import SwiftData

struct GameModeSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    let hero: Hero

    @AppStorage("reduceAnimations") private var reduceAnimations: Bool = false
    @State private var showVacationPicker = false
    @State private var vacationDays: Int = 1

    private var isOnVacation: Bool {
        guard let end = hero.vacationEndDate else { return false }
        let cal = Calendar.current
        return cal.startOfDay(for: Date()) <= cal.startOfDay(for: end)
    }

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.system(size: 42))
                            .foregroundColor(.blue)
                            .padding(.top, 32)
                        Text("Game Mode")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.white)
                        Text("Choose how revenge battles affect your daily score.")
                            .font(.system(size: 13))
                            .foregroundColor(Color(white: 0.45))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 8)

                    // Easy card
                    modeCard(
                        selected: hero.easyMode,
                        icon: "🌟",
                        title: "Easy",
                        description: "If you avenge a monster after the deadline, it still counts as a victory for the day. Progress is rewarded even when late.",
                        accentColor: .green
                    ) {
                        hero.easyMode = true
                        try? modelContext.save()
                    }

                    // Hard card
                    modeCard(
                        selected: !hero.easyMode,
                        icon: "💀",
                        title: "Hard",
                        description: "A missed deadline is a defeat, period. Avenging a monster earns points but won't save the day. Discipline or nothing.",
                        accentColor: .red
                    ) {
                        hero.easyMode = false
                        try? modelContext.save()
                    }

                    Rectangle()
                        .fill(Color(white: 1, opacity: 0.07))
                        .frame(height: 1)

                    // Reduce Animations card
                    modeCard(
                        selected: reduceAnimations,
                        icon: "⚡",
                        title: "Reduce Animations",
                        description: "Freezes the hero and monster idle loops. Battle sequences still play normally. Useful for older devices.",
                        accentColor: .cyan
                    ) {
                        reduceAnimations.toggle()
                    }

                    Rectangle()
                        .fill(Color(white: 1, opacity: 0.07))
                        .frame(height: 1)

                    // Vacation Mode card
                    vacationCard()

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("Game Mode")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Vacation card

    @ViewBuilder
    private func vacationCard() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 14) {
                Text("🏖️")
                    .font(.system(size: 28))
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Vacation Mode")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        if isOnVacation {
                            Text("ACTIVE")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.cyan)
                                .tracking(0.5)
                        }
                    }

                    Text("Pause your streak for up to 7 days with no penalty. No wins or losses recorded while on vacation.")
                        .font(.system(size: 13))
                        .foregroundColor(Color(white: 0.5))
                        .fixedSize(horizontal: false, vertical: true)

                    if isOnVacation, let end = hero.vacationEndDate {
                        let formatted = end.formatted(date: .abbreviated, time: .omitted)
                        Text("Until \(formatted)")
                            .font(.system(size: 12))
                            .foregroundColor(.cyan)

                        Button("Cancel vacation") {
                            hero.vacationEndDate = nil
                            showVacationPicker = false
                            try? modelContext.save()
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.red)
                    } else {
                        if showVacationPicker {
                            HStack(spacing: 16) {
                                Stepper(
                                    "\(vacationDays) day\(vacationDays == 1 ? "" : "s")",
                                    value: $vacationDays, in: 1...7
                                )
                                .foregroundColor(.white)
                                .tint(.cyan)
                                .labelsHidden()

                                Text("\(vacationDays) day\(vacationDays == 1 ? "" : "s")")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(minWidth: 50, alignment: .leading)

                                Spacer()

                                Button("Activate") {
                                    let cal = Calendar.current
                                    let start = cal.startOfDay(for: Date())
                                    let end = cal.date(byAdding: .day, value: vacationDays - 1, to: start) ?? start
                                    hero.vacationEndDate = end
                                    showVacationPicker = false
                                    try? modelContext.save()
                                }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.cyan)
                            }
                        } else {
                            Button("Set vacation") {
                                vacationDays = 1
                                showVacationPicker = true
                            }
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.cyan)
                        }
                    }
                }
            }
            .padding(18)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: isOnVacation ? 0.14 : 0.10))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isOnVacation ? Color.cyan.opacity(0.5) : Color(white: 0.15),
                        lineWidth: isOnVacation ? 1.5 : 1)
        )
    }

    // MARK: - Mode card

    @ViewBuilder
    private func modeCard(
        selected: Bool,
        icon: String,
        title: String,
        description: String,
        accentColor: Color,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 14) {
                Text(icon)
                    .font(.system(size: 28))
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        if selected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(accentColor)
                                .font(.system(size: 20))
                        } else {
                            Circle()
                                .stroke(Color(white: 0.3), lineWidth: 1.5)
                                .frame(width: 20, height: 20)
                        }
                    }
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(Color(white: 0.5))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(white: selected ? 0.14 : 0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(selected ? accentColor.opacity(0.5) : Color(white: 0.15),
                            lineWidth: selected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
