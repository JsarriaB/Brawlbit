import SwiftUI

struct ProgresoView: View {
    @AppStorage("progresoSelectedTab") private var selectedTab: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            // Black header — safe area + picker
            Picker("", selection: $selectedTab) {
                Text("Mountain").tag(0)
                Text("Progress").tag(1)
            }
            .pickerStyle(.segmented)
            .colorScheme(.dark)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.black.ignoresSafeArea(edges: .top))

            // Content starts cleanly below the header
            Group {
                if selectedTab == 0 {
                    MountainView()
                } else {
                    StatsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.black)
    }
}

