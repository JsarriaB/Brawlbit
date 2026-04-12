import SwiftUI
import SwiftData
import Combine

// Helper so AddTaskSheet sheet knows which routine to add to
struct AddTaskTarget: Identifiable {
    let id = UUID()
    let routineIndex: Int
    let availableDays: [Int]
}

struct ProfileView: View {
    @Query private var heroes: [Hero]
    @Query(filter: #Predicate<Goal90> { $0.isCompleted },
           sort: \Goal90.completedAt,
           order: .reverse) private var pastChallenges: [Goal90]
    @Environment(\.modelContext) private var modelContext

    var hero: Hero? { heroes.first }

    @State private var editingName = false
    @State private var nameInput = ""
    @State private var heroFrame: Int = 0
    @State private var isAnimating = false
    private let frameTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    private let cycleTimer = Timer.publish(every: 4.0, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color(white: 0.07).ignoresSafeArea()

                // ── Fixed room banner ─────────────────────────────────
                if let hero {
                    roomBanner(hero: hero)
                        .ignoresSafeArea(edges: .top)
                        .zIndex(1)
                }

                ScrollView {
                    VStack(spacing: 0) {

                        // Spacer that sits behind the fixed banner
                        Color.clear.frame(height: 300)

                        // ── Header card ──────────────────────────────────
                        if let hero {
                            headerCard(hero: hero)
                                .padding(.horizontal, 20)
                                .padding(.top, -16)
                                .padding(.bottom, 24)
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
                                icon: "shield.lefthalf.filled",
                                iconColor: .blue,
                                title: "Game Mode",
                                subtitle: (hero?.easyMode ?? true) ? "Easy — Revenges count as victories" : "Hard — A missed deadline is a defeat"
                            ) {
                                if let hero { GameModeSettingsView(hero: hero) }
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

                            rowDivider()

                            settingsRow(
                                icon: "lock.shield.fill",
                                iconColor: Color(red: 0.2, green: 0.6, blue: 0.4),
                                title: "Data & Privacy",
                                subtitle: "Export, delete or view your data"
                            ) {
                                DataPrivacySettingsView()
                            }

                            rowDivider()

                            settingsRow(
                                icon: "ellipsis.circle.fill",
                                iconColor: Color(white: 0.35),
                                title: "About",
                                subtitle: "Version, rate, contact & legal"
                            ) {
                                AboutView()
                            }
                        }
                        .background(Color(white: 0.12))
                        .cornerRadius(16)
                        .padding(.horizontal, 20)

                        // ── Past Challenges ───────────────────────────────
                        if !pastChallenges.isEmpty {
                            pastChallengesSection()
                        }
                    }
                    .padding(.bottom, 60)
                }
            }
        }
        .onReceive(frameTimer) { _ in
            guard isAnimating, let hero else { return }
            let frames = hero.heroClass.idleFrames
            let next = heroFrame + 1
            if next >= frames.count {
                heroFrame = 0
                isAnimating = false
            } else {
                heroFrame = next
            }
        }
        .onReceive(cycleTimer) { _ in
            isAnimating = true
        }
        .onAppear { isAnimating = true }
        .onChange(of: hero?.heroClass) { heroFrame = 0 }
    }

    // MARK: - Room banner

    @ViewBuilder
    private func roomBanner(hero: Hero) -> some View {
        let frames = hero.heroClass.idleFrames
        ZStack(alignment: .bottom) {
            Image(hero.heroClass.roomAssetName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .scaleEffect(hero.heroClass == .knight ? 1.18 : 1.0, anchor: .center)
                .offset(x: hero.heroClass == .knight ? 30 : 0)
                .clipped()

            LinearGradient(
                colors: [Color(white: 0.07), Color.clear],
                startPoint: .bottom,
                endPoint: .init(x: 0.5, y: 0.35)
            )

            let spriteBottomPadding: CGFloat = {
                switch hero.heroClass {
                case .knight: return 44
                case .rogue: return 38
                case .mage: return 28
                }
            }()

            Image(frames[heroFrame % frames.count])
                .resizable()
                .scaledToFit()
                .frame(height: 140)
                .padding(.bottom, spriteBottomPadding)
        }
        .frame(height: 300)
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Header card

    @ViewBuilder
    private func headerCard(hero: Hero) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Name (editable)
            if editingName {
                HStack(spacing: 8) {
                    TextField("Hero name", text: $nameInput)
                        .font(.system(size: 26, weight: .black))
                        .foregroundColor(.white)
                        .tint(.orange)
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

            // Coins (left) + Level & class (right)
            HStack {
                HStack(spacing: 4) {
                    Text("🪙")
                        .font(.system(size: 14))
                    Text("\(hero.coins)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.82, blue: 0.2))
                }
                Spacer()
                HStack(spacing: 8) {
                    Text("\(AchievementService.level(for: hero.points))")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(.orange)
                    Text(hero.heroClass.displayName)
                        .font(.system(size: 13))
                        .foregroundColor(Color(white: 0.45))
                }
            }
            .padding(.bottom, 12)

            // XP bar
            VStack(alignment: .leading, spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(white: 0.18))
                            .frame(height: 6)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.orange)
                            .frame(width: geo.size.width * AchievementService.xpProgress(for: hero.points),
                                   height: 6)
                    }
                }
                .frame(height: 6)

                Text("\(AchievementService.xpInCurrentLevel(for: hero.points)) / \(AchievementService.xpPerLevel) XP")
                    .font(.system(size: 10))
                    .foregroundColor(Color(white: 0.35))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(22)
        .background(Color(white: 0.12))
        .cornerRadius(16)
    }

    private func saveName(hero: Hero) {
        let trimmed = nameInput.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty { hero.name = trimmed }
        try? modelContext.save()
        editingName = false
    }

    // MARK: - Past Challenges

    @ViewBuilder
    private func pastChallengesSection() -> some View {
        let dateFormatter: DateFormatter = {
            let f = DateFormatter()
            f.dateStyle = .medium
            f.timeStyle = .none
            return f
        }()

        VStack(alignment: .leading, spacing: 12) {
            Text("PAST CHALLENGES")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(white: 0.4))
                .tracking(1)
                .padding(.horizontal, 24)
                .padding(.top, 32)

            VStack(spacing: 10) {
                ForEach(pastChallenges) { challenge in
                    HStack(spacing: 14) {
                        Image("cup")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)

                        VStack(alignment: .leading, spacing: 3) {
                            Text("\"" + challenge.goalText + "\"")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .lineLimit(2)
                            if let completedAt = challenge.completedAt {
                                Text("\(dateFormatter.string(from: challenge.startDate)) – \(dateFormatter.string(from: completedAt))  ·  90 days")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color(white: 0.35))
                            }
                        }
                        Spacer()
                    }
                    .padding(14)
                    .background(Color(white: 0.12))
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                }
            }
        }
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
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
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
