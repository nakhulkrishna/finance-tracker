import SwiftUI

struct MoreSettingsScreen: View {
    @State private var spendingAlerts = true
    @State private var weeklyInsights = true
    @State private var biometricLock = false
    @State private var lockOnLaunch = false
    @State private var hideRecentActivity = false
    @State private var selectedCurrency: ProfileCurrency = .inr
    @State private var preferredWalletSource: WalletPreferenceSource = .bankTransfer
    @State private var showWalletSyncStatus = true
    @State private var showWalletActivityPreview = true
    @State private var activeRoute: ProfileRoute?
    @State private var isShowingNotifications = false
    @State private var hasAnimatedIn = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                DashboardHeader(
                    title: "Profile",
                    subtitle: "Settings and privacy",
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
                        preferredSource: $preferredWalletSource,
                        showWalletSyncStatus: $showWalletSyncStatus,
                        showWalletActivityPreview: $showWalletActivityPreview
                    )
                case .securityPrivacy:
                    SecurityPrivacyScreen(
                        biometricLock: $biometricLock,
                        lockOnLaunch: $lockOnLaunch,
                        hideRecentActivity: $hideRecentActivity
                    )
                case .currency:
                    CurrencySettingsScreen(selectedCurrency: $selectedCurrency)
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

                    Text("NK")
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
                Text("Nakhul Krishna")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text("Personal finance dashboard owner")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.76))
                    .lineLimit(1)
            }

            HStack(spacing: 8) {
                Text("PREMIUM")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(FinancePalette.navyBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.92))
                    .clipShape(Capsule())

                ProfileChip(title: "On-device only")
            }

            HStack(spacing: 14) {
                ProfileStatTile(title: "Wallet", value: "₹24.8K")
                ProfileStatTile(title: "This Month", value: "₹42.1K")
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
                    .fill(FinancePalette.paleBlue)
                    .frame(width: 58, height: 58)

                Image(systemName: "shield.lefthalf.filled")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(FinancePalette.royalBlue)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Private by design")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)

                Text("Transactions and wallet logs stay on this iPhone only.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(FinancePalette.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 12)

            Text("Protected")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(FinancePalette.royalBlue)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(FinancePalette.paleBlue)
                .clipShape(Capsule())
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white, FinancePalette.mistBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(FinancePalette.icyBlue.opacity(0.96), lineWidth: 1)
        )
        .shadow(color: FinancePalette.cardShadow.opacity(0.42), radius: 14, y: 10)
    }

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            SettingsSectionTitle(
                title: "Account",
                subtitle: "Personal details and finance access"
            )

            SettingsCard {
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
                    value: biometricLock ? "Face ID" : "Local",
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
                    value: selectedCurrency.code,
                    color: FinancePalette.royalBlue,
                    action: {
                        activeRoute = .currency
                    }
                )

                SettingsRowDivider()

                SettingsToggleRow(
                    icon: "bell.badge.fill",
                    title: "Spending Alerts",
                    subtitle: "Get reminders for manual expense updates",
                    isOn: $spendingAlerts,
                    color: FinancePalette.oceanBlue
                )

                SettingsRowDivider()

                SettingsToggleRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Weekly Insights",
                    subtitle: "Show a weekly finance summary prompt",
                    isOn: $weeklyInsights,
                    color: FinancePalette.royalBlue
                )

                SettingsRowDivider()

                SettingsToggleRow(
                    icon: "faceid",
                    title: "Biometric Lock",
                    subtitle: "Add Face ID before sensitive screens",
                    isOn: $biometricLock,
                    color: FinancePalette.sapphireBlue
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
}

private enum ProfileRoute: String, Identifiable {
    case personalDetails
    case walletPreferences
    case securityPrivacy
    case currency
    case privacyPolicy
    case helpCenter
    case about

    var id: String { rawValue }
}

private enum ProfileCurrency: String, CaseIterable, Identifiable {
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

private enum WalletPreferenceSource: String, CaseIterable, Identifiable {
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
}

private struct ProfileDetailsScreen: View {
    var body: some View {
        ProfileSubscreenScaffold(
            title: "Personal Details",
            subtitle: "Profile identity and account basics"
        ) {
            SettingsHeroPanel(
                icon: "person.crop.circle.fill",
                title: "Nakhul Krishna",
                subtitle: "Personal finance dashboard owner",
                badge: "Verified",
                accent: FinancePalette.royalBlue
            ) {
                HStack(spacing: 12) {
                    HomeSheetMiniStat(title: "Member Since", value: "Apr 2026")
                    HomeSheetMiniStat(title: "Plan", value: "Premium")
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                SettingsSectionTitle(
                    title: "Identity",
                    subtitle: "Core information used by the app"
                )

                SettingsCard {
                    SettingsInfoRow(
                        icon: "person.fill",
                        title: "Full Name",
                        subtitle: "Primary profile name",
                        value: "Nakhul Krishna",
                        color: FinancePalette.royalBlue
                    )

                    SettingsRowDivider()

                    SettingsInfoRow(
                        icon: "phone.fill",
                        title: "Mobile",
                        subtitle: "Contact number for your account",
                        value: "+91 98XXXXXX42",
                        color: FinancePalette.oceanBlue
                    )

                    SettingsRowDivider()

                    SettingsInfoRow(
                        icon: "envelope.fill",
                        title: "Email",
                        subtitle: "Primary app email",
                        value: "nakhul@financetracker.app",
                        color: FinancePalette.sapphireBlue
                    )
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                SettingsSectionTitle(
                    title: "Finance Profile",
                    subtitle: "How your account is configured today"
                )

                SettingsCard {
                    SettingsInfoRow(
                        icon: "square.and.pencil",
                        title: "Tracking Mode",
                        subtitle: "iOS entry behavior",
                        value: "Manual Entry",
                        color: FinancePalette.royalBlue
                    )

                    SettingsRowDivider()

                    SettingsInfoRow(
                        icon: "internaldrive.fill",
                        title: "Data Storage",
                        subtitle: "Where app data currently lives",
                        value: "On-device",
                        color: FinancePalette.oceanBlue
                    )

                    SettingsRowDivider()

                    SettingsInfoRow(
                        icon: "location.fill",
                        title: "Region",
                        subtitle: "Primary money and locale setup",
                        value: "India",
                        color: FinancePalette.sapphireBlue
                    )
                }
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
                subtitle: "This iOS MVP keeps finance tracking local and controlled.",
                badge: "Protected",
                accent: FinancePalette.sapphireBlue
            ) {
                HStack(spacing: 12) {
                    HomeSheetMiniStat(title: "Processing", value: "Local")
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
                        value: "On-device only",
                        color: FinancePalette.royalBlue
                    )

                    SettingsRowDivider()

                    SettingsInfoRow(
                        icon: "icloud.slash.fill",
                        title: "Cloud Sync",
                        subtitle: "Remote backup status",
                        value: "Disabled",
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

private struct PrivacyPolicyScreen: View {
    var body: some View {
        ProfileSubscreenScaffold(
            title: "Privacy Policy",
            subtitle: "How Finance Tracker handles your data"
        ) {
            SettingsHeroPanel(
                icon: "hand.raised.fill",
                title: "Your data stays with you",
                subtitle: "This current iOS version is designed around local-first finance tracking.",
                badge: "Local Only",
                accent: FinancePalette.sapphireBlue
            ) {
                HStack(spacing: 12) {
                    HomeSheetMiniStat(title: "Server Storage", value: "None")
                    HomeSheetMiniStat(title: "Sharing", value: "Disabled")
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
                        title: "All processing is local",
                        subtitle: "Balances, wallet logs, and insights are handled directly on the device.",
                        color: FinancePalette.royalBlue
                    )

                    SettingsFeatureCard(
                        icon: "server.rack",
                        title: "No finance data stored on servers",
                        subtitle: "The MVP does not upload transactions or wallet entries to a backend.",
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
                    title: "Permissions",
                    subtitle: "What the app needs in this current UI prototype"
                )

                SettingsCard {
                    SettingsInfoRow(
                        icon: "network",
                        title: "Internet",
                        subtitle: "Reserved for future ad modules and app metadata",
                        value: "Optional",
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
                        title: "Device Storage",
                        subtitle: "Local data storage for app entries and insights",
                        value: "Enabled",
                        color: FinancePalette.sapphireBlue
                    )
                }
            }
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
                        subtitle: "Insights reflect the transaction and wallet entries available in the app's local data.",
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
                        subtitle: "Yes. The current iOS MVP is local-first and avoids server-side finance storage.",
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
    var body: some View {
        ProfileSubscreenScaffold(
            title: "About Finance Tracker",
            subtitle: "Product purpose, build info, and current phase"
        ) {
            SettingsHeroPanel(
                icon: "chart.line.text.clipboard.fill",
                title: "Finance Tracker",
                subtitle: "A clean iOS finance app focused on local expense and wallet tracking.",
                badge: "v1.0",
                accent: FinancePalette.royalBlue
            ) {
                HStack(spacing: 12) {
                    HomeSheetMiniStat(title: "Phase", value: "UI MVP")
                    HomeSheetMiniStat(title: "Storage", value: "Local")
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
                        value: "1.0",
                        color: FinancePalette.royalBlue
                    )

                    SettingsRowDivider()

                    SettingsInfoRow(
                        icon: "hammer.fill",
                        title: "Build Phase",
                        subtitle: "Current development stage",
                        value: "UI Prototype",
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

private struct ProfileSubscreenScaffold<Content: View>: View {
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
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(FinancePalette.icyBlue, lineWidth: 1)
                    )
                    .shadow(color: FinancePalette.cardShadow.opacity(0.45), radius: 12, y: 8)
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
                        .lineLimit(1)

                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.78))
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
