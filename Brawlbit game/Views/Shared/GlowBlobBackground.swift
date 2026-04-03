import SwiftUI

struct GlowBlobBackground: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            // Blob 1 — naranja
            Circle()
                .fill(Color(red: 1.0, green: 0.45, blue: 0.1).opacity(0.13))
                .frame(width: 320, height: 320)
                .blur(radius: 80)
                .offset(x: -80, y: -120)
                .scaleEffect(pulse ? 1.04 : 0.96)
                .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: pulse)

            // Blob 2 — rojo
            Circle()
                .fill(Color(red: 0.85, green: 0.1, blue: 0.2).opacity(0.10))
                .frame(width: 280, height: 280)
                .blur(radius: 80)
                .offset(x: 100, y: 80)
                .scaleEffect(pulse ? 0.97 : 1.03)
                .animation(.easeInOut(duration: 3.8).repeatForever(autoreverses: true), value: pulse)

            // Blob 3 — púrpura
            Circle()
                .fill(Color(red: 0.45, green: 0.1, blue: 0.75).opacity(0.08))
                .frame(width: 240, height: 240)
                .blur(radius: 70)
                .offset(x: 40, y: -220)
                .scaleEffect(pulse ? 1.06 : 0.94)
                .animation(.easeInOut(duration: 4.2).repeatForever(autoreverses: true), value: pulse)
        }
        .ignoresSafeArea()
        .onAppear { pulse = true }
    }
}
