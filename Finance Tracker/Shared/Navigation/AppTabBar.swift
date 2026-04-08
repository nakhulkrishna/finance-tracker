import SwiftUI

struct AppTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(FinancePalette.icyBlue.opacity(0.9))
                .frame(height: 1)

            HStack(spacing: 0) {
                ForEach(AppTab.allCases) { tab in
                    Button(action: {
                        withAnimation(.smooth(duration: 0.30)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 4) {
                            Capsule()
                                .fill(selectedTab == tab ? FinancePalette.royalBlue : .clear)
                                .frame(width: 18, height: 3)

                            Image(systemName: tab.symbol)
                                .font(.system(size: 17, weight: .semibold))

                            Text(tab.rawValue)
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .lineLimit(1)
                                .minimumScaleFactor(0.82)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                        .padding(.bottom, 10)
                        .foregroundStyle(selectedTab == tab ? FinancePalette.royalBlue : FinancePalette.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 4)
        }
        .background(.ultraThinMaterial)
    }
}
