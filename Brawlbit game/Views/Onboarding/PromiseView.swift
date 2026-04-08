import SwiftUI
import UserNotifications

struct PromiseView: View {
    let onContinue: () -> Void

    @State private var showingManuscript    = false
    @State private var showingNotifications = false
    @State private var itemsVisible: [Bool] = [false, false, false, false, false]

    private let vows = [
        ("⚔️", "I will defeat every monster before the deadline"),
        ("🏔️", "I will climb the 90-day mountain"),
        ("🔥", "I will keep my winning streak"),
        ("🏆", "I will fight every day without excuses"),
        ("🚫", "I will not fake victories or mark done what I haven't done"),
    ]

    var body: some View {
        if showingNotifications {
            NotificationsPromptView(onContinue: onContinue)
        } else if showingManuscript {
            ManuscriptView {
                withAnimation { showingNotifications = true }
            }
        } else {
            promiseBody
        }
    }

    private var promiseBody: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            GlowBlobBackground()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 28) {
                    // Título
                    VStack(spacing: 8) {
                        Text("⚔️")
                            .font(.system(size: 48))
                        Text("Warrior's Oath")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        Text("Before you begin your adventure,\ntake this oath.")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(Color(white: 0.45))
                            .multilineTextAlignment(.center)
                    }

                    // Votos
                    VStack(spacing: 12) {
                        ForEach(vows.indices, id: \.self) { i in
                            HStack(spacing: 14) {
                                Text(vows[i].0)
                                    .font(.system(size: 22))
                                    .frame(width: 32)
                                Text(vows[i].1)
                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 18))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(Color(white: 0.11))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.orange.opacity(0.25), lineWidth: 1)
                            )
                            .cornerRadius(14)
                            .opacity(itemsVisible[i] ? 1 : 0)
                            .offset(y: itemsVisible[i] ? 0 : 16)
                            .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(i) * 0.2), value: itemsVisible[i])
                        }
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()

                OnboardingCTAButton(title: "I swear it! 💪", icon: nil) {
                    withAnimation { showingManuscript = true }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 52)
            }
        }
        .onAppear {
            for i in vows.indices {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.25 + 0.3) {
                    itemsVisible[i] = true
                }
            }
        }
    }
}

// MARK: - Signature canvas

private struct SignatureCanvasView: View {
    @Binding var lines: [[CGPoint]]
    @State private var currentLine: [CGPoint] = []

    var body: some View {
        Canvas { ctx, size in
            for line in lines + (currentLine.isEmpty ? [] : [currentLine]) {
                var path = Path()
                guard line.count > 1 else { continue }
                path.move(to: line[0])
                for pt in line.dropFirst() { path.addLine(to: pt) }
                ctx.stroke(path,
                           with: .color(Color(red: 0.1, green: 0.05, blue: 0.3)),
                           style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { v in currentLine.append(v.location) }
                .onEnded { _ in
                    if !currentLine.isEmpty { lines.append(currentLine) }
                    currentLine = []
                }
        )
    }
}

// MARK: - Manuscript signing screen

private struct ManuscriptView: View {
    let onContinue: () -> Void

    @State private var signatureLines: [[CGPoint]] = []
    @State private var scrollVisible = false

    private var hasSigned: Bool { !signatureLines.isEmpty }

    private let oathLines = [
        "I hereby swear, on my honor as a warrior,",
        "that I will fight every day without excuses,",
        "that I will not lie about my progress,",
        "and that I will never mark done",
        "what I have not truly accomplished.",
        "",
        "My word is my blade.",
    ]

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            GlowBlobBackground()

            VStack(spacing: 0) {
                Spacer()

                Text("✍️")
                    .font(.system(size: 44))
                    .padding(.bottom, 12)

                Text("Sign the Oath")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.bottom, 6)

                Text("Sign with your finger to seal the oath.")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(Color(white: 0.4))
                    .padding(.bottom, 28)

                // Parchment scroll
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0.96, green: 0.91, blue: 0.78))
                        .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 4)

                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(oathLines, id: \.self) { line in
                            Text(line)
                                .font(.system(size: 14, design: .serif))
                                .foregroundColor(Color(red: 0.15, green: 0.10, blue: 0.05))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Divider()
                            .background(Color(red: 0.3, green: 0.2, blue: 0.1).opacity(0.4))
                            .padding(.top, 12)

                        HStack(alignment: .bottom) {
                            Text("Signed:")
                                .font(.system(size: 11, weight: .semibold, design: .serif))
                                .foregroundColor(Color(red: 0.35, green: 0.22, blue: 0.10))

                            Spacer()

                            if hasSigned {
                                Button {
                                    signatureLines = []
                                } label: {
                                    Text("Clear")
                                        .font(.system(size: 11, design: .serif))
                                        .foregroundColor(Color(red: 0.5, green: 0.3, blue: 0.15))
                                }
                            }
                        }
                        .padding(.top, 4)

                        // Drawing area
                        ZStack(alignment: .center) {
                            Rectangle()
                                .fill(Color(red: 0.93, green: 0.87, blue: 0.70))
                                .frame(height: 150)
                                .cornerRadius(8)

                            if !hasSigned {
                                Text("Sign here")
                                    .font(.system(size: 15, design: .serif))
                                    .foregroundColor(Color(red: 0.6, green: 0.45, blue: 0.25).opacity(0.5))
                            }

                            SignatureCanvasView(lines: $signatureLines)
                                .frame(height: 150)
                                .cornerRadius(8)
                        }

                        Rectangle()
                            .fill(Color(red: 0.3, green: 0.2, blue: 0.1).opacity(0.35))
                            .frame(height: 1)
                    }
                    .padding(24)
                }
                .padding(.horizontal, 28)
                .offset(y: scrollVisible ? 0 : 30)
                .opacity(scrollVisible ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: scrollVisible)

                Spacer()

                OnboardingCTAButton(
                    title: "I sign my oath ✍️",
                    isEnabled: hasSigned,
                    action: onContinue
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 52)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                scrollVisible = true
            }
        }
    }
}

// MARK: - Notifications prompt

private struct NotificationsPromptView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            GlowBlobBackground()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 24) {
                    Text("🔔")
                        .font(.system(size: 52))

                    VStack(spacing: 8) {
                        Text("Don't miss a single battle")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text("Enable reminders and we'll warn you\nbefore the monster defeats you.")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(Color(white: 0.45))
                            .multilineTextAlignment(.center)
                    }

                    // Mockup de notificación
                    HStack(spacing: 12) {
                        Image(systemName: "app.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("⚔️ Medusa · 5 minutes remaining")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("FINAL WARNING — attack now! ⚠️")
                                .font(.system(size: 11, design: .rounded))
                                .foregroundColor(Color(white: 0.5))
                        }
                        Spacer()
                        Text("Now")
                            .font(.system(size: 10))
                            .foregroundColor(Color(white: 0.4))
                    }
                    .padding(14)
                    .background(Color(white: 0.14))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                }

                Spacer()

                VStack(spacing: 12) {
                    OnboardingCTAButton(title: "Enable reminders 🔔", icon: nil) {
                        UNUserNotificationCenter.current()
                            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
                                DispatchQueue.main.async { onContinue() }
                            }
                    }

                    Button("Not now") {
                        onContinue()
                    }
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(Color(white: 0.35))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 52)
            }
        }
    }
}
