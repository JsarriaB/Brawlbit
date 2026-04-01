import SwiftUI
import SwiftData

struct CustomizationSettingsView: View {
    let hero: Hero
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Hero class ───────────────────────────────────────
                    sectionHeader("HERO CLASS")

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(HeroClass.allCases, id: \.self) { cls in
                            Button {
                                hero.heroClass = cls
                                try? modelContext.save()
                            } label: {
                                VStack(spacing: 6) {
                                    Image(cls.idleFrames[0])
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 64)
                                    Text(cls.displayName)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(hero.heroClass == cls ? .orange : Color(white: 0.5))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(hero.heroClass == cls ? Color.orange.opacity(0.12) : Color(white: 1, opacity: 0.05))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(hero.heroClass == cls ? Color.orange : Color.clear, lineWidth: 1.5)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)

                    divider()

                    // ── Arena ────────────────────────────────────────────
                    sectionHeader("ARENA")

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(Battleground.allCases, id: \.self) { arena in
                            Button {
                                hero.battleground = arena
                                try? modelContext.save()
                            } label: {
                                ZStack(alignment: .bottomLeading) {
                                    Image(arena.assetName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 80)
                                        .clipped()
                                    Text(arena.displayName)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(6)
                                }
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(hero.battleground == arena ? Color.orange : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
                .padding(.top, 24)
            }
        }
        .navigationTitle("Customization")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.orange)
            .tracking(1)
            .padding(.horizontal, 24)
            .padding(.bottom, 14)
    }

    @ViewBuilder
    private func divider() -> some View {
        Rectangle()
            .fill(Color(white: 1, opacity: 0.07))
            .frame(height: 1)
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
    }
}
