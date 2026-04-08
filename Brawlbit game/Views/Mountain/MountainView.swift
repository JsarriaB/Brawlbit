import SwiftUI
import SwiftData

struct MountainView: View {
    @Query private var goals: [Goal90]
    @Query private var heroes: [Hero]

    @State private var heroImage: String = ""
    @State private var heroWaitTimer: Timer?
    @State private var heroAnimTimer: Timer?

    var goal: Goal90? { goals.first }
    var hero: Hero? { heroes.first }

    // 90 waypoints grabados a mano sobre la imagen. Index 0 = day 1, index 89 = day 90.
    private let waypoints: [(Double, Double)] = [
        (0.380, 0.977),  // 1
        (0.457, 0.954),  // 2
        (0.513, 0.953),  // 3
        (0.585, 0.940),  // 4
        (0.646, 0.935),  // 5
        (0.723, 0.918),  // 6
        (0.595, 0.886),  // 7
        (0.536, 0.883),  // 8
        (0.467, 0.874),  // 9
        (0.401, 0.847),  // 10
        (0.375, 0.841),  // 11
        (0.338, 0.836),  // 12
        (0.303, 0.824),  // 13
        (0.279, 0.803),  // 14
        (0.300, 0.790),  // 15
        (0.345, 0.787),  // 16
        (0.378, 0.783),  // 17
        (0.407, 0.786),  // 18
        (0.439, 0.780),  // 19
        (0.483, 0.766),  // 20
        (0.551, 0.750),  // 21
        (0.590, 0.748),  // 22
        (0.628, 0.735),  // 23
        (0.653, 0.733),  // 24
        (0.678, 0.724),  // 25
        (0.701, 0.712),  // 26
        (0.711, 0.691),  // 27
        (0.694, 0.682),  // 28
        (0.663, 0.680),  // 29
        (0.609, 0.667),  // 30
        (0.563, 0.657),  // 31
        (0.535, 0.649),  // 32
        (0.513, 0.648),  // 33
        (0.472, 0.640),  // 34
        (0.447, 0.638),  // 35
        (0.410, 0.631),  // 36
        (0.381, 0.619),  // 37
        (0.369, 0.609),  // 38
        (0.415, 0.579),  // 39
        (0.488, 0.576),  // 40
        (0.543, 0.556),  // 41
        (0.567, 0.556),  // 42
        (0.595, 0.547),  // 43
        (0.624, 0.546),  // 44
        (0.650, 0.543),  // 45
        (0.679, 0.535),  // 46
        (0.711, 0.526),  // 47
        (0.725, 0.510),  // 48
        (0.704, 0.498),  // 49
        (0.657, 0.487),  // 50
        (0.604, 0.471),  // 51
        (0.580, 0.467),  // 52
        (0.559, 0.461),  // 53
        (0.536, 0.459),  // 54
        (0.508, 0.455),  // 55
        (0.477, 0.456),  // 56
        (0.452, 0.451),  // 57
        (0.404, 0.439),  // 58
        (0.400, 0.419),  // 59
        (0.452, 0.404),  // 60
        (0.507, 0.383),  // 61
        (0.527, 0.377),  // 62
        (0.551, 0.373),  // 63
        (0.575, 0.372),  // 64
        (0.595, 0.374),  // 65
        (0.623, 0.367),  // 66
        (0.653, 0.362),  // 67
        (0.663, 0.362),  // 68
        (0.677, 0.349),  // 69
        (0.643, 0.338),  // 70
        (0.588, 0.324),  // 71
        (0.567, 0.319),  // 72
        (0.542, 0.314),  // 73
        (0.515, 0.309),  // 74
        (0.494, 0.304),  // 75
        (0.512, 0.293),  // 76
        (0.541, 0.289),  // 77
        (0.572, 0.284),  // 78
        (0.608, 0.271),  // 79
        (0.579, 0.248),  // 80
        (0.544, 0.234),  // 81
        (0.522, 0.230),  // 82
        (0.494, 0.223),  // 83
        (0.480, 0.207),  // 84
        (0.509, 0.193),  // 85
        (0.532, 0.188),  // 86
        (0.556, 0.175),  // 87
        (0.536, 0.164),  // 88
        (0.525, 0.147),  // 89
        (0.536, 0.119),  // 90
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let daysCompleted = goal?.daysCompleted ?? 0
                let wps = waypoints

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

                    // Hero — snaps to exact day waypoint
                    if let hero {
                        let heroWp: (Double, Double) = wps[min(89, max(0, daysCompleted - 1))]
                        Image(heroImage.isEmpty ? (hero.heroClass.idleFrames.first ?? "") : heroImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .shadow(color: .black.opacity(0.6), radius: 4)
                            .position(x: heroWp.0 * w, y: heroWp.1 * h - 40)
                    }

                    // Right margin HUD
                    VStack(alignment: .trailing, spacing: 14) {
                        if let goal {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(goal.daysCompleted)/90")
                                    .font(.system(size: 20, weight: .black))
                                    .foregroundColor(.white)
                                Text("days")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color(white: 0.55))
                            }
                        }
                        if let hero {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(hero.points) pts")
                                    .font(.system(size: 20, weight: .black))
                                    .foregroundColor(.orange)
                                Text(hero.name)
                                    .font(.system(size: 11))
                                    .foregroundColor(Color(white: 0.55))
                            }
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(Color(white: 0, opacity: 0.45))
                    .cornerRadius(12)
                    .padding(.trailing, 16)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .padding(.bottom, 60)
                }
            }
        }
        .onAppear {
            if let h = hero {
                heroImage = h.heroClass.idleFrames[0]
            }
            startAmbientHero()
        }
        .onDisappear {
            heroWaitTimer?.invalidate()
            heroAnimTimer?.invalidate()
        }
        .onChange(of: hero?.heroClass) {
            if let h = hero { heroImage = h.heroClass.idleFrames[0] }
            startAmbientHero()
        }
    }

    private func startAmbientHero() {
        heroWaitTimer?.invalidate()
        heroAnimTimer?.invalidate()
        guard let h = hero else { return }
        let idle = h.heroClass.idleFrames[0]
        let frames = h.heroClass.jumpFrames
        heroWaitTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { _ in
            var idx = 0
            heroImage = frames[0]
            heroAnimTimer = Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true) { t in
                idx += 1
                if idx < frames.count {
                    heroImage = frames[idx]
                } else {
                    t.invalidate()
                    heroImage = idle
                    startAmbientHero()
                }
            }
        }
    }
}

#Preview {
    MountainView()
}
