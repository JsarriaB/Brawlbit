import SwiftUI
import SwiftData

// Helper so AddTaskSheet sheet knows which routine to add to
struct AddTaskTarget: Identifiable {
    let id = UUID()
    let routineIndex: Int
    let availableDays: [Int]
}

struct ProfileView: View {
    @Query private var heroes: [Hero]
    @Environment(\.modelContext) private var modelContext

    var hero: Hero? { heroes.first }

    @State private var editingName = false
    @State private var nameInput = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color(white: 0.07).ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 0) {

                        // ── Header card ──────────────────────────────────
                        if let hero {
                            headerCard(hero: hero)
                                .padding(.horizontal, 24)
                                .padding(.top, 56)
                                .padding(.bottom, 32)
                        }

                        // ── Section rows ─────────────────────────────────
                        VStack(spacing: 0) {
                            settingsRow(
                                icon: "paintbrush.fill",
                                iconColor: .purple,
                                title: "Customization",
                                subtitle: "Hero, class and arena"
                            ) {
                                if let hero {
                                    CustomizationSettingsView(hero: hero)
                                }
                            }

                            rowDivider()

                            settingsRow(
                                icon: "list.bullet.rectangle.fill",
                                iconColor: .orange,
                                title: "Routines",
                                subtitle: "Tasks, schedules and monsters"
                            ) {
                                RoutinesSettingsView()
                            }

                            rowDivider()

                            settingsRow(
                                icon: "bell.fill",
                                iconColor: .red,
                                title: "Notifications",
                                subtitle: "Alerts and reminders"
                            ) {
                                NotificationsSettingsView()
                            }
                        }
                        .background(Color(white: 0.12))
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 60)
                }
            }
        }
    }

    // MARK: - Header card

    @ViewBuilder
    private func headerCard(hero: Hero) -> some View {
        VStack(spacing: 0) {
            // Hero sprite
            Image(hero.heroClass.idleFrames[0])
                .resizable()
                .scaledToFit()
                .frame(width: 110, height: 110)
                .padding(.bottom, 16)

            // Name (editable)
            if editingName {
                HStack(spacing: 8) {
                    TextField("Hero name", text: $nameInput)
                        .font(.system(size: 26, weight: .black))
                        .foregroundColor(.white)
                        .tint(.orange)
                        .multilineTextAlignment(.center)
                        .onSubmit { saveName(hero: hero) }
                    Button(action: { saveName(hero: hero) }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.orange)
                    }
                }
                .padding(.bottom, 10)
            } else {
                Button {
                    nameInput = hero.name
                    editingName = true
                } label: {
                    HStack(spacing: 6) {
                        Text(hero.name)
                            .font(.system(size: 26, weight: .black))
                            .foregroundColor(.white)
                        Image(systemName: "pencil")
                            .font(.system(size: 14))
                            .foregroundColor(Color(white: 0.35))
                    }
                }
                .padding(.bottom, 10)
            }

            // Level + class
            HStack(spacing: 10) {
                Text("LVL \(AchievementService.level(for: hero.points))")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .cornerRadius(7)
                Text(hero.heroClass.displayName)
                    .font(.system(size: 13))
                    .foregroundColor(Color(white: 0.45))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(Color(white: 0.12))
        .cornerRadius(16)
    }

    private func saveName(hero: Hero) {
        let trimmed = nameInput.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty { hero.name = trimmed }
        try? modelContext.save()
        editingName = false
    }

    // MARK: - Row builder

    @ViewBuilder
    private func settingsRow<Destination: View>(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink(destination: destination()) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(iconColor)
                    .cornerRadius(8)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(Color(white: 0.4))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(white: 0.3))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func rowDivider() -> some View {
        Rectangle()
            .fill(Color(white: 1, opacity: 0.06))
            .frame(height: 1)
            .padding(.leading, 62)
    }
}
