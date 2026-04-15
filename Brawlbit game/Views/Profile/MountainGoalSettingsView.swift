import SwiftUI
import SwiftData

struct MountainGoalSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var goals: [Goal90]

    var goal: Goal90? { goals.first }

    @State private var editingText = false
    @State private var textInput = ""
    @State private var showResetConfirm = false

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "mountain.2.fill")
                            .font(.system(size: 42))
                            .foregroundColor(.orange)
                            .padding(.top, 32)
                        Text("Mountain Goal")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.white)
                        Text("Edit your 90-day challenge or start fresh.")
                            .font(.system(size: 13))
                            .foregroundColor(Color(white: 0.45))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 8)

                    // Current goal card
                    if let goal {
                        VStack(alignment: .leading, spacing: 16) {

                            // Goal text section
                            VStack(alignment: .leading, spacing: 10) {
                                Text("CURRENT GOAL")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(white: 0.35))
                                    .tracking(1)

                                if editingText {
                                    VStack(spacing: 12) {
                                        TextField("Describe your 90-day challenge", text: $textInput, axis: .vertical)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                            .tint(.orange)
                                            .lineLimit(3...6)
                                            .padding(14)
                                            .background(Color(white: 0.15))
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.orange.opacity(0.4), lineWidth: 1)
                                            )

                                        HStack(spacing: 12) {
                                            Button("Cancel") {
                                                editingText = false
                                            }
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(white: 0.4))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color(white: 0.12))
                                            .cornerRadius(10)

                                            Button("Save") {
                                                let trimmed = textInput.trimmingCharacters(in: .whitespaces)
                                                if !trimmed.isEmpty {
                                                    goal.goalText = trimmed
                                                    try? modelContext.save()
                                                }
                                                editingText = false
                                            }
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color.orange)
                                            .cornerRadius(10)
                                            .disabled(textInput.trimmingCharacters(in: .whitespaces).isEmpty)
                                        }
                                    }
                                } else {
                                    Button {
                                        textInput = goal.goalText
                                        editingText = true
                                    } label: {
                                        HStack(alignment: .top, spacing: 10) {
                                            Text("\"")
                                                .font(.system(size: 28, weight: .black))
                                                .foregroundColor(.orange)
                                                .offset(y: -4)
                                            Text(goal.goalText)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.leading)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            Image(systemName: "pencil")
                                                .font(.system(size: 13))
                                                .foregroundColor(Color(white: 0.35))
                                        }
                                        .padding(16)
                                        .background(Color(white: 0.12))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color(white: 0.18), lineWidth: 1)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            // Progress info
                            VStack(alignment: .leading, spacing: 10) {
                                Text("PROGRESS")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(white: 0.35))
                                    .tracking(1)

                                HStack(spacing: 0) {
                                    statCell(value: "\(goal.daysCompleted)", label: "Days won")
                                    Divider()
                                        .background(Color(white: 0.2))
                                        .frame(height: 40)
                                    statCell(value: "\(goal.daysRemaining)", label: "Days left")
                                    Divider()
                                        .background(Color(white: 0.2))
                                        .frame(height: 40)
                                    statCell(value: "\(Int(goal.progressPercentage * 100))%", label: "Complete")
                                }
                                .padding(.vertical, 14)
                                .background(Color(white: 0.12))
                                .cornerRadius(12)

                                // Progress bar
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color(white: 0.18))
                                            .frame(height: 6)
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.orange)
                                            .frame(width: geo.size.width * goal.progressPercentage, height: 6)
                                    }
                                }
                                .frame(height: 6)
                            }

                            // Reset section
                            VStack(alignment: .leading, spacing: 10) {
                                Text("START OVER")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color(white: 0.35))
                                    .tracking(1)

                                Button {
                                    showResetConfirm = true
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "arrow.counterclockwise.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.red)
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text("Reset mountain to day 0")
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(.white)
                                            Text("Your battle history and hero progress are kept.")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color(white: 0.40))
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color(white: 0.3))
                                    }
                                    .padding(16)
                                    .background(Color(white: 0.12))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.red.opacity(0.25), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 40)
                }
            }
        }
        .navigationTitle("Mountain Goal")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Reset mountain to day 0?",
            isPresented: $showResetConfirm,
            titleVisibility: .visible
        ) {
            Button("Reset", role: .destructive) {
                goal?.daysCompleted = 0
                try? modelContext.save()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your hero will return to the base of the mountain. This cannot be undone.")
        }
    }

    @ViewBuilder
    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .black))
                .foregroundColor(.orange)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color(white: 0.40))
        }
        .frame(maxWidth: .infinity)
    }
}
