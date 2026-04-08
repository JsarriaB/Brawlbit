import SwiftUI
import SwiftData

struct GameModeSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    let hero: Hero

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.system(size: 42))
                            .foregroundColor(.blue)
                            .padding(.top, 32)
                        Text("Game Mode")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.white)
                        Text("Choose how revenge battles affect your daily score.")
                            .font(.system(size: 13))
                            .foregroundColor(Color(white: 0.45))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 8)

                    // Easy card
                    modeCard(
                        selected: hero.easyMode,
                        icon: "🌟",
                        title: "Easy",
                        description: "If you avenge a monster after the deadline, it still counts as a victory for the day. Progress is rewarded even when late.",
                        accentColor: .green
                    ) {
                        hero.easyMode = true
                        try? modelContext.save()
                    }

                    // Hard card
                    modeCard(
                        selected: !hero.easyMode,
                        icon: "💀",
                        title: "Hard",
                        description: "A missed deadline is a defeat, period. Avenging a monster earns points but won't save the day. Discipline or nothing.",
                        accentColor: .red
                    ) {
                        hero.easyMode = false
                        try? modelContext.save()
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("Game Mode")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func modeCard(
        selected: Bool,
        icon: String,
        title: String,
        description: String,
        accentColor: Color,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 14) {
                Text(icon)
                    .font(.system(size: 28))
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        if selected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(accentColor)
                                .font(.system(size: 20))
                        } else {
                            Circle()
                                .stroke(Color(white: 0.3), lineWidth: 1.5)
                                .frame(width: 20, height: 20)
                        }
                    }
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(Color(white: 0.5))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(white: selected ? 0.14 : 0.10))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(selected ? accentColor.opacity(0.5) : Color(white: 0.15), lineWidth: selected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
