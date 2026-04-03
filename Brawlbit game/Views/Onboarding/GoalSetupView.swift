import SwiftUI
import SwiftData

struct GoalSetupView: View {
    @Environment(\.modelContext) private var modelContext
    let onContinue: () -> Void

    @State private var goalText: String = ""

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            GlowBlobBackground()
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 14) {
                    Text("🏔️")
                        .font(.system(size: 60))

                    Text("¿Qué te espera\nen la cima?")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    Text("Tras 90 días de batalla,\n¿qué habrás conquistado?")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(Color(white: 0.45))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 32)

                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    Text("TU META DE 90 DÍAS")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.orange)
                        .tracking(1)

                    TextField("Ser más disciplinado...", text: $goalText)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .tint(.orange)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color(white: 1, opacity: 0.06))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(white: 1, opacity: 0.1), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 14)

                OnboardingCTAButton(
                    title: "¡Esta es mi meta! 🏔️",
                    isEnabled: !goalText.trimmingCharacters(in: .whitespaces).isEmpty,
                    action: saveGoal
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 52)
            }
        }
    }

    private func saveGoal() {
        let goal = Goal90(goalText: goalText)
        modelContext.insert(goal)
        try? modelContext.save()
        onContinue()
    }
}
