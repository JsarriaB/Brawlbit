import SwiftUI

struct BattleChartView: View {
    let onContinue: () -> Void

    @State private var drawProgress: CGFloat = 0
    @State private var pointsVisible: [Bool] = [false, false, false, false]

    private let milestones: [(day: String, pct: String, x: CGFloat, y: CGFloat)] = [
        ("7d",  "5%",  0.08, 0.88),
        ("21d", "15%", 0.30, 0.72),
        ("66d", "34%", 0.68, 0.42),
        ("90d", "67%", 0.94, 0.10),
    ]

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            GlowBlobBackground()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer().frame(height: 20)

                        // Título
                        VStack(spacing: 8) {
                            Text("🔥 Consistency\nchanges everything!")
                                .font(.system(size: 26, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            Text("Warriors who complete 90 days\nimprove their consistency by 67%")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(Color(white: 0.5))
                                .multilineTextAlignment(.center)
                        }

                        // Gráfica
                        GeometryReader { geo in
                            let w = geo.size.width
                            let h = geo.size.height

                            ZStack {
                                // Área bajo la curva
                                HabitCurveArea(drawProgress: drawProgress)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.orange.opacity(0.25), Color.clear],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )

                                // Línea de la curva
                                HabitCurveLine(drawProgress: drawProgress)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.orange, Color(red: 0.9, green: 0.2, blue: 0.1)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                                    )

                                // Puntos de milestone
                                ForEach(milestones.indices, id: \.self) { i in
                                    let m = milestones[i]
                                    let px = m.x * w
                                    let py = m.y * h
                                    let isLast = i == milestones.count - 1

                                    ZStack {
                                        if isLast {
                                            Circle()
                                                .fill(Color.green)
                                                .frame(width: 22, height: 22)
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 10, weight: .black))
                                                .foregroundColor(.white)
                                        } else {
                                            Circle()
                                                .stroke(Color.orange, lineWidth: 2)
                                                .background(Circle().fill(Color(white: 0.1)))
                                                .frame(width: 16, height: 16)
                                        }
                                    }
                                    .position(x: px, y: py)
                                    .opacity(pointsVisible[i] ? 1 : 0)
                                    .scaleEffect(pointsVisible[i] ? 1 : 0.3)
                                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: pointsVisible[i])

                                    // Label
                                    VStack(spacing: 1) {
                                        Text(m.pct)
                                            .font(.system(size: 10, weight: .black, design: .monospaced))
                                            .foregroundColor(.white)
                                        Text(m.day)
                                            .font(.system(size: 9, design: .monospaced))
                                            .foregroundColor(Color(white: 0.45))
                                    }
                                    .position(x: px, y: py - 26)
                                    .opacity(pointsVisible[i] ? 1 : 0)
                                    .animation(.easeOut(duration: 0.3).delay(0.1), value: pointsVisible[i])
                                }

                                // Etiqueta ejes
                                Text("Consistency")
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundColor(Color(white: 0.3))
                                    .rotationEffect(.degrees(-90))
                                    .position(x: -14, y: h / 2)

                                Text("Battle days →")
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundColor(Color(white: 0.3))
                                    .position(x: w / 2, y: h + 14)
                            }
                        }
                        .frame(height: 200)
                        .padding(.horizontal, 36)
                        .padding(.bottom, 20)

                        // Leyenda
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 10, height: 10)
                            Text("Day 90 — Goal conquered ✓")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(Color(white: 0.5))
                        }

                        Spacer().frame(height: 8)
                    }
                    .padding(.horizontal, 24)
                }

                OnboardingCTAButton(title: "I can make it!", action: onContinue)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2)) { drawProgress = 1.0 }
            for i in milestones.indices {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4 + Double(i) * 0.45) {
                    pointsVisible[i] = true
                }
            }
        }
    }
}

// MARK: - Custom Shapes

private struct HabitCurveLine: Shape {
    var drawProgress: CGFloat
    var animatableData: CGFloat {
        get { drawProgress }
        set { drawProgress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        // Curva exponencial: 4 puntos de control
        path.move(to: CGPoint(x: 0, y: h))
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.05),
            control1: CGPoint(x: w * 0.3, y: h * 0.92),
            control2: CGPoint(x: w * 0.6, y: h * 0.55)
        )
        return path.trimmedPath(from: 0, to: drawProgress)
    }
}

private struct HabitCurveArea: Shape {
    var drawProgress: CGFloat
    var animatableData: CGFloat {
        get { drawProgress }
        set { drawProgress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let w = rect.width * drawProgress
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: 0, y: h))
        path.addCurve(
            to: CGPoint(x: w, y: h * 0.05 + (1 - drawProgress) * h * 0.95),
            control1: CGPoint(x: w * 0.3, y: h * 0.92),
            control2: CGPoint(x: w * 0.6, y: h * 0.55)
        )
        path.addLine(to: CGPoint(x: w, y: h))
        path.closeSubpath()
        return path
    }
}
