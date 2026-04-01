import SwiftUI
import SwiftData

struct GoalSetupView: View {
    @Environment(\.modelContext) private var modelContext
    let onContinue: () -> Void

    @State private var goalText: String = ""

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 14) {
                    Text("🏔️")
                        .font(.system(size: 60))

                    Text("What awaits you\nat the top?")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    Text("After 90 days of battles,\nwhat will you have conquered?")
                        .font(.callout)
                        .foregroundColor(Color(white: 0.45))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 32)

                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    Text("YOUR 90-DAY GOAL")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.orange)
                        .tracking(1)

                    TextField("Become more disciplined...", text: $goalText)
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

                Button(action: saveGoal) {
                    HStack(spacing: 8) {
                        Text("This is my goal")
                            .font(.system(size: 16, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(goalText.trimmingCharacters(in: .whitespaces).isEmpty
                        ? Color(white: 0.15) : Color.orange)
                    .foregroundColor(goalText.trimmingCharacters(in: .whitespaces).isEmpty
                        ? Color(white: 0.3) : .white)
                    .cornerRadius(12)
                }
                .disabled(goalText.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.horizontal, 28)
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
