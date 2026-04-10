import StoreKit
import SwiftUI

private enum AppExternalLinks {
    static let privacyPolicy = URL(string: "https://nakhulkrishna.github.io/finance-tracker/privacy.html")!
    static let deleteAccount = URL(string: "https://nakhulkrishna.github.io/finance-tracker/delete-account.html")!
}

struct MoreSettingsScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var financeStore: FinanceStore
    @EnvironmentObject private var premiumStore: PremiumStore
    @State private var activeRoute: ProfileRoute?
    @State private var isShowingNotifications = false
    @State private var hasAnimatedIn = false

    private var selectedCurrency: Binding<ProfileCurrency> {
        Binding(
            get: { authStore.profilePreferences.selectedCurrency },
            set: { newValue in
                authStore.updateProfilePreferences { $0.selectedCurrency = newValue }
            }
        )
    }

    private var preferredWalletSource: Binding<WalletPreferenceSource> {
        Binding(
            get: { authStore.profilePreferences.preferredWalletSource },
            set: { newValue in
                authStore.updateProfilePreferences { $0.preferredWalletSource = newValue }
            }
        )
    }

    private var showWalletSyncStatus: Binding<Bool> {
        Binding(
            get: { authStore.profilePreferences.showWalletSyncStatus },
            set: { newValue in
                authStore.updateProfilePreferences { $0.showWalletSyncStatus = newValue }
            }
        )
    }

    private var showWalletActivityPreview: Binding<Bool> {
        Binding(
            get: { authStore.profilePreferences.showWalletActivityPreview },
            set: { newValue in
                authStore.updateProfilePreferences { $0.showWalletActivityPreview = newValue }
            }
        )
    }

    private var spendingAlerts: Binding<Bool> {
        Binding(
            get: { authStore.profilePreferences.spendingAlerts },
            set: { newValue in
                authStore.updateProfilePreferences { $0.spendingAlerts = newValue }
            }
        )
    }

    private var prefersDarkMode: Binding<Bool> {
        Binding(
            get: { authStore.profilePreferences.prefersDarkMode },
            set: { newValue in
                authStore.updateProfilePreferences { $0.prefersDarkMode = newValue }
            }
        )
    }

    private var weeklyInsights: Binding<Bool> {
        Binding(
            get: { authStore.profilePreferences.weeklyInsights },
            set: { newValue in
                authStore.updateProfilePreferences { $0.weeklyInsights = newValue }
            }
        )
    }

    private var biometricLock: Binding<Bool> {
        Binding(
            get: { authStore.profilePreferences.biometricLock },
            set: { newValue in
                authStore.updateProfilePreferences { $0.biometricLock = newValue }
            }
        )
    }

    private var lockOnLaunch: Binding<Bool> {
        Binding(
            get: { authStore.profilePreferences.lockOnLaunch },
            set: { newValue in
                authStore.updateProfilePreferences { $0.lockOnLaunch = newValue }
            }
        )
    }

    private var hideRecentActivity: Binding<Bool> {
        Binding(
            get: { authStore.profilePreferences.hideRecentActivity },
            set: { newValue in
                authStore.updateProfilePreferences { $0.hideRecentActivity = newValue }
            }
        )
    }

    private var customCategoriesRowValue: String {
        premiumStore.hasAccess(to: .customCategories) ? customCategorySummary : "Premium"
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                DashboardHeader(
                    avatarText: authStore.currentUser?.initials ?? "FT",
                    title: "Profile",
                    subtitle: authStore.currentUser?.profileSubtitle ?? "Settings and privacy",
                    notificationAction: {
                        isShowingNotifications = true
                    }
                )

                profileCard
                    .opacity(hasAnimatedIn ? 1 : 0)
                    .offset(y: hasAnimatedIn ? 0 : 16)
                    .animation(.spring(response: 0.62, dampingFraction: 0.88), value: hasAnimatedIn)

                privacyCard
                    .opacity(hasAnimatedIn ? 1 : 0)
                    .offset(y: hasAnimatedIn ? 0 : 18)
                    .animation(.spring(response: 0.66, dampingFraction: 0.90).delay(0.04), value: hasAnimatedIn)

                accountSection
                    .opacity(hasAnimatedIn ? 1 : 0)
                    .offset(y: hasAnimatedIn ? 0 : 20)
                    .animation(.spring(response: 0.70, dampingFraction: 0.90).delay(0.08), value: hasAnimatedIn)

                preferencesSection
                    .opacity(hasAnimatedIn ? 1 : 0)
                    .offset(y: hasAnimatedIn ? 0 : 22)
                    .animation(.spring(response: 0.72, dampingFraction: 0.90).delay(0.12), value: hasAnimatedIn)

                supportSection
                    .opacity(hasAnimatedIn ? 1 : 0)
                    .offset(y: hasAnimatedIn ? 0 : 24)
                    .animation(.spring(response: 0.76, dampingFraction: 0.92).delay(0.16), value: hasAnimatedIn)

                signOutButton
                    .opacity(hasAnimatedIn ? 1 : 0)
                    .offset(y: hasAnimatedIn ? 0 : 26)
                    .animation(.spring(response: 0.78, dampingFraction: 0.92).delay(0.18), value: hasAnimatedIn)
            }
            .frame(maxWidth: 430)
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 120)
        }
        .sheet(item: $activeRoute) { route in
            Group {
                switch route {
                case .personalDetails:
                    ProfileDetailsScreen()
                case .walletPreferences:
                    WalletPreferencesScreen(
                        preferredSource: preferredWalletSource,
                        showWalletSyncStatus: showWalletSyncStatus,
                        showWalletActivityPreview: showWalletActivityPreview
                    )
                case .securityPrivacy:
                    SecurityPrivacyScreen(
                        biometricLock: biometricLock,
                        lockOnLaunch: lockOnLaunch,
                        hideRecentActivity: hideRecentActivity
                    )
                case .currency:
                    CurrencySettingsScreen(selectedCurrency: selectedCurrency)
                case .customCategories:
                    CustomCategoriesScreen()
                case .premium:
                    PremiumSubscriptionScreen()
                case .privacyPolicy:
                    PrivacyPolicyScreen()
                case .helpCenter:
                    HelpCenterScreen()
                case .about:
                    AboutFinanceTrackerScreen()
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $isShowingNotifications) {
            InsightsNotificationsScreen()
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
        .onAppear {
            guard !hasAnimatedIn else { return }
            hasAnimatedIn = true
        }
    }

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 72, height: 72)

                    Circle()
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        .frame(width: 82, height: 82)

                    Text(authStore.currentUser?.initials ?? "FT")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                Spacer(minLength: 0)

                Button(action: {
                    activeRoute = .personalDetails
                }) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 42, height: 42)
                        .background(Color.white.opacity(0.14))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.10), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(authStore.currentUser?.fullName ?? "Finance User")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                    .fixedSize(horizontal: false, vertical: true)

                Text(authStore.currentUser?.email ?? "Personal finance dashboard owner")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.76))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }

            HStack(spacing: 8) {
                Text((authStore.currentUser?.accountType.badgeTitle ?? FinanceAccountType.standard.badgeTitle).uppercased())
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(FinancePalette.navyBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.92))
                    .clipShape(Capsule())

                ProfileChip(title: "Private sync")
            }

            HStack(spacing: 14) {
                ProfileStatTile(title: "Wallet", value: financeStore.walletBalanceText)
                ProfileStatTile(title: "This Month", value: financeStore.monthlySpend.currencyText)
            }
        }
        .padding(24)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [FinancePalette.navyBlue, FinancePalette.sapphireBlue, FinancePalette.royalBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Circle()
                    .fill(Color.white.opacity(0.14))
                    .frame(width: 190, height: 190)
                    .blur(radius: 10)
                    .offset(x: 128, y: -88)

                Circle()
                    .fill(FinancePalette.iceBlue.opacity(0.28))
                    .frame(width: 132, height: 132)
                    .blur(radius: 16)
                    .offset(x: -132, y: 86)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: FinancePalette.royalBlue.opacity(0.22), radius: 22, y: 16)
    }

    private var privacyCard: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(FinancePalette.softBlueBackground(for: colorScheme))
                    .frame(width: 58, height: 58)

                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(FinancePalette.royalBlue)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Private by design")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)

                Text("Your finance data stays inside your secured account and syncs privately.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(FinancePalette.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 12)

            Text("Secure Sync")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(FinancePalette.royalBlue)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(FinancePalette.softBlueBackground(for: colorScheme))
                .clipShape(Capsule())
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(FinancePalette.elevatedBackground(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(FinancePalette.border(for: colorScheme), lineWidth: 1)
        )
        .shadow(color: FinancePalette.shadow(for: colorScheme).opacity(0.42), radius: 14, y: 10)
    }

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SettingsSectionTitle(
                title: "Account",
                subtitle: "Personal details and finance access"
            )

            SettingsCard {
                SettingsNavigationRow(
                    icon: "crown.fill",
                    title: "Premium",
                    subtitle: premiumStore.isPremium
                        ? "Your App Store premium access is active on this device"
                        : "Unlock advanced insights, exports, and richer controls",
                    value: premiumStore.isPremium ? premiumStore.activePlan.title : "Upgrade",
                    color: FinancePalette.royalBlue,
                    action: {
                        activeRoute = .premium
                    }
                )

                SettingsRowDivider()

                SettingsNavigationRow(
                    icon: "person.text.rectangle.fill",
                    title: "Personal Details",
                    subtitle: "Name, phone, and account identity",
                    value: "Edit",
                    color: FinancePalette.royalBlue,
                    action: {
                        activeRoute = .personalDetails
                    }
                )

                SettingsRowDivider()

                SettingsNavigationRow(
                    icon: "wallet.pass.fill",
                    title: "Wallet Preferences",
                    subtitle: "Liquid money card and quick actions",
                    value: "Open",
                    color: FinancePalette.oceanBlue,
                    action: {
                        activeRoute = .walletPreferences
                    }
                )

                SettingsRowDivider()

                SettingsNavigationRow(
                    icon: "lock.shield.fill",
                    title: "Security & Privacy",
                    subtitle: "Local processing and data protection",
                    value: biometricLock.wrappedValue ? "Face ID" : "Local",
                    color: FinancePalette.sapphireBlue,
                    action: {
                        activeRoute = .securityPrivacy
                    }
                )
            }
        }
    }

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SettingsSectionTitle(
                title: "Preferences",
                subtitle: "Alerts and app behavior"
            )

            SettingsCard {
                SettingsNavigationRow(
                    icon: "indianrupeesign.circle.fill",
                    title: "Currency",
                    subtitle: "Primary display unit",
                    value: selectedCurrency.wrappedValue.code,
                    color: FinancePalette.royalBlue,
                    action: {
                        activeRoute = .currency
                    }
                )

                SettingsRowDivider()

                SettingsNavigationRow(
                    icon: "square.grid.2x2.fill",
                    title: "Custom Categories",
                    subtitle: premiumStore.hasAccess(to: .customCategories)
                        ? "Add your own categories for entries and wallet logs"
                        : "Unlock custom categories with Premium",
                    value: customCategoriesRowValue,
                    color: FinancePalette.oceanBlue,
                    action: {
                        activeRoute = premiumStore.hasAccess(to: .customCategories) ? .customCategories : .premium
                    }
                )

                SettingsRowDivider()

                if premiumStore.hasAccess(to: .premiumAlerts) {
                    SettingsToggleRow(
                        icon: "bell.badge.fill",
                        title: "Spending Alerts",
                        subtitle: "Get reminders for manual expense updates",
                        isOn: spendingAlerts,
                        color: FinancePalette.oceanBlue
                    )
                } else {
                    SettingsNavigationRow(
                        icon: "bell.badge.fill",
                        title: "Spending Alerts",
                        subtitle: "Premium reminder controls for finance activity",
                        value: "Premium",
                        color: FinancePalette.oceanBlue,
                        action: {
                            activeRoute = .premium
                        }
                    )
                }

                SettingsRowDivider()

                if premiumStore.hasAccess(to: .premiumAlerts) {
                    SettingsToggleRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Weekly Insights",
                        subtitle: "Show a weekly finance summary prompt",
                        isOn: weeklyInsights,
                        color: FinancePalette.royalBlue
                    )
                } else {
                    SettingsNavigationRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Weekly Insights",
                        subtitle: "Unlock premium finance summaries and prompts",
                        value: "Premium",
                        color: FinancePalette.royalBlue,
                        action: {
                            activeRoute = .premium
                        }
                    )
                }

                SettingsRowDivider()

                SettingsToggleRow(
                    icon: "moon.fill",
                    title: "Dark Mode",
                    subtitle: "Switch the whole app between light and dark appearance",
                    isOn: prefersDarkMode,
                    color: FinancePalette.sapphireBlue
                )

                SettingsRowDivider()

                SettingsToggleRow(
                    icon: "faceid",
                    title: "Biometric Lock",
                    subtitle: "Add Face ID before sensitive screens",
                    isOn: biometricLock,
                    color: FinancePalette.royalBlue
                )
            }
        }
    }

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SettingsSectionTitle(
                title: "Support",
                subtitle: "Help, privacy policy, and app info"
            )

            SettingsCard {
                SettingsNavigationRow(
                    icon: "hand.raised.fill",
                    title: "Privacy Policy",
                    subtitle: "How on-device finance data is handled",
                    value: "Read",
                    color: FinancePalette.sapphireBlue,
                    action: {
                        activeRoute = .privacyPolicy
                    }
                )

                SettingsRowDivider()

                SettingsNavigationRow(
                    icon: "questionmark.circle.fill",
                    title: "Help Center",
                    subtitle: "FAQs, onboarding, and support guides",
                    value: "Open",
                    color: FinancePalette.oceanBlue,
                    action: {
                        activeRoute = .helpCenter
                    }
                )

                SettingsRowDivider()

                SettingsNavigationRow(
                    icon: "info.circle.fill",
                    title: "About Finance Tracker",
                    subtitle: "Version, credits, and app details",
                    value: "v1.0",
                    color: FinancePalette.royalBlue,
                    action: {
                        activeRoute = .about
                    }
                )
            }
        }
    }

    private var signOutButton: some View {
        Button {
            authStore.signOut()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 15, weight: .bold))

                Text("Sign Out")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
            }
            .foregroundStyle(FinancePalette.royalBlue)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(FinancePalette.elevatedBackground(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(FinancePalette.border(for: colorScheme), lineWidth: 1)
            )
            .shadow(color: FinancePalette.shadow(for: colorScheme).opacity(0.20), radius: 12, y: 8)
        }
        .buttonStyle(.plain)
    }

    private var customCategorySummary: String {
        let totalCount = authStore.profilePreferences.paymentCategories.count
            + authStore.profilePreferences.depositCategories.count
            + authStore.profilePreferences.walletAddCategories.count
            + authStore.profilePreferences.walletWithdrawCategories.count

        return totalCount == 0 ? "None" : "\(totalCount) added"
    }
}

private enum ProfileRoute: String, Identifiable {
    case personalDetails
    case walletPreferences
    case securityPrivacy
    case currency
    case customCategories
    case premium
    case privacyPolicy
    case helpCenter
    case about

    var id: String { rawValue }
}

private extension FinanceAccountType {
    var subtitle: String {
        switch self {
        case .standard:
            return "Clean finance tracking with the core local-first tools."
        case .premium:
            return "Enhanced finance profile with a richer premium badge style."
        }
    }

    var icon: String {
        switch self {
        case .standard:
            return "star.circle.fill"
        case .premium:
            return "crown.fill"
        }
    }

    var color: Color {
        switch self {
        case .standard:
            return FinancePalette.oceanBlue
        case .premium:
            return FinancePalette.royalBlue
        }
    }
}

enum ProfileCurrency: String, CaseIterable, Identifiable, Codable {
    case inr
    case usd
    case eur
    case gbp

    var id: String { rawValue }

    var code: String {
        switch self {
        case .inr:
            return "INR"
        case .usd:
            return "USD"
        case .eur:
            return "EUR"
        case .gbp:
            return "GBP"
        }
    }

    var symbol: String {
        switch self {
        case .inr:
            return "Rs"
        case .usd:
            return "$"
        case .eur:
            return "EUR"
        case .gbp:
            return "GBP"
        }
    }

    var title: String {
        switch self {
        case .inr:
            return "Indian Rupee"
        case .usd:
            return "US Dollar"
        case .eur:
            return "Euro"
        case .gbp:
            return "British Pound"
        }
    }

    var subtitle: String {
        switch self {
        case .inr:
            return "Best fit for your current finance tracker setup"
        case .usd:
            return "Useful for international balances and travel"
        case .eur:
            return "Clean format for Europe-based spending"
        case .gbp:
            return "Pound format for UK-style money display"
        }
    }

    var region: String {
        switch self {
        case .inr:
            return "India"
        case .usd:
            return "United States"
        case .eur:
            return "Europe"
        case .gbp:
            return "United Kingdom"
        }
    }
}

enum WalletPreferenceSource: String, CaseIterable, Identifiable, Codable {
    case bankTransfer
    case cash
    case salary
    case refund

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bankTransfer:
            return "Bank Transfer"
        case .cash:
            return "Cash"
        case .salary:
            return "Salary"
        case .refund:
            return "Refund"
        }
    }

    var shortTitle: String {
        switch self {
        case .bankTransfer:
            return "Bank"
        case .cash:
            return "Cash"
        case .salary:
            return "Salary"
        case .refund:
            return "Refund"
        }
    }

    var subtitle: String {
        switch self {
        case .bankTransfer:
            return "Best for regular wallet top-ups"
        case .cash:
            return "Use when logging physical cash"
        case .salary:
            return "For monthly income-based entries"
        case .refund:
            return "For returns and reimbursements"
        }
    }

    var icon: String {
        switch self {
        case .bankTransfer:
            return "building.columns.fill"
        case .cash:
            return "banknote.fill"
        case .salary:
            return "briefcase.fill"
        case .refund:
            return "arrow.uturn.left.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .bankTransfer:
            return FinancePalette.royalBlue
        case .cash:
            return FinancePalette.oceanBlue
        case .salary:
            return FinancePalette.sapphireBlue
        case .refund:
            return FinancePalette.iceBlue
        }
    }

    var walletTag: String {
        switch self {
        case .bankTransfer:
            return "Transfer"
        case .cash:
            return "Cash"
        case .salary:
            return "Salary"
        case .refund:
            return "Refund"
        }
    }
}

private struct ProfileDetailsScreen: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var premiumStore: PremiumStore
    @State private var fullName = ""
    @State private var phoneNumber = ""
    @State private var statusMessage: String?
    @State private var hasLoadedInitialState = false

    var body: some View {
        ProfileSubscreenScaffold(
            title: "Personal Details",
            subtitle: "Profile identity and account basics"
        ) {
            SettingsHeroPanel(
                icon: "person.crop.circle.fill",
                title: authStore.currentUser?.fullName ?? "Finance User",
                subtitle: authStore.currentUser?.email ?? "Email account",
                badge: "Verified",
                accent: FinancePalette.royalBlue
            ) {
                HStack(spacing: 12) {
                    HomeSheetMiniStat(title: "Member Since", value: authStore.currentUser?.memberSinceText ?? "This month")
                    HomeSheetMiniStat(title: "Plan", value: premiumStore.premiumBadgeTitle)
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                SettingsSectionTitle(
                    title: "Editable Details",
                    subtitle: "Information that appears across your app experience"
                )

                VStack(alignment: .leading, spacing: 16) {
                    if let statusMessage {
                        ProfileStatusBanner(message: statusMessage)
                    }

                    HomeSheetField(
                        title: "Full Name",
                        prefix: nil,
                        placeholder: "Enter your full name",
                        text: $fullName
                    )

                    HomeSheetField(
                        title: "Phone Number",
                        prefix: nil,
                        placeholder: "Enter your mobile number",
                        text: $phoneNumber
                    )

                    SettingsCard {
                        SettingsInfoRow(
                            icon: "envelope.fill",
                            title: "Email",
                            subtitle: "Primary app email",
                            value: authStore.currentUser?.email ?? "Not added",
                            color: FinancePalette.sapphireBlue
                        )
                    }
                }
            }

            SettingsCard {
                SettingsInfoRow(
                    icon: premiumStore.isPremium ? "crown.fill" : "star.circle.fill",
                    title: "Current Plan",
                    subtitle: premiumStore.isPremium
                        ? "Managed by your App Store subscription status"
                        : "Standard plan until a premium purchase is active",
                    value: premiumStore.premiumBadgeTitle,
                    color: FinancePalette.royalBlue
                )
            }

            PrimaryActionButton(
                title: authStore.isLoading ? "Saving..." : "Save Profile",
                symbol: "checkmark",
                fill: FinancePalette.royalBlue,
                foreground: .white,
                stroke: .clear,
                action: saveProfile
            )
            .disabled(authStore.isLoading)
        }
        .onAppear {
            guard !hasLoadedInitialState else { return }
            fullName = authStore.currentUser?.fullName ?? ""
            phoneNumber = authStore.currentUser?.phoneNumber ?? ""
            hasLoadedInitialState = true
        }
    }

    private func saveProfile() {
        statusMessage = nil
        authStore.updateProfile(
            fullName: fullName,
            phoneNumber: phoneNumber
        ) { message in
            if let message {
                statusMessage = message
            } else {
                statusMessage = "Profile updated successfully."
            }
        }
    }
}

private struct WalletPreferencesScreen: View {
    @Binding var preferredSource: WalletPreferenceSource
    @Binding var showWalletSyncStatus: Bool
    @Binding var showWalletActivityPreview: Bool

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ProfileSubscreenScaffold(
            title: "Wallet Preferences",
            subtitle: "Control wallet display and quick actions"
        ) {
            SettingsHeroPanel(
                icon: "wallet.pass.fill",
                title: "Liquid Wallet",
                subtitle: "Customize how wallet actions look and behave",
                badge: "Wallet",
                accent: FinancePalette.oceanBlue
            ) {
                HStack(spacing: 12) {
                    HomeSheetMiniStat(title: "Default Source", value: preferredSource.shortTitle)
                    HomeSheetMiniStat(title: "Sync Label", value: showWalletSyncStatus ? "Visible" : "Hidden")
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                SettingsSectionTitle(
                    title: "Default Source",
                    subtitle: "Your favorite entry source for wallet logs"
                )

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(WalletPreferenceSource.allCases) { source in
                        SettingsSelectionCard(
                            icon: source.icon,
                            title: source.title,
                            subtitle: source.subtitle,
                            isSelected: preferredSource == source,
                            color: source.color,
                            action: {
                                preferredSource = source
                            }
                        )
                    }
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                SettingsSectionTitle(
                    title: "Display",
                    subtitle: "Choose what appears on the wallet page"
                )

                SettingsCard {
                    SettingsToggleRow(
                        icon: "arrow.triangle.2.circlepath",
                        title: "Show Last Sync",
                        subtitle: "Display the sync time in the wallet card",
                        isOn: $showWalletSyncStatus,
                        color: FinancePalette.oceanBlue
                    )

                    SettingsRowDivider()

                    SettingsToggleRow(
                        icon: "clock.fill",
                        title: "Show Recent Activity",
                        subtitle: "Keep the recent cash log preview on the page",
                        isOn: $showWalletActivityPreview,
                        color: FinancePalette.royalBlue
                    )

                    SettingsRowDivider()

                    SettingsInfoRow(
                        icon: "rectangle.grid.2x2.fill",
                        title: "Quick Actions Layout",
                        subtitle: "Current arrangement of wallet actions",
                        value: "Two Cards",
                        color: FinancePalette.sapphireBlue
                    )
                }
            }
        }
    }
}

private struct SecurityPrivacyScreen: View {
    @Binding var biometricLock: Bool
    @Binding var lockOnLaunch: Bool
    @Binding var hideRecentActivity: Bool

    var body: some View {
        ProfileSubscreenScaffold(
            title: "Security & Privacy",
            subtitle: "Protect data and control how it appears"
        ) {
            SettingsHeroPanel(
                icon: "shield.fill",
                title: "Private by Design",
                subtitle: "Your finance account is protected with private sync and user-level access.",
                badge: "Protected",
                accent: FinancePalette.sapphireBlue
            ) {
                HStack(spacing: 12) {
                    HomeSheetMiniStat(title: "Sync", value: "Firebase")
                    HomeSheetMiniStat(title: "Data Sharing", value: "None")
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                SettingsSectionTitle(
                    title: "Security Controls",
                    subtitle: "Locks and visibility for sensitive information"
                )

                SettingsCard {
                    SettingsToggleRow(
                        icon: "faceid",
                        title: "Biometric Lock",
                        subtitle: "Use Face ID before sensitive finance screens",
                        isOn: $biometricLock,
                        color: FinancePalette.sapphireBlue
                    )

                    SettingsRowDivider()

                    SettingsToggleRow(
                        icon: "lock.fill",
                        title: "Lock on Launch",
                        subtitle: "Require unlock when the app opens",
                        isOn: $lockOnLaunch,
                        color: FinancePalette.royalBlue
                    )

                    SettingsRowDivider()

                    SettingsToggleRow(
                        icon: "eye.slash.fill",
                        title: "Hide Recent Activity",
                        subtitle: "Reduce visible cash activity in shared spaces",
                        isOn: $hideRecentActivity,
                        color: FinancePalette.oceanBlue
                    )
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                SettingsSectionTitle(
                    title: "Data Handling",
                    subtitle: "How app data is processed in the current MVP"
                )

                SettingsCard {
                    SettingsInfoRow(
                        icon: "internaldrive.fill",
                        title: "Storage",
                        subtitle: "Transaction and wallet data",
                        value: "Firebase",
                        color: FinancePalette.royalBlue
                    )

                    SettingsRowDivider()

                    SettingsInfoRow(
                        icon: "icloud.slash.fill",
                        title: "Cloud Sync",
                        subtitle: "Private account data sync",
                        value: "Enabled",
                        color: FinancePalette.sapphireBlue
                    )

                    SettingsRowDivider()

                    SettingsInfoRow(
                        icon: "person.2.slash.fill",
                        title: "Sharing",
                        subtitle: "External data sharing",
                        value: "None",
                        color: FinancePalette.oceanBlue
                    )
                }
            }
        }
    }
}

private struct CurrencySettingsScreen: View {
    @Binding var selectedCurrency: ProfileCurrency

    var body: some View {
        ProfileSubscreenScaffold(
            title: "Currency",
            subtitle: "Choose how money appears across the app"
        ) {
            SettingsHeroPanel(
                icon: "indianrupeesign.circle.fill",
                title: selectedCurrency.title,
                subtitle: "Current format used for balances, wallet logs, and insights",
                badge: selectedCurrency.code,
                accent: FinancePalette.royalBlue
            ) {
                HStack(spacing: 12) {
                    HomeSheetMiniStat(title: "Symbol", value: selectedCurrency.symbol)
                    HomeSheetMiniStat(title: "Region", value: selectedCurrency.region)
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                SettingsSectionTitle(
                    title: "Available Currencies",
                    subtitle: "Pick the format that best matches your spending view"
                )

                VStack(spacing: 12) {
                    ForEach(ProfileCurrency.allCases) { currency in
                        SettingsSelectionCard(
                            icon: "dollarsign.circle.fill",
                            title: currency.title,
                            subtitle: currency.subtitle,
                            isSelected: selectedCurrency == currency,
                            color: currency == .inr ? FinancePalette.royalBlue : FinancePalette.oceanBlue,
                            trailingValue: currency.code,
                            action: {
                                selectedCurrency = currency
                            }
                        )
                    }
                }
            }
        }
    }
}

private struct CustomCategoriesScreen: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var premiumStore: PremiumStore

    @State private var paymentInput = ""
    @State private var depositInput = ""
    @State private var walletAddInput = ""
    @State private var walletWithdrawInput = ""

    var body: some View {
        ProfileSubscreenScaffold(
            title: "Custom Categories",
            subtitle: "Add your own category chips for manual entries"
        ) {
            if premiumStore.hasAccess(to: .customCategories) {
                SettingsHeroPanel(
                    icon: "square.grid.2x2.fill",
                    title: "Entry Categories",
                    subtitle: "These custom categories appear in Pay, Deposit, Add Money, and Withdraw sheets.",
                    badge: "\(totalCount) Added",
                    accent: FinancePalette.oceanBlue
                ) {
                    HStack(spacing: 12) {
                        HomeSheetMiniStat(title: "Payments", value: "\(authStore.profilePreferences.paymentCategories.count)")
                        HomeSheetMiniStat(title: "Wallet", value: "\(authStore.profilePreferences.walletAddCategories.count + authStore.profilePreferences.walletWithdrawCategories.count)")
                    }
                }

                EditableCategorySection(
                    title: "Payment Categories",
                    subtitle: "Shown in Home > Pay",
                    input: $paymentInput,
                    placeholder: "Medicine",
                    categories: authStore.profilePreferences.paymentCategories,
                    accent: FinancePalette.royalBlue,
                    addAction: { addCategory(paymentInput, to: \.paymentCategories) },
                    removeAction: { removeCategory($0, from: \.paymentCategories) }
                )

                EditableCategorySection(
                    title: "Deposit Categories",
                    subtitle: "Shown in Home > Deposit",
                    input: $depositInput,
                    placeholder: "Bonus",
                    categories: authStore.profilePreferences.depositCategories,
                    accent: FinancePalette.oceanBlue,
                    addAction: { addCategory(depositInput, to: \.depositCategories) },
                    removeAction: { removeCategory($0, from: \.depositCategories) }
                )

                EditableCategorySection(
                    title: "Wallet Add Categories",
                    subtitle: "Shown in Wallet > Add Money",
                    input: $walletAddInput,
                    placeholder: "Pocket Money",
                    categories: authStore.profilePreferences.walletAddCategories,
                    accent: FinancePalette.sapphireBlue,
                    addAction: { addCategory(walletAddInput, to: \.walletAddCategories) },
                    removeAction: { removeCategory($0, from: \.walletAddCategories) }
                )

                EditableCategorySection(
                    title: "Wallet Withdraw Categories",
                    subtitle: "Shown in Wallet > Withdraw",
                    input: $walletWithdrawInput,
                    placeholder: "Fuel",
                    categories: authStore.profilePreferences.walletWithdrawCategories,
                    accent: FinancePalette.royalBlue,
                    addAction: { addCategory(walletWithdrawInput, to: \.walletWithdrawCategories) },
                    removeAction: { removeCategory($0, from: \.walletWithdrawCategories) }
                )
            } else {
                PremiumLockedFeaturePanel(
                    title: PremiumFeature.customCategories.title,
                    subtitle: PremiumFeature.customCategories.subtitle
                )
            }
        }
    }

    private var totalCount: Int {
        authStore.profilePreferences.paymentCategories.count
            + authStore.profilePreferences.depositCategories.count
            + authStore.profilePreferences.walletAddCategories.count
            + authStore.profilePreferences.walletWithdrawCategories.count
    }

    private func addCategory(_ rawValue: String, to keyPath: WritableKeyPath<ProfilePreferences, [String]>) {
        let cleaned = normalizedCategory(rawValue)
        guard !cleaned.isEmpty else { return }

        authStore.updateProfilePreferences { preferences in
            var categories = preferences[keyPath: keyPath]
            guard !categories.contains(where: { $0.caseInsensitiveCompare(cleaned) == .orderedSame }) else { return }
            categories.append(cleaned)
            preferences[keyPath: keyPath] = categories
        }

        clearInput(for: keyPath)
    }

    private func removeCategory(_ category: String, from keyPath: WritableKeyPath<ProfilePreferences, [String]>) {
        authStore.updateProfilePreferences { preferences in
            preferences[keyPath: keyPath].removeAll { $0.caseInsensitiveCompare(category) == .orderedSame }
        }
    }

    private func normalizedCategory(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: " ")
            .map(String.init)
            .joined(separator: " ")
    }

    private func clearInput(for keyPath: WritableKeyPath<ProfilePreferences, [String]>) {
        switch keyPath {
        case \ProfilePreferences.paymentCategories:
            paymentInput = ""
        case \ProfilePreferences.depositCategories:
            depositInput = ""
        case \ProfilePreferences.walletAddCategories:
            walletAddInput = ""
        case \ProfilePreferences.walletWithdrawCategories:
            walletWithdrawInput = ""
        default:
            break
        }
    }
}

private struct PrivacyPolicyScreen: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ProfileSubscreenScaffold(
            title: "Privacy Policy",
            subtitle: "How Finance Tracker handles your data"
        ) {
            SettingsHeroPanel(
                icon: "hand.raised.fill",
                title: "Your data stays with you",
                subtitle: "Finance data is synced securely to your account and isolated per signed-in user.",
                badge: "Secure Sync",
                accent: FinancePalette.sapphireBlue
            ) {
                HStack(spacing: 12) {
                    HomeSheetMiniStat(title: "Server Storage", value: "Firebase")
                    HomeSheetMiniStat(title: "Sharing", value: "Restricted")
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                SettingsSectionTitle(
                    title: "Core Commitments",
                    subtitle: "Key privacy rules for the current app phase"
                )

                VStack(spacing: 12) {
                    SettingsFeatureCard(
                        icon: "internaldrive.fill",
                        title: "Your account is isolated",
                        subtitle: "Profile, transactions, wallet logs, and investments are stored only under your signed-in account.",
                        color: FinancePalette.royalBlue
                    )

                    SettingsFeatureCard(
                        icon: "server.rack",
                        title: "Finance data syncs with Firebase",
                        subtitle: "Entries are saved to your private cloud-backed account for persistence.",
                        color: FinancePalette.oceanBlue
                    )

                    SettingsFeatureCard(
                        icon: "person.2.slash.fill",
                        title: "No data sharing",
                        subtitle: "Your personal finance information is not shared with third parties.",
                        color: FinancePalette.sapphireBlue
                    )

                    SettingsFeatureCard(
                        icon: "square.and.pencil",
                        title: "Manual entry on iOS",
                        subtitle: "Finance Tracker uses manual expense and wallet logging on iPhone.",
                        color: FinancePalette.iceBlue
                    )
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                SettingsSectionTitle(
                    title: "Public URLs",
                    subtitle: "Open the hosted privacy and account deletion pages from inside the app"
                )

                SettingsCard {
                    SettingsInfoRow(
                        icon: "link.circle.fill",
                        title: "Privacy Policy URL",
                        subtitle: "Public page for App Store Connect and user access",
                        value: "Online",
                        color: FinancePalette.royalBlue
                    )

                    SettingsRowDivider()

                    SettingsInfoRow(
                        icon: "trash.circle.fill",
                        title: "Delete Account URL",
                        subtitle: "Public deletion request page for App Store requirements",
                        value: "Online",
                        color: FinancePalette.oceanBlue
                    )
                }

                VStack(spacing: 12) {
                    Link(destination: AppExternalLinks.privacyPolicy) {
                        HStack(spacing: 10) {
                            Image(systemName: "safari.fill")
                                .font(.system(size: 15, weight: .bold))

                            Text("Open Hosted Privacy Policy")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(FinancePalette.royalBlue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(FinancePalette.softBlueBackground(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(FinancePalette.royalBlue.opacity(0.14), lineWidth: 1)
                        )
                    }

                    Link(destination: AppExternalLinks.deleteAccount) {
                        HStack(spacing: 10) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 15, weight: .bold))

                            Text("Open Hosted Delete Account Page")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(FinancePalette.oceanBlue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(FinancePalette.softBlueBackground(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(FinancePalette.oceanBlue.opacity(0.14), lineWidth: 1)
                        )
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(AppExternalLinks.privacyPolicy.absoluteString)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(FinancePalette.textSecondary)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(AppExternalLinks.deleteAccount.absoluteString)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(FinancePalette.textSecondary)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                SettingsSectionTitle(
                    title: "Permissions",
                    subtitle: "What the app needs in this current UI prototype"
                )

                SettingsCard {
                    SettingsInfoRow(
                        icon: "network",
                        title: "Internet",
                        subtitle: "Needed for secure sign-in and finance sync",
                        value: "Required",
                        color: FinancePalette.royalBlue
                    )

                    SettingsRowDivider()

                    SettingsInfoRow(
                        icon: "message.fill",
                        title: "Financial SMS",
                        subtitle: "Not used in this iOS approach",
                        value: "Disabled",
                        color: FinancePalette.oceanBlue
                    )

                    SettingsRowDivider()

                    SettingsInfoRow(
                        icon: "lock.iphone",
                        title: "Device Cache",
                        subtitle: "Temporary local cache used by the app and Firebase SDK",
                        value: "Enabled",
                        color: FinancePalette.sapphireBlue
                    )
                }
            }
        }
    }
}

struct PremiumSubscriptionScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var premiumStore: PremiumStore
    @State private var isShowingManageSubscriptions = false

    var body: some View {
        ProfileSubscreenScaffold(
            title: "Premium",
            subtitle: "Upgrade and restore App Store premium access"
        ) {
            SettingsHeroPanel(
                icon: "crown.fill",
                title: premiumStore.premiumBadgeTitle,
                subtitle: premiumStore.isPremium
                    ? "Your premium access is active on this Apple ID."
                    : "Unlock advanced finance tools with a premium plan.",
                badge: premiumStore.isPremium ? "Active" : "Upgrade",
                accent: FinancePalette.royalBlue
            ) {
                HStack(spacing: 12) {
                    HomeSheetMiniStat(title: "Status", value: premiumStore.isPremium ? "Premium" : "Standard")
                    HomeSheetMiniStat(
                        title: premiumStore.isPremium ? "Renews" : "Plans",
                        value: premiumStore.isPremium
                            ? renewalDateText
                            : (premiumStore.products.isEmpty ? "Loading" : "\(premiumStore.products.count)")
                    )
                }
            }

            if let statusMessage = premiumStore.errorMessage ?? premiumStore.infoMessage {
                ProfileStatusBanner(message: statusMessage)
            }

            VStack(alignment: .leading, spacing: 14) {
                SettingsSectionTitle(
                    title: "Premium Includes",
                    subtitle: "Suggested premium value split for Finance Tracker"
                )

                SettingsCard {
                    SettingsInfoRow(
                        icon: "calendar.badge.clock",
                        title: PremiumFeature.yearlyInsights.title,
                        subtitle: PremiumFeature.yearlyInsights.subtitle,
                        value: "Premium",
                        color: FinancePalette.royalBlue
                    )

                    SettingsRowDivider()

                    SettingsInfoRow(
                        icon: "square.grid.2x2.fill",
                        title: PremiumFeature.customCategories.title,
                        subtitle: PremiumFeature.customCategories.subtitle,
                        value: "Premium",
                        color: FinancePalette.oceanBlue
                    )

                    SettingsRowDivider()

                    SettingsInfoRow(
                        icon: "bell.badge.fill",
                        title: PremiumFeature.premiumAlerts.title,
                        subtitle: PremiumFeature.premiumAlerts.subtitle,
                        value: "Premium",
                        color: FinancePalette.sapphireBlue
                    )
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                SettingsSectionTitle(
                    title: "Available Plans",
                    subtitle: "These product IDs must match App Store Connect exactly"
                )

                if premiumStore.isLoadingProducts && premiumStore.products.isEmpty {
                    SettingsCard {
                        SettingsInfoRow(
                            icon: "arrow.triangle.2.circlepath.circle.fill",
                            title: "Loading plans",
                            subtitle: "Fetching premium products from the App Store",
                            value: "Please wait",
                            color: FinancePalette.royalBlue
                        )
                    }
                } else if premiumStore.products.isEmpty {
                    SettingsCard {
                        SettingsInfoRow(
                            icon: "exclamationmark.circle.fill",
                            title: "No plans loaded",
                            subtitle: "Create the products in App Store Connect, then reopen this screen",
                            value: "Missing",
                            color: FinancePalette.sapphireBlue
                        )
                    }
                } else {
                    VStack(spacing: 12) {
                        ForEach(premiumStore.products, id: \.id) { product in
                            SettingsSelectionCard(
                                icon: PremiumCatalog.plan(for: product.id) == .yearly ? "calendar.circle.fill" : "calendar.badge.clock",
                                title: product.displayName,
                                subtitle: subscriptionSubtitle(for: product),
                                isSelected: premiumStore.activeProductID == product.id,
                                color: FinancePalette.royalBlue,
                                trailingValue: product.displayPrice,
                                action: {
                                    Task {
                                        await premiumStore.purchase(product)
                                    }
                                }
                            )
                        }
                    }
                }
            }

            if premiumStore.isPremium {
                PrimaryActionButton(
                    title: "Manage Subscription",
                    symbol: "slider.horizontal.3",
                    fill: FinancePalette.royalBlue,
                    foreground: .white,
                    stroke: .clear,
                    action: {
                        isShowingManageSubscriptions = true
                    }
                )
            }

            PrimaryActionButton(
                title: premiumStore.isRestoringPurchases ? "Restoring..." : "Restore Purchases",
                symbol: "arrow.clockwise",
                fill: FinancePalette.cardBackground(for: colorScheme),
                foreground: FinancePalette.royalBlue,
                stroke: FinancePalette.border(for: colorScheme),
                action: {
                    Task {
                        await premiumStore.restorePurchases()
                    }
                }
            )
            .disabled(premiumStore.isRestoringPurchases)
        }
        .manageSubscriptionsSheet(isPresented: $isShowingManageSubscriptions)
        .task {
            await premiumStore.fetchProducts()
            await premiumStore.refreshEntitlements()
        }
        .onDisappear {
            premiumStore.clearMessages()
        }
    }

    private var renewalDateText: String {
        guard let expirationDate = premiumStore.activeExpirationDate else {
            return "Active"
        }

        return premiumRenewalFormatter.string(from: expirationDate)
    }

    private func subscriptionSubtitle(for product: Product) -> String {
        switch PremiumCatalog.plan(for: product.id) {
        case .monthly:
            return "Flexible monthly premium access for advanced finance tools."
        case .yearly:
            return "Best-value yearly access for power users and deeper reports."
        case .free:
            return "Premium access plan"
        }
    }
}

private struct PremiumLockedFeaturePanel: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SettingsHeroPanel(
                icon: "crown.fill",
                title: title,
                subtitle: subtitle,
                badge: "Premium",
                accent: FinancePalette.royalBlue
            ) {
                HStack(spacing: 12) {
                    HomeSheetMiniStat(title: "Access", value: "Premium")
                    HomeSheetMiniStat(title: "Where", value: "More > Premium")
                }
            }

            SettingsFeatureCard(
                icon: "sparkles",
                title: "Upgrade to unlock",
                subtitle: "Open the Premium screen from the Profile tab to activate this feature with an App Store subscription.",
                color: FinancePalette.royalBlue
            )
        }
    }
}

private struct HelpCenterScreen: View {
    var body: some View {
        ProfileSubscreenScaffold(
            title: "Help Center",
            subtitle: "Guides and answers for daily app use"
        ) {
            SettingsHeroPanel(
                icon: "questionmark.circle.fill",
                title: "Need a hand?",
                subtitle: "Quick answers for home, wallet, and insights flows.",
                badge: "Support",
                accent: FinancePalette.oceanBlue
            ) {
                HStack(spacing: 12) {
                    HomeSheetMiniStat(title: "Response", value: "Fast")
                    HomeSheetMiniStat(title: "Mode", value: "In-app Help")
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                SettingsSectionTitle(
                    title: "Quick Answers",
                    subtitle: "Common questions users ask first"
                )

                VStack(spacing: 12) {
                    SettingsFeatureCard(
                        icon: "plus.circle.fill",
                        title: "How do I add money to wallet?",
                        subtitle: "Open the Wallet tab and use the Add Money action to log cash or transfers.",
                        color: FinancePalette.royalBlue
                    )

                    SettingsFeatureCard(
                        icon: "chart.bar.fill",
                        title: "How do insights update?",
                        subtitle: "Insights reflect the transactions and wallet entries saved in your account data.",
                        color: FinancePalette.oceanBlue
                    )

                    SettingsFeatureCard(
                        icon: "indianrupeesign.circle.fill",
                        title: "Can I change the currency?",
                        subtitle: "Yes. Open Profile, go to Currency, and switch the money format there.",
                        color: FinancePalette.sapphireBlue
                    )

                    SettingsFeatureCard(
                        icon: "shield.fill",
                        title: "Is my data private?",
                        subtitle: "Yes. Your data is stored in your authenticated Firebase account and not shared across users.",
                        color: FinancePalette.iceBlue
                    )
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                SettingsSectionTitle(
                    title: "Support Contact",
                    subtitle: "Where this product area is currently managed"
                )

                SettingsCard {
                    SettingsInfoRow(
                        icon: "envelope.fill",
                        title: "Support Email",
                        subtitle: "Primary help channel",
                        value: "support@financetracker.app",
                        color: FinancePalette.royalBlue
                    )

                    SettingsRowDivider()

                    SettingsInfoRow(
                        icon: "clock.fill",
                        title: "Expected Reply",
                        subtitle: "Current prototype support window",
                        value: "Within 24 hrs",
                        color: FinancePalette.oceanBlue
                    )
                }
            }
        }
    }
}

private struct AboutFinanceTrackerScreen: View {
    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    private var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }

    var body: some View {
        ProfileSubscreenScaffold(
            title: "About Finance Tracker",
            subtitle: "Product purpose, build info, and current phase"
        ) {
            SettingsHeroPanel(
                icon: "chart.line.text.clipboard.fill",
                title: "Finance Tracker",
                subtitle: "A clean iOS finance app focused on private synced expense, wallet, and investment tracking.",
                badge: "v\(appVersion)",
                accent: FinancePalette.royalBlue
            ) {
                HStack(spacing: 12) {
                    HomeSheetMiniStat(title: "Phase", value: "Cloud Sync")
                    HomeSheetMiniStat(title: "Storage", value: "Firebase")
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                SettingsSectionTitle(
                    title: "Build Information",
                    subtitle: "Current application metadata"
                )

                SettingsCard {
                    SettingsInfoRow(
                        icon: "info.circle.fill",
                        title: "App Version",
                        subtitle: "Current profile and wallet build",
                        value: "v\(appVersion)",
                        color: FinancePalette.royalBlue
                    )

                    SettingsRowDivider()

                    SettingsInfoRow(
                        icon: "hammer.fill",
                        title: "Build Phase",
                        subtitle: "Current development stage",
                        value: "Build \(buildNumber)",
                        color: FinancePalette.oceanBlue
                    )

                    SettingsRowDivider()

                    SettingsInfoRow(
                        icon: "swift",
                        title: "Technology",
                        subtitle: "Primary app stack",
                        value: "SwiftUI",
                        color: FinancePalette.sapphireBlue
                    )
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                SettingsSectionTitle(
                    title: "What This App Covers",
                    subtitle: "The main value areas already planned for the product"
                )

                VStack(spacing: 12) {
                    SettingsFeatureCard(
                        icon: "list.bullet.rectangle.fill",
                        title: "Expense tracking",
                        subtitle: "Log and review day-to-day transactions without clutter.",
                        color: FinancePalette.royalBlue
                    )

                    SettingsFeatureCard(
                        icon: "wallet.pass.fill",
                        title: "Wallet logging",
                        subtitle: "Track liquid money in hand with add and withdraw flows.",
                        color: FinancePalette.oceanBlue
                    )

                    SettingsFeatureCard(
                        icon: "chart.bar.xaxis",
                        title: "Spending insights",
                        subtitle: "See category breakdowns and summaries from your entries.",
                        color: FinancePalette.sapphireBlue
                    )
                }
            }
        }
    }
}

private struct EditableCategorySection: View {
    let title: String
    let subtitle: String
    @Binding var input: String
    let placeholder: String
    let categories: [String]
    let accent: Color
    let addAction: () -> Void
    let removeAction: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SettingsSectionTitle(title: title, subtitle: subtitle)

            SettingsCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 10) {
                        InitialCategoryInputField(
                            placeholder: placeholder,
                            text: $input
                        )

                        Button(action: addAction) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(accent)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }

                    if categories.isEmpty {
                        Text("No custom categories added yet.")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(FinancePalette.textSecondary)
                    } else {
                        FlexibleCategoryWrap(categories: categories, accent: accent, removeAction: removeAction)
                    }
                }
                .padding(.vertical, 10)
            }
        }
    }
}

private struct InitialCategoryInputField: View {
    @Environment(\.colorScheme) private var colorScheme
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(FinancePalette.textPrimary)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(FinancePalette.fieldBackground(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(FinancePalette.border(for: colorScheme), lineWidth: 1)
            )
    }
}

private struct FlexibleCategoryWrap: View {
    @Environment(\.colorScheme) private var colorScheme
    let categories: [String]
    let accent: Color
    let removeAction: (String) -> Void

    private let columns = [GridItem(.adaptive(minimum: 92), spacing: 8, alignment: .leading)]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(categories, id: \.self) { category in
                Button(action: { removeAction(category) }) {
                    HStack(spacing: 6) {
                        Text(category)
                            .font(.system(size: 12, weight: .bold, design: .rounded))

                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 999, style: .continuous)
                            .fill(colorScheme == .dark ? accent.opacity(0.16) : accent.opacity(0.10))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 999, style: .continuous)
                            .stroke(colorScheme == .dark ? accent.opacity(0.18) : Color.clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private let premiumRenewalFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()

private struct ProfileSubscreenScaffold<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    content
                }
                .frame(maxWidth: 430)
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 40)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)

                Text(subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(FinancePalette.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(FinancePalette.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(FinancePalette.cardBackground(for: colorScheme))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(FinancePalette.border(for: colorScheme), lineWidth: 1)
                    )
                    .shadow(color: FinancePalette.shadow(for: colorScheme).opacity(0.45), radius: 12, y: 8)
            }
            .buttonStyle(.plain)
        }
    }
}

private struct SettingsHeroPanel<Content: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let badge: String
    let accent: Color
    @ViewBuilder let content: Content

    init(
        icon: String,
        title: String,
        subtitle: String,
        badge: String,
        accent: Color,
        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.badge = badge
        self.accent = accent
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white.opacity(0.14))
                        .frame(width: 60, height: 60)

                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.78))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }

                Spacer(minLength: 8)

                Text(badge)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(FinancePalette.navyBlue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.92))
                    .clipShape(Capsule())
            }

            content
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [FinancePalette.navyBlue, accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: accent.opacity(0.20), radius: 20, y: 14)
    }
}

private struct ProfileChip: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color.white.opacity(0.14))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
    }
}

private struct ProfileStatusBanner: View {
    @Environment(\.colorScheme) private var colorScheme
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(FinancePalette.royalBlue)
                .padding(.top, 2)

            Text(message)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(FinancePalette.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(FinancePalette.elevatedBackground(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(FinancePalette.border(for: colorScheme), lineWidth: 1)
        )
        .shadow(color: FinancePalette.shadow(for: colorScheme).opacity(0.28), radius: 10, y: 8)
    }
}

private struct ProfileStatTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.74))

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }
}
