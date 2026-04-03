import SwiftUI

struct FeatureSlidesView: View {
    let onContinue: () -> Void

    @State private var currentSlide = 0
    @State private var autoAdvanceTimer: Timer?

    private let slides: [(title: String, subtitle: String, mockup: AnyView)] = [
        (
            "Turn your tasks\ninto epic battles",
            "Every pending habit is a monster. Defeat it before the deadline.",
            AnyView(TodayMockup())
        ),
        (
            "Climb your\n90-day mountain",
            "Every day won brings you closer to the top. Your progress, visualised.",
            AnyView(MountainMockup())
        )
    ]

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            GlowBlobBackground()

            VStack(spacing: 0) {
                // Slides
                TabView(selection: $currentSlide) {
                    ForEach(slides.indices, id: \.self) { i in
                        VStack(spacing: 20) {
                            Spacer()

                            // Mockup
                            slides[i].mockup
                                .frame(height: 260)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color(white: 0.18), lineWidth: 1)
                                )
                                .padding(.horizontal, 24)
                                .shadow(color: Color.orange.opacity(0.15), radius: 20, x: 0, y: 8)

                            // Texto
                            VStack(spacing: 8) {
                                Text(slides[i].title)
                                    .font(.system(size: 24, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)

                                Text(slides[i].subtitle)
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(Color(white: 0.5))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }

                            Spacer()
                        }
                        .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)

                // Dots
                HStack(spacing: 8) {
                    ForEach(slides.indices, id: \.self) { i in
                        Capsule()
                            .fill(currentSlide == i ? Color.orange : Color(white: 0.25))
                            .frame(width: currentSlide == i ? 20 : 7, height: 7)
                            .animation(.spring(response: 0.3), value: currentSlide)
                    }
                }
                .padding(.bottom, 20)

                OnboardingCTAButton(title: "Continue", action: onContinue)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 52)
            }
        }
        .onAppear { startAutoAdvance() }
        .onDisappear { autoAdvanceTimer?.invalidate() }
    }

    private func startAutoAdvance() {
        autoAdvanceTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { _ in
            withAnimation { currentSlide = (currentSlide + 1) % slides.count }
        }
    }
}

// MARK: - Today Mockup

private struct TodayMockup: View {
    var body: some View {
        ZStack {
            Color(white: 0.1)
            VStack(alignment: .leading, spacing: 0) {
                Text("⚔️  TODAY")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
                    .tracking(2)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                ForEach(mockTasks, id: \.name) { task in
                    MockTaskRow(task: task)
                    if task.name != mockTasks.last?.name {
                        Divider().background(Color(white: 0.15)).padding(.horizontal, 16)
                    }
                }
                Spacer()
            }
        }
    }

    private let mockTasks: [(name: String, emoji: String, time: String, done: Bool)] = [
        ("Study", "📚", "14:00", true),
        ("Exercise", "🐉", "17:00", false),
        ("Read", "👹", "21:00", false),
    ]
}

private struct MockTaskRow: View {
    let task: (name: String, emoji: String, time: String, done: Bool)

    var body: some View {
        HStack(spacing: 12) {
            Text(task.emoji)
                .font(.system(size: 20))
            Text(task.name)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(task.done ? Color(white: 0.4) : .white)
            Spacer()
            Text(task.time)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(Color(white: 0.4))
            Image(systemName: task.done ? "checkmark.circle.fill" : "circle")
                .foregroundColor(task.done ? .green : Color(white: 0.3))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - Mountain Mockup

private struct MountainMockup: View {
    var body: some View {
        ZStack {
            Color(white: 0.1)
            VStack(spacing: 16) {
                Text("🏔️")
                    .font(.system(size: 52))

                Text("47 / 90 days")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(white: 0.2))
                            .frame(height: 10)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(LinearGradient(
                                colors: [.orange, Color(red: 0.9, green: 0.2, blue: 0.1)],
                                startPoint: .leading, endPoint: .trailing
                            ))
                            .frame(width: geo.size.width * 0.52, height: 10)
                    }
                }
                .frame(height: 10)
                .padding(.horizontal, 32)

                Text("43 days to the top")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(Color(white: 0.5))
            }
            .padding(24)
        }
    }
}
