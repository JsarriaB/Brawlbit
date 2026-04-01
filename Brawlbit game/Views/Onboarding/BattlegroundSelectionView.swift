import SwiftUI

struct BattlegroundSelectionView: View {
    @Binding var battleground: Battleground
    let onContinue: () -> Void

    private let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            VStack(spacing: 0) {

                // Header
                VStack(spacing: 6) {
                    Text("Choose your arena")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Text("Where will your battles take place?")
                        .font(.callout)
                        .foregroundColor(Color(white: 0.45))
                }
                .padding(.top, 52)
                .padding(.bottom, 28)

                // Grid
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(Battleground.allCases, id: \.self) { arena in
                        BattlegroundCard(
                            arena: arena,
                            isSelected: battleground == arena
                        ) { battleground = arena }
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                // CTA
                Button(action: onContinue) {
                    HStack(spacing: 8) {
                        Text("This is my arena")
                            .font(.system(size: 16, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 52)
            }
        }
    }
}

struct BattlegroundCard: View {
    let arena: Battleground
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                Image(arena.assetName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: 100)
                    .clipped()

                // Name overlay
                LinearGradient(
                    colors: [Color.black.opacity(0.75), Color.clear],
                    startPoint: .bottom,
                    endPoint: .center
                )

                Text(arena.displayName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 7)
            }
            .frame(height: 100)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ? Color.orange : Color(white: 1, opacity: 0.08),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}
