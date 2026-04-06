import SwiftUI
import SwiftData

struct MountainView: View {
    @Query private var goals: [Goal90]
    @Query private var heroes: [Hero]

    @State private var frameIndex = 0
    @State private var timer: Timer?

    var goal: Goal90? { goals.first }
    var hero: Hero? { heroes.first }

    // 9 checkpoints from base to summit — fractions of image size (x, y)
    private let waypoints: [(Double, Double)] = [
        (0.50, 0.93),  // 0 — base
        (0.63, 0.83),  // 1
        (0.37, 0.73),  // 2
        (0.61, 0.63),  // 3
        (0.39, 0.53),  // 4
        (0.59, 0.43),  // 5
        (0.41, 0.33),  // 6
        (0.54, 0.26),  // 7
        (0.50, 0.20),  // 8 — summit
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let progress = goal?.progressPercentage ?? 0

                ZStack(alignment: .top) {
                    // Mountain background
                    Image("Mountain")
                        .resizable()
                        .scaledToFill()
                        .frame(width: w, height: h)
                        .clipped()

                    // Goal text near summit
                    if let goal {
                        VStack(spacing: 2) {
                            Text("🏆")
                                .font(.system(size: 22))
                            Text(goal.goalText)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .shadow(color: .black.opacity(0.9), radius: 3)
                                .frame(maxWidth: 140)
                        }
                        .padding(.top, h * 0.04 + 8)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }

                    // Checkpoint dots along the path
                    ForEach(0..<waypoints.count, id: \.self) { i in
                        let wp = waypoints[i]
                        let checkpointProgress = Double(i) / Double(waypoints.count - 1)
                        let passed = progress >= checkpointProgress
                        let isSummit = i == waypoints.count - 1

                        ZStack {
                            Circle()
                                .fill(passed ? Color.orange : Color(white: 0.15, opacity: 0.75))
                                .frame(width: isSummit ? 22 : 14, height: isSummit ? 22 : 14)
                                .shadow(color: passed ? Color.orange.opacity(0.6) : .clear, radius: 4)

                            if isSummit {
                                Text("🏆")
                                    .font(.system(size: 11))
                            } else if passed {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 7, weight: .black))
                                    .foregroundColor(.white)
                            }
                        }
                        .shadow(color: .black.opacity(0.5), radius: 2)
                        .position(x: wp.0 * w, y: wp.1 * h)
                    }

                    // Hero — animated, positioned along the path
                    if let hero {
                        let pos = heroPosition(progress: progress, in: geo.size)
                        Image(hero.heroClass.idleFrames[frameIndex % hero.heroClass.idleFrames.count])
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 44)
                            .shadow(color: .black.opacity(0.6), radius: 4)
                            .position(x: pos.x, y: pos.y)
                    }

                    // Bottom progress panel
                    VStack(spacing: 4) {
                        Spacer()
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                if let goal {
                                    Text("\(goal.daysCompleted) / 90 days")
                                        .font(.system(size: 18, weight: .black))
                                        .foregroundColor(.white)
                                    Text("\(goal.daysRemaining) days remaining")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(white: 0.6))
                                }
                            }
                            Spacer()
                            if let hero {
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(hero.points) pts")
                                        .font(.system(size: 18, weight: .black))
                                        .foregroundColor(.orange)
                                    Text(hero.name)
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(white: 0.6))
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(.ultraThinMaterial)
                    }
                }
            }
        }
        .onAppear {
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 0.10, repeats: true) { _ in
                frameIndex += 1
            }
        }
        .onDisappear { timer?.invalidate() }
    }

    /// Interpolates hero position along the path between waypoints.
    private func heroPosition(progress: Double, in size: CGSize) -> CGPoint {
        let t = max(0, min(1, progress)) * Double(waypoints.count - 1)
        let i = min(Int(t), waypoints.count - 2)
        let frac = t - Double(i)
        let a = waypoints[i]
        let b = waypoints[i + 1]
        let x = a.0 + (b.0 - a.0) * frac
        let y = a.1 + (b.1 - a.1) * frac
        return CGPoint(x: x * size.width, y: y * size.height)
    }
}
