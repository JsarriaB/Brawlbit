import SwiftUI

struct QuizOption: Identifiable {
    let id = UUID()
    let emoji: String
    let text: String
}

struct QuizView: View {
    let question: String
    let options: [QuizOption]
    let progress: Double      // 0.0–1.0 para la barra de progreso
    let multiSelect: Bool
    let onAnswer: ([Int]) -> Void  // índices seleccionados

    @State private var selected: Set<Int> = []

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()

            VStack(spacing: 0) {
                // Barra de progreso
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(white: 0.15))
                            .frame(height: 4)
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: geo.size.width * progress, height: 4)
                            .animation(.easeOut(duration: 0.4), value: progress)
                    }
                }
                .frame(height: 4)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Pregunta
                        Text(question)
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .lineSpacing(4)
                            .padding(.top, 36)

                        if multiSelect {
                            Text("Select all that apply")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(Color(white: 0.4))
                                .padding(.top, -16)
                        }

                        // Opciones
                        VStack(spacing: 10) {
                            ForEach(options.indices, id: \.self) { i in
                                QuizOptionRow(
                                    emoji: options[i].emoji,
                                    text: options[i].text,
                                    isSelected: selected.contains(i)
                                ) {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        if multiSelect {
                                            if selected.contains(i) { selected.remove(i) }
                                            else { selected.insert(i) }
                                        } else {
                                            selected = [i]
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }

                // CTA
                OnboardingCTAButton(
                    title: "Continue",
                    isEnabled: !selected.isEmpty
                ) {
                    onAnswer(Array(selected).sorted())
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }
}

struct QuizOptionRow: View {
    let emoji: String
    let text: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Text(emoji)
                    .font(.system(size: 22))
                Text(text)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.orange : Color(white: 0.3), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(isSelected ? Color.orange.opacity(0.12) : Color(white: 0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.orange.opacity(0.6) : Color.clear, lineWidth: 1.5)
            )
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
    }
}
