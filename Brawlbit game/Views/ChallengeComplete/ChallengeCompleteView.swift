import SwiftUI
import SwiftData

struct ChallengeCompleteView: View {
    @Query(filter: #Predicate<Goal90> { !$0.isCompleted }) private var activeGoals: [Goal90]
    @Query private var dayRecords: [DayRecord]
    @Query private var heroes: [Hero]
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    @State private var showNewChallenge = false
    @State private var heroFrame = 0
    @State private var frameTimer: Timer? = nil

    private var goal: Goal90? { activeGoals.first }
    private var hero: Hero? { heroes.first }

    private var totalMonsters: Int {
        dayRecords.reduce(0) { $0 + $1.victoriesCount }
    }

    private var winRate: Int {
        guard !dayRecords.isEmpty else { return 0 }
        let won = dayRecords.filter { $0.dayWon }.count
        return Int(Double(won) / Double(dayRecords.count) * 100)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Epic gold gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.85, green: 0.60, blue: 0.0),
                        Color(red: 0.45, green: 0.20, blue: 0.0),
                        Color(red: 0.12, green: 0.05, blue: 0.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ChallengeConfettiView()

                VStack(spacing: 0) {
                    // Mountain with hero + cup at summit
                    ZStack(alignment: .top) {
                        Image("Mountain")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: geo.size.height * 0.40)
                            .clipped()

                        GeometryReader { inner in
                            let summitX = inner.size.width * 0.50
                            let summitY = inner.size.height * 0.20

                            Image("cup")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 52, height: 52)
                                .position(x: summitX + 34, y: summitY - 10)

                            if let hero, !hero.heroClass.idleFrames.isEmpty {
                                Image(hero.heroClass.idleFrames[heroFrame % hero.heroClass.idleFrames.count])
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 48, height: 48)
                                    .position(x: summitX - 20, y: summitY + 4)
                            }
                        }
                        .frame(height: geo.size.height * 0.40)
                    }

                    Spacer()

                    // Title
                    VStack(spacing: 8) {
                        Text("🏆")
                            .font(.system(size: 44))
                        Text("Challenge Complete")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        if let goal {
                            Text("\"" + goal.goalText + "\"")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(Color(white: 1, opacity: 0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                    }

                    Spacer()

                    // Stats cards
                    HStack(spacing: 10) {
                        StatCard(value: "90", label: "days")
                        StatCard(value: "\(totalMonsters)", label: "monsters")
                        StatCard(value: "\(winRate)%", label: "win rate")
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    // Buttons
                    VStack(spacing: 12) {
                        Button {
                            shareResult()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Share your victory")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(white: 1, opacity: 0.2))
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }

                        Button {
                            showNewChallenge = true
                        } label: {
                            Text("Set a new challenge")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .foregroundColor(Color(red: 0.6, green: 0.3, blue: 0.0))
                                .cornerRadius(14)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear { startHeroAnimation() }
        .onDisappear { frameTimer?.invalidate() }
        .sheet(isPresented: $showNewChallenge) {
            NewChallengeSheet { newGoalText in
                archiveAndCreateNew(goalText: newGoalText)
            }
        }
    }

    private func startHeroAnimation() {
        frameTimer = Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { _ in
            heroFrame += 1
        }
    }

    private func shareResult() {
        let text = "I completed my 90-day Brawlbit challenge: \"\(goal?.goalText ?? "")\" — \(totalMonsters) monsters defeated, \(winRate)% win rate. Every day is a battle. Win yours. 🔥"
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = windowScene.windows.first?.rootViewController {
            root.present(vc, animated: true)
        }
    }

    private func archiveAndCreateNew(goalText: String) {
        if let goal {
            goal.isCompleted = true
            goal.completedAt = Date()
        }
        let newGoal = Goal90(goalText: goalText)
        modelContext.insert(newGoal)
        try? modelContext.save()
        showNewChallenge = false
        appState.showChallengeComplete = false
    }
}

// MARK: - Stat card

private struct StatCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(Color(white: 1, opacity: 0.65))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(white: 0, opacity: 0.2))
        .cornerRadius(14)
    }
}

// MARK: - Confetti

private struct ChallengeConfettiView: View {

    private struct Item {
        let x: CGFloat
        let color: Color
        let size: CGFloat
        let delay: Double
        let isCircle: Bool
        let rotation: Double
        let duration: Double
    }

    private let items: [Item]
    @State private var animate = false

    init() {
        let colors: [Color] = [.red, .orange, .yellow, .green, .cyan, .purple, .pink, .white]
        items = (0..<50).map { _ in
            Item(
                x: CGFloat.random(in: 0.05...0.95),
                color: colors.randomElement()!,
                size: CGFloat.random(in: 6...14),
                delay: Double.random(in: 0...2.5),
                isCircle: Bool.random(),
                rotation: Double.random(in: 180...540),
                duration: Double.random(in: 2.0...3.5)
            )
        }
    }

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<items.count, id: \.self) { i in
                let item = items[i]
                Group {
                    if item.isCircle {
                        Circle()
                            .fill(item.color)
                            .frame(width: item.size, height: item.size)
                    } else {
                        Capsule()
                            .fill(item.color)
                            .frame(width: item.size * 0.5, height: item.size * 1.8)
                    }
                }
                .rotationEffect(.degrees(animate ? item.rotation : 0))
                .position(x: item.x * geo.size.width, y: animate ? geo.size.height + 30 : -30)
                .animation(
                    .easeIn(duration: item.duration).delay(item.delay),
                    value: animate
                )
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear { animate = true }
    }
}
