import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case home = "Home"
    case insights = "Insights"
    case invest = "Invest"
    case wallet = "Wallet"
    case more = "More"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .home:
            return "house.fill"
        case .insights:
            return "chart.pie.fill"
        case .invest:
            return "chart.line.uptrend.xyaxis.circle.fill"
        case .wallet:
            return "wallet.pass.fill"
        case .more:
            return "person.crop.circle"
        }
    }
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .home
    @State private var isAuthenticated = false

    var body: some View {
        ZStack {
            AppBackground()

            if isAuthenticated {
                Group {
                    switch selectedTab {
                    case .home:
                        HomeDashboardScreen()
                    case .insights:
                        InsightsScreen()
                    case .invest:
                        InvestmentsScreen()
                    case .wallet:
                        WalletScreen()
                    case .more:
                        MoreSettingsScreen()
                    }
                }
            } else {
                AuthenticationFlowScreen(isAuthenticated: $isAuthenticated)
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if isAuthenticated {
                AppTabBar(selectedTab: $selectedTab)
            }
        }
        .animation(.smooth(duration: 0.30), value: selectedTab)
        .animation(.smooth(duration: 0.35), value: isAuthenticated)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
    }
}
