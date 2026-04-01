import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            // Content
            Group {
                switch selectedTab {
                case 0: TodayView()
                case 1: ProgresoView()
                case 2: HistoryView()
                case 3: ProfileView()
                default: TodayView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom tab bar
            HStack(spacing: 0) {
                tabItem(icon: "flame.fill",       label: "Today",    tag: 0)
                tabItem(icon: "mountain.2.fill",  label: "Progress", tag: 1)
                tabItem(icon: "scroll.fill",      label: "History",  tag: 2)
                tabItem(icon: "person.fill",      label: "Profile",  tag: 3)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 12)
            .padding(.bottom, 28) // covers home indicator area
            .background(Color.black)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    @ViewBuilder
    private func tabItem(icon: String, label: String, tag: Int) -> some View {
        let isSelected = selectedTab == tag
        Button { selectedTab = tag } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                Text(label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
            }
            .foregroundColor(isSelected ? .orange : Color(white: 0.4))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
