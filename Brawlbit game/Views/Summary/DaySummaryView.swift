import SwiftUI
import SwiftData

struct DaySummaryView: View {
    @Query(sort: \DayRecord.date, order: .reverse) private var records: [DayRecord]
    @Query private var heroes: [Hero]
    @Environment(\.dismiss) private var dismiss

    @State private var frameIndex: Int = 0
    @State private var timer: Timer?

    var latest: DayRecord? { records.first }
    var hero: Hero? { heroes.first }
    var won: Bool { latest?.dayWon == true }
    var pointsToday: Int { (latest?.victoriesCount ?? 0) * 10 }
    var streak: Int { AchievementService.currentWinStreak(records) }

    var body: some View {
        ZStack {
            // Background gradient — orange for victory, dark red for defeat
            (won
                ? LinearGradient(
                    colors: [Color(red: 0.85, green: 0.45, blue: 0.0), Color(red: 0.35, green: 0.12, blue: 0.0)],
                    startPoint: .top, endPoint: .bottom)
                : LinearGradient(
                    colors: [Color(red: 0.45, green: 0.04, blue: 0.04), Color(red: 0.12, green: 0.02, blue: 0.02)],
                    startPoint: .top, endPoint: .bottom)
            )
            .ignoresSafeArea()

            if won { ConfettiView() }

            VStack(spacing: 0) {
                Spacer()

                // Title
                VStack(spacing: 10) {
                    Text(won ? "VICTORY!" : "DEFEATED!")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text(won ? "The monster falls before you." : "The monster defeated you today.")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(Color(white: 1, opacity: 0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)

                Spacer()

                // Stats row — XP and streak
                HStack(spacing: 0) {
                    Spacer()
                    VStack(spacing: 4) {
                        Text("+\(pointsToday)")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("XP earned")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(Color(white: 1, opacity: 0.6))
                    }
                    Spacer()
                    Rectangle()
                        .fill(Color(white: 1, opacity: 0.3))
                        .frame(width: 1, height: 44)
                    Spacer()
                    VStack(spacing: 4) {
                        Text(won ? "🔥 \(streak)" : "💀 0")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("day streak")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(Color(white: 1, opacity: 0.6))
                    }
                    Spacer()
                }
                .padding(.vertical, 20)
                .background(Color(white: 0, opacity: 0.15))
                .cornerRadius(16)
                .padding(.horizontal, 32)

                Spacer()

                // Animated hero
                if let hero {
                    Image(hero.heroClass.idleFrames[frameIndex])
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .onAppear { startAnimation(frames: hero.heroClass.idleFrames) }
                        .onDisappear { timer?.invalidate() }
                }

                // Battle results list
                if let record = latest, !record.battles.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(record.battles, id: \.taskName) { battle in
                            HStack(spacing: 10) {
                                Text(battle.result == .victory ? "✅" : "❌")
                                    .font(.system(size: 14))
                                Text(battle.taskName)
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(white: 1, opacity: 0.85))
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                }

                Spacer()

                Button("Back to camp") { dismiss() }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(white: 1, opacity: 0.2))
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
            }
        }
    }

    private func startAnimation(frames: [String]) {
        frameIndex = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { _ in
            frameIndex = (frameIndex + 1) % frames.count
        }
    }
}

// MARK: - Confetti (victory only)

private struct ConfettiView: View {

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
        let colors: [Color] = [.red, .orange, .yellow, .green, .cyan, .purple, .pink]
        items = (0..<40).map { _ in
            Item(
                x: CGFloat.random(in: 0.05...0.95),
                color: colors.randomElement()!,
                size: CGFloat.random(in: 6...12),
                delay: Double.random(in: 0...2),
                isCircle: Bool.random(),
                rotation: Double.random(in: 180...540),
                duration: Double.random(in: 1.5...2.5)
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
