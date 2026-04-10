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
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var financeStore: FinanceStore
    @EnvironmentObject private var premiumStore: PremiumStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab: AppTab = .home
    @State private var isAppLockPresented = false
    @State private var isUnlockingApp = false
    @State private var appLockMessage: String?
    @State private var appUnlockMethod: DeviceAuthenticationMethod = .faceID
    @State private var hasHandledInitialSession = false

    private var shouldShowAppLock: Bool {
        authStore.isAuthenticated && authStore.profilePreferences.lockOnLaunch && isAppLockPresented
    }

    private var appColorScheme: ColorScheme {
        authStore.profilePreferences.prefersDarkMode ? .dark : .light
    }

    var body: some View {
        ZStack {
            AppBackground()

            if authStore.isRestoringSession {
                SessionLoadingScreen()
            } else if authStore.isAuthenticated {
                Group {
                    if authStore.requiresInitialFinanceSetup {
                        InitialFinanceSetupFlowScreen()
                    } else {
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
                }
                .blur(radius: shouldShowAppLock ? 14 : 0)
                .allowsHitTesting(!shouldShowAppLock)
            } else {
                AuthenticationFlowScreen()
            }

            if shouldShowAppLock {
                AppLaunchLockScreen(
                    firstName: authStore.currentUser?.firstName ?? "there",
                    unlockMethod: appUnlockMethod,
                    isUnlocking: isUnlockingApp,
                    message: appLockMessage,
                    unlockAction: unlockApp
                )
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if authStore.isAuthenticated && !authStore.requiresInitialFinanceSetup && !shouldShowAppLock {
                AppTabBar(selectedTab: $selectedTab)
            }
        }
        .onAppear {
            financeStore.setActiveUser(authStore.currentUser?.id)
            handleInitialSessionIfNeeded()

            Task {
                await premiumStore.prepare()
                syncPremiumState()
            }
        }
        .onChange(of: authStore.currentUser?.id) { _, userID in
            financeStore.setActiveUser(userID)

            if userID == nil {
                resetAppLockState()
            } else {
                appUnlockMethod = DeviceAuthenticationMethod.availableMethod()
            }

            Task {
                await premiumStore.refreshEntitlements()
                syncPremiumState()
            }
        }
        .onChange(of: authStore.isRestoringSession) { _, _ in
            handleInitialSessionIfNeeded()
        }
        .onChange(of: authStore.profilePreferences.lockOnLaunch) { _, isEnabled in
            if isEnabled {
                appUnlockMethod = DeviceAuthenticationMethod.availableMethod()
            } else {
                withAnimation(.smooth(duration: 0.25)) {
                    isAppLockPresented = false
                    appLockMessage = nil
                }
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            handleScenePhaseChange(newPhase)
        }
        .onChange(of: premiumStore.activePlan) { _, _ in
            syncPremiumState()
        }
        .onChange(of: premiumStore.activeProductID) { _, _ in
            syncPremiumState()
        }
        .preferredColorScheme(appColorScheme)
        .animation(.smooth(duration: 0.30), value: selectedTab)
        .animation(.smooth(duration: 0.35), value: authStore.isAuthenticated)
        .animation(.smooth(duration: 0.28), value: appColorScheme)
        .animation(.smooth(duration: 0.25), value: shouldShowAppLock)
    }

    private func handleInitialSessionIfNeeded() {
        guard !authStore.isRestoringSession else { return }
        guard !hasHandledInitialSession else { return }

        hasHandledInitialSession = true
        appUnlockMethod = DeviceAuthenticationMethod.availableMethod()

        guard authStore.isAuthenticated, authStore.profilePreferences.lockOnLaunch else { return }
        presentAppLockAndAuthenticate()
    }

    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        guard hasHandledInitialSession else { return }

        switch newPhase {
        case .background:
            guard authStore.isAuthenticated, authStore.profilePreferences.lockOnLaunch else { return }
            withAnimation(.smooth(duration: 0.25)) {
                isAppLockPresented = true
                appLockMessage = nil
            }
        case .active:
            guard shouldShowAppLock else { return }
            unlockApp()
        default:
            break
        }
    }

    private func presentAppLockAndAuthenticate() {
        withAnimation(.smooth(duration: 0.25)) {
            isAppLockPresented = true
            appLockMessage = nil
        }

        unlockApp()
    }

    private func unlockApp() {
        guard !isUnlockingApp else { return }

        appLockMessage = nil
        appUnlockMethod = DeviceAuthenticationMethod.availableMethod()

        Task {
            isUnlockingApp = true

            let result = await DeviceAuthenticator.authenticate(
                reason: "Unlock Finance Tracker to continue."
            )

            switch result {
            case let .success(method):
                appUnlockMethod = method
                withAnimation(.smooth(duration: 0.25)) {
                    isAppLockPresented = false
                    appLockMessage = nil
                }
            case let .failure(message):
                withAnimation(.smooth(duration: 0.25)) {
                    isAppLockPresented = true
                    appLockMessage = message
                }
            }

            isUnlockingApp = false
        }
    }

    private func resetAppLockState() {
        withAnimation(.smooth(duration: 0.25)) {
            isAppLockPresented = false
            appLockMessage = nil
        }

        isUnlockingApp = false
        appUnlockMethod = .faceID
    }

    private func syncPremiumState() {
        guard authStore.isAuthenticated else { return }
        authStore.syncPremiumStatus(
            plan: premiumStore.activePlan,
            productID: premiumStore.activeProductID,
            expiresAt: premiumStore.activeExpirationDate
        )
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthStore())
            .environmentObject(FinanceStore())
            .environmentObject(PremiumStore())
            .preferredColorScheme(.light)
    }
}
#endif

private struct SessionLoadingScreen: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(FinancePalette.royalBlue)
                .scaleEffect(1.1)

            Text("Checking your account")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(FinancePalette.textPrimary)

            Text("Opening your finance workspace securely.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(FinancePalette.textSecondary)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 26)
        .background(Color.white.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(FinancePalette.icyBlue.opacity(0.92), lineWidth: 1)
        )
        .shadow(color: FinancePalette.cardShadow.opacity(0.28), radius: 18, y: 10)
        .padding(.horizontal, 24)
    }
}

private struct AppLaunchLockScreen: View {
    let firstName: String
    let unlockMethod: DeviceAuthenticationMethod
    let isUnlocking: Bool
    let message: String?
    let unlockAction: () -> Void

    private var helperText: String {
        if isUnlocking {
            return "Checking \(unlockMethod.title) and device security."
        }

        return "Use \(unlockMethod.title) to open your finance workspace."
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.98), FinancePalette.mistBlue],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 18) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [FinancePalette.royalBlue, FinancePalette.oceanBlue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 90, height: 90)

                        Image(systemName: unlockMethod.symbol)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    VStack(spacing: 8) {
                        Text("Welcome back, \(firstName)")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(FinancePalette.textPrimary)
                            .multilineTextAlignment(.center)

                        Text("Finance Tracker is locked")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(FinancePalette.textSecondary)

                        Text(helperText)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(FinancePalette.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    HStack(spacing: 12) {
                        AppLockMiniStat(title: "Security", value: unlockMethod.title)
                        AppLockMiniStat(title: "Protection", value: "On Launch")
                    }

                    if let message {
                        Text(message)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(FinancePalette.sapphireBlue)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }

                    PrimaryActionButton(
                        title: isUnlocking ? "Unlocking" : "Unlock App",
                        symbol: isUnlocking ? "hourglass" : unlockMethod.symbol,
                        fill: FinancePalette.royalBlue,
                        foreground: .white,
                        stroke: .clear,
                        action: unlockAction
                    )
                    .disabled(isUnlocking)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 28)
                .background(Color.white.opacity(0.96))
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(FinancePalette.icyBlue.opacity(0.96), lineWidth: 1)
                )
                .shadow(color: FinancePalette.cardShadow.opacity(0.34), radius: 24, y: 14)
                .padding(.horizontal, 24)

                Spacer()
            }
        }
    }
}

private struct AppLockMiniStat: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(FinancePalette.textSecondary)

            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(FinancePalette.textPrimary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(FinancePalette.paleBlue.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(FinancePalette.icyBlue.opacity(0.96), lineWidth: 1)
        )
    }
}
