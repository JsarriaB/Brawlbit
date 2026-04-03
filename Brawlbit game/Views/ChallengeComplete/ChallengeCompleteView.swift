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
        ZStack {
            Color(white: 0.07).ignoresSafeArea()

            VStack(spacing: 0) {
                // Mountain with hero + cup at summit
                ZStack(alignment: .top) {
                    Image("Mountain")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.height * 0.48)
                        .clipped()

                    GeometryReader { geo in
                        let summitX = geo.size.width * 0.50
                        let summitY = geo.size.height * 0.20

                        // Cup
                        Image("cup")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 52, height: 52)
                            .position(x: summitX + 34, y: summitY - 10)

                        // Hero idle animation
                        if let hero, !hero.heroClass.idleFrames.isEmpty {
                            Image(hero.heroClass.idleFrames[heroFrame % hero.heroClass.idleFrames.count])
                                .resizable()
                                .scaledToFit()
                                .frame(width: 48, height: 48)
                                .position(x: summitX - 20, y: summitY + 4)
                        }
                    }
                    .frame(height: UIScreen.main.bounds.height * 0.48)
                }

                Spacer()

                // Text content
                VStack(spacing: 10) {
                    Text("Challenge Complete")
                        .font(.system(size: 30, weight: .black))
                        .foregroundColor(.white)

                    if let goal {
                        Text("\"" + goal.goalText + "\"")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.orange)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                    Text("90 days  ·  \(totalMonsters) monsters defeated  ·  \(winRate)% win rate")
                        .font(.system(size: 12))
                        .foregroundColor(Color(white: 0.4))
                        .padding(.top, 4)
                }

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    Button {
                        shareResult()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Share")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(white: 0.18))
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }

                    Button {
                        showNewChallenge = true
                    } label: {
                        Text("Set a new challenge")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .onAppear { startHeroAnimation() }
        .onDisappear { frameTimer?.invalidate() }
        .sheet(isPresented: $showNewChallenge) {
            NewChallengeSheet { newGoalText in
                archiveAndCreateNew(goalText: newGoalText)
            }
        }
    }

    // MARK: - Hero animation

    private func startHeroAnimation() {
        frameTimer = Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { _ in
            heroFrame += 1
        }
    }

    // MARK: - Share

    private func shareResult() {
        let text = "I completed my 90-day Brawlbit challenge: \"\(goal?.goalText ?? "")\" — \(totalMonsters) monsters defeated, \(winRate)% win rate. Every day is a battle. Win yours. 🔥"
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = windowScene.windows.first?.rootViewController {
            root.present(vc, animated: true)
        }
    }

    // MARK: - Archive + new challenge

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
