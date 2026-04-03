import SwiftUI

struct AnalyzingView: View {
    let onComplete: () -> Void

    @State private var progress: CGFloat = 0
    @State private var displayPercent: Int = 0
    @State private var phraseIndex: Int = 0
    @State private var phraseOpacity: Double = 1

    private let phrases = [
        "Analysing your answers...",
        "Identifying your patterns...",
        "Calculating your battle level...",
        "Preparing your 90-day plan...",
        "Almost ready, warrior! ⚔️"
    ]

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            GlowBlobBackground()

            VStack(spacing: 32) {
                Spacer()

                // Anillo de progreso
                ZStack {
                    Circle()
                        .stroke(Color(white: 0.15), lineWidth: 6)
                        .frame(width: 160, height: 160)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            AngularGradient(
                                colors: [Color.orange, Color(red: 0.9, green: 0.2, blue: 0.1), Color.orange],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90))

                    Text("\(displayPercent)%")
                        .font(.system(size: 44, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                }

                // Título + frase rotante
                VStack(spacing: 10) {
                    Text("Forging your\nwarrior profile")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text(phrases[phraseIndex])
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(Color(white: 0.5))
                        .opacity(phraseOpacity)
                        .animation(.easeInOut(duration: 0.3), value: phraseOpacity)
                }

                Spacer()
            }
            .padding(.horizontal, 32)
        }
        .onAppear { startAnalysis() }
    }

    private func startAnalysis() {
        // Animar progreso 0 → 1 en 4s
        withAnimation(.easeInOut(duration: 4.0)) { progress = 1.0 }

        // Contador numérico
        let steps = 40
        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * (4.0 / Double(steps))) {
                displayPercent = Int(Double(i) / Double(steps) * 100)
            }
        }

        // Rotar frases
        for i in 0..<phrases.count {
            let delay = Double(i) * 0.85
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation { phraseOpacity = 0 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    phraseIndex = i
                    withAnimation { phraseOpacity = 1 }
                }
            }
        }

        // Continuar al terminar
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.4) { onComplete() }
    }
}
