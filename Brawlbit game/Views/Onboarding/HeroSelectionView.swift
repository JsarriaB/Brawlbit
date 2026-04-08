import SwiftUI

struct HeroSelectionView: View {
    @Binding var heroName: String
    @Binding var heroClass: HeroClass
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            GlowBlobBackground()
            VStack(spacing: 0) {

                // Header
                VStack(spacing: 6) {
                    Text("⚔️ Choose your warrior")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text("Who will lead your battles?")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(Color(white: 0.45))
                    Text("🪙 The rest can be unlocked later with coins")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(Color(white: 0.3))
                        .padding(.top, 2)
                }
                .padding(.top, 52)
                .padding(.bottom, 24)

                // Hero pager — dots hidden, custom ones below
                TabView(selection: $heroClass) {
                    ForEach(HeroClass.allCases, id: \.self) { option in
                        VStack {
                            AnimatedHeroCell(
                                heroClass: option,
                                isSelected: heroClass == option
                            ) { heroClass = option }
                        }
                        .frame(maxWidth: .infinity)
                        .tag(option)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 360)

                // Custom dot indicator
                HStack(spacing: 8) {
                    ForEach(HeroClass.allCases, id: \.self) { option in
                        Capsule()
                            .fill(heroClass == option ? Color.orange : Color(white: 0.3))
                            .frame(width: heroClass == option ? 20 : 7, height: 7)
                            .animation(.spring(response: 0.3), value: heroClass)
                    }
                }
                .padding(.top, 14)

                Spacer()

                // Name + CTA
                VStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("YOUR HERO'S NAME")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.orange)
                            .tracking(1)

                        TextField("Enter a name...", text: $heroName)
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

                    OnboardingCTAButton(
                        title: "This is my warrior!",
                        isEnabled: !heroName.trimmingCharacters(in: .whitespaces).isEmpty,
                        action: onContinue
                    )
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 48)
            }
        }
    }
}

struct AnimatedHeroCell: View {
    let heroClass: HeroClass
    let isSelected: Bool
    let onTap: () -> Void

    @State private var frameIndex: Int = 0
    @State private var isAttacking: Bool = false
    @State private var timer: Timer?

    var currentFrames: [String] {
        isAttacking ? heroClass.attackFrames : heroClass.idleFrames
    }

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(white: isSelected ? 0.14 : 0.09))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                isSelected ? Color.orange : Color(white: 1, opacity: 0.08),
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    )

                Image(currentFrames[frameIndex])
                    .resizable()
                    .scaledToFit()
                    .padding(28)
                    .offset(x: 10)
            }
            .frame(width: 260, height: 280)
            .onTapGesture {
                onTap()
                playAttack()
            }

            Text(heroClass.displayName.uppercased())
                .font(.system(size: 12, weight: .bold))
                .tracking(2)
                .foregroundColor(isSelected ? .orange : Color(white: 0.4))
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
        timer = Timer.scheduledTimer(withTimeInterval: 0.07, repeats: true) { _ in
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
