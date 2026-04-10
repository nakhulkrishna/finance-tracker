import SwiftUI

@main
struct Finance_TrackerApp: App {
    @StateObject private var authStore: AuthStore
    @StateObject private var financeStore = FinanceStore()
    @StateObject private var premiumStore = PremiumStore()

    init() {
        FirebaseBootstrap.configureIfNeeded()
        _authStore = StateObject(wrappedValue: AuthStore())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authStore)
                .environmentObject(financeStore)
                .environmentObject(premiumStore)
        }
    }
}
