import SwiftUI

struct AboutView: View {
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    // Replace with real App Store ID once the app is published
    private let appStoreId = "XXXXXXXXXX"

    var body: some View {
        ZStack {
            Color(white: 0.07).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    sectionHeader("APP")

                    VStack(spacing: 0) {
                        infoRow(
                            icon: "info.circle.fill", iconColor: Color(white: 0.4),
                            title: "Version",
                            value: "\(appVersion) (\(buildNumber))"
                        )
                    }
                    .background(Color(white: 0.12))
                    .cornerRadius(14)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)

                    sectionHeader("SUPPORT")

                    VStack(spacing: 0) {
                        actionRow(
                            icon: "star.fill", iconColor: .yellow,
                            title: "Rate Brawlbit"
                        ) {
                            if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appStoreId)?action=write-review") {
                                UIApplication.shared.open(url)
                            }
                        }

                        rowDivider()

                        actionRow(
                            icon: "envelope.fill", iconColor: .blue,
                            title: "Contact support"
                        ) {
                            if let url = URL(string: "mailto:jsarriab28@gmail.com?subject=Brawlbit%20Support") {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    .background(Color(white: 0.12))
                    .cornerRadius(14)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)

                    sectionHeader("LEGAL")

                    VStack(spacing: 0) {
                        actionRow(
                            icon: "doc.text.fill", iconColor: Color(white: 0.45),
                            title: "Terms and Conditions"
                        ) {
                            // Replace with your hosted URL (GitHub Pages, Notion, etc.)
                            if let url = URL(string: "https://yourwebsite.com/terms") {
                                UIApplication.shared.open(url)
                            }
                        }

                        rowDivider()

                        actionRow(
                            icon: "lock.fill", iconColor: Color(white: 0.45),
                            title: "Privacy Policy"
                        ) {
                            if let url = URL(string: "https://yourwebsite.com/privacy") {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    .background(Color(white: 0.12))
                    .cornerRadius(14)
                    .padding(.horizontal, 24)

                    Text("Made with ☕ and way too many late nights.")
                        .font(.system(size: 11))
                        .foregroundColor(Color(white: 0.25))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 36)
                        .padding(.bottom, 60)
                }
                .padding(.top, 24)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    @ViewBuilder
    private func infoRow(icon: String, iconColor: Color, title: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(iconColor)
                .cornerRadius(7)
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            Spacer()
            Text(value)
                .font(.system(size: 13))
                .foregroundColor(Color(white: 0.4))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func actionRow(icon: String, iconColor: Color, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(iconColor)
                    .cornerRadius(7)
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12))
                    .foregroundColor(Color(white: 0.3))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func rowDivider() -> some View {
        Rectangle()
            .fill(Color(white: 1, opacity: 0.06))
            .frame(height: 1)
            .padding(.leading, 58)
    }

    @ViewBuilder
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(Color(white: 0.4))
            .tracking(1)
            .padding(.horizontal, 24)
            .padding(.bottom, 14)
    }
}
