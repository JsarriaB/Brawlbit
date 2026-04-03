import SwiftUI

struct NewChallengeSheet: View {
    let onConfirm: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var goalText = ""

    var body: some View {
        ZStack {
            Color(white: 0.1).ignoresSafeArea()

            VStack(spacing: 0) {
                // Handle
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(white: 0.28))
                    .frame(width: 36, height: 4)
                    .padding(.top, 14)
                    .padding(.bottom, 28)

                Text("New Challenge")
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(.white)
                    .padding(.bottom, 10)

                Text("90 more days. A new goal.\nWhat will you conquer next?")
                    .font(.system(size: 14))
                    .foregroundColor(Color(white: 0.45))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 36)

                TextField("My new goal…", text: $goalText)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .tint(.orange)
                    .padding(16)
                    .background(Color(white: 0.16))
                    .cornerRadius(12)
                    .padding(.horizontal, 24)

                Spacer()

                Button {
                    let trimmed = goalText.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty else { return }
                    onConfirm(trimmed)
                } label: {
                    Text("Start")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(goalText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.orange.opacity(0.4) : Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .disabled(goalText.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
}
