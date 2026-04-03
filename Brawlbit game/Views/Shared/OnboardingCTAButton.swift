import SwiftUI

struct OnboardingCTAButton: View {
    let title: String
    var icon: String? = "arrow.right"
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                Group {
                    if isEnabled {
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.42, blue: 0.08),
                                Color(red: 0.88, green: 0.14, blue: 0.14)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        Color(white: 0.15)
                    }
                }
            )
            .foregroundColor(isEnabled ? .white : Color(white: 0.3))
            .cornerRadius(16)
        }
        .disabled(!isEnabled)
    }
}
