import SwiftUI
import SwiftData

struct MountainView: View {
    @Query private var goals: [Goal90]
    @Query private var heroes: [Hero]

    var goal: Goal90? { goals.first }
    var hero: Hero? { heroes.first }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                ZStack(alignment: .top) {
                    // Mountain background — fills the screen
                    Image("Mountain")
                        .resizable()
                        .scaledToFill()
                        .frame(width: w, height: h)
                        .clipped()

                    // Goal text at the summit
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

                    // Hero on the path
                    if let hero, let goal {
                        let pos = heroPosition(progress: goal.progressPercentage, in: geo.size)
                        Image(hero.heroClass.idleFrames[0])
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 44)
                            .shadow(color: .black.opacity(0.6), radius: 4)
                            .position(x: pos.x, y: pos.y)
                    }

                    // Progress info — bottom panel
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
        // no ignoresSafeArea needed — ProgresoView positions content below the header
    }

    /// Interpolates the hero's position along the mountain path.
    /// Waypoints are expressed as (x, y) fractions of the image size (0,0 = top-left).
    private func heroPosition(progress: Double, in size: CGSize) -> CGPoint {
        // Path waypoints from bottom of mountain to summit
        let waypoints: [(Double, Double)] = [
            (0.50, 0.93),  // start — base of path
            (0.62, 0.80),  // first bend right
            (0.38, 0.67),  // bend left
            (0.60, 0.54),  // bend right
            (0.40, 0.41),  // bend left
            (0.55, 0.28),  // near top right
            (0.50, 0.20),  // summit (shifted down to clear header bar)
        ]

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
