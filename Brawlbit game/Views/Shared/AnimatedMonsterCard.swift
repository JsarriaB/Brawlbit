import SwiftUI

struct AnimatedMonsterCard: View {
    let monsterType: MonsterType
    let isSelected: Bool
    let onTap: () -> Void

    @State private var frameIndex: Int = 0
    @State private var isAttacking: Bool = false
    @State private var timer: Timer?

    var currentFrames: [String] {
        isAttacking ? monsterType.attackFrames : monsterType.idleFrames
    }

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(isSelected
                        ? Color.orange.opacity(0.12)
                        : Color(white: 1, opacity: 0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                isSelected ? Color.orange : Color.clear,
                                lineWidth: 1.5
                            )
                    )

                Image(currentFrames[frameIndex])
                    .resizable()
                    .scaledToFit()
                    .padding(16)
            }
            .frame(width: 130, height: 130)
            .onTapGesture {
                onTap()
                playAttack()
            }

            Text(monsterType.displayName)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .orange : Color(white: 0.45))
        }
        .onDisappear { timer?.invalidate() }
        .onChange(of: isSelected) { _, selected in
            if selected { playAttack() }
        }
    }

    private func playAttack() {
        timer?.invalidate()
        isAttacking = true
        frameIndex = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.08, repeats: true) { _ in
            if frameIndex < currentFrames.count - 1 {
                frameIndex += 1
            } else {
                timer?.invalidate()
                isAttacking = false
                frameIndex = 0
            }
        }
    }
}
