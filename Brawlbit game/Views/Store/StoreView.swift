import SwiftUI

struct StoreView: View {
    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    Text("Store")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.top, 52)
                        .padding(.bottom, 32)

                    sectionHeader("HEROES")

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(HeroClass.allCases, id: \.self) { cls in
                            VStack(spacing: 8) {
                                Image(cls.idleFrames[0])
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 64)
                                    .grayscale(1.0)
                                Text(cls.displayName)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(white: 0.35))
                                Text("Coming soon")
                                    .font(.system(size: 10))
                                    .foregroundColor(Color(white: 0.25))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(white: 1, opacity: 0.04))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)

                    divider()

                    sectionHeader("ARENAS")

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(Battleground.allCases, id: \.self) { arena in
                            ZStack(alignment: .bottomLeading) {
                                Image(arena.assetName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 70)
                                    .clipped()
                                    .grayscale(1.0)
                                Text(arena.displayName)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(Color(white: 0.5))
                                    .padding(6)
                            }
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(white: 0.15), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)

                    divider()

                    VStack(spacing: 8) {
                        Image(systemName: "bag.fill")
                            .font(.system(size: 32))
                            .foregroundColor(Color(white: 0.2))
                        Text("More content coming soon")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(white: 0.3))
                        Text("New heroes, arenas and monsters\nare on the way.")
                            .font(.system(size: 12))
                            .foregroundColor(Color(white: 0.22))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 36)
                    .padding(.bottom, 40)
                }
            }
        }
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
