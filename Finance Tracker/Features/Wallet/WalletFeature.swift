import LocalAuthentication
import SwiftUI

struct WalletScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var financeStore: FinanceStore

    private let actionColumns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    @State private var activeRoute: WalletRoute?
    @State private var isShowingNotifications = false
    @State private var isBalanceUnlocked = false
    @State private var isUnlockingBalance = false
    @State private var balanceSecurityMessage: String?
    @State private var unlockMethod: DeviceAuthenticationMethod = .faceID

    private var recentEntries: [WalletEntry] {
        financeStore.recentWalletEntries
    }

    private var historySections: [WalletActivitySection] {
        financeStore.walletSections
    }

    private var displayedBalanceText: String {
        requiresBalanceUnlock && !isBalanceUnlocked ? "••••••" : financeStore.walletBalanceText
    }

    private var requiresBalanceUnlock: Bool {
        authStore.profilePreferences.biometricLock
    }

    private var shouldConcealWalletAmounts: Bool {
        requiresBalanceUnlock && !isBalanceUnlocked
    }

    private func concealedAmount(_ value: String) -> String {
        shouldConcealWalletAmounts ? "••••••" : value
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                DashboardHeader(
                    title: "Wallet",
                    subtitle: "Liquid money, ready to use",
                    notificationAction: {
                        isShowingNotifications = true
                    }
                )

                walletCard
                quickActionsSection
                activitySection
            }
            .frame(maxWidth: 430)
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 120)
        }
        .sheet(item: $activeRoute) { route in
            switch route {
            case .addMoney:
                WalletActionSheet(action: .addMoney)
                    .environmentObject(financeStore)
                    .presentationDetents([.height(560), .large])
                    .presentationDragIndicator(.visible)
            case .withdraw:
                WalletActionSheet(action: .withdraw)
                    .environmentObject(financeStore)
                    .presentationDetents([.height(560), .large])
                    .presentationDragIndicator(.visible)
            case .history:
                WalletActivityScreen(
                    sections: historySections,
                    currentBalance: financeStore.walletBalance
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
            }
        }
        .sheet(isPresented: $isShowingNotifications) {
            InsightsNotificationsScreen()
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
        .onAppear {
            unlockMethod = DeviceAuthenticationMethod.availableMethod()
            isBalanceUnlocked = !requiresBalanceUnlock
        }
        .onChange(of: authStore.profilePreferences.biometricLock) { _, isEnabled in
            withAnimation(.smooth(duration: 0.25)) {
                isBalanceUnlocked = !isEnabled
            }
        }
    }

    private var walletCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Liquid Wallet")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.82))

                    HStack(spacing: 10) {
                        Text(displayedBalanceText)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())

                        if requiresBalanceUnlock {
                            Button(action: {
                                if isBalanceUnlocked {
                                    withAnimation(.smooth(duration: 0.25)) {
                                        isBalanceUnlocked = false
                                    }
                                } else {
                                    unlockBalance()
                                }
                            }) {
                                Image(systemName: isBalanceUnlocked ? "eye.fill" : unlockMethod.symbol)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 32, height: 32)
                                    .background(Color.white.opacity(0.12))
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                            .disabled(isUnlockingBalance)
                        }
                    }

                    Text(balanceSupportingText)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.76))
                }

                Spacer(minLength: 12)

                Text(requiresBalanceUnlock && !isBalanceUnlocked ? "Locked" : "Available")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(FinancePalette.navyBlue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.94))
                    .clipShape(Capsule())
            }

            if let balanceSecurityMessage {
                Text(balanceSecurityMessage)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.82))
                    .lineLimit(2)
            }

            HStack(spacing: 12) {
                WalletMetricPill(title: "Money In", value: concealedAmount(financeStore.walletMonthlyIn.currencyText))
                WalletMetricPill(title: "Money Out", value: concealedAmount(financeStore.walletMonthlyOut.currencyText))
            }

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Cash entries")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.74))

                    Text("\(financeStore.walletEntryCount)")
                        .font(.system(size: 19, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }

                Spacer()

                if authStore.profilePreferences.showWalletSyncStatus {
                    VStack(alignment: .trailing, spacing: 6) {
                        Text("Last update")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.74))

                        Text(financeStore.walletLastUpdatedText)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                    }
                }
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
                    .fill(Color.white.opacity(0.16))
                    .frame(width: 180, height: 180)
                    .blur(radius: 10)
                    .offset(x: 112, y: -72)

                Circle()
                    .fill(FinancePalette.iceBlue.opacity(0.28))
                    .frame(width: 120, height: 120)
                    .blur(radius: 14)
                    .offset(x: -126, y: 72)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: FinancePalette.royalBlue.opacity(0.22), radius: 22, y: 16)
    }

    private var balanceSupportingText: String {
        guard requiresBalanceUnlock else {
            return "Ready to use"
        }

        if isUnlockingBalance {
            return "Checking \(unlockMethod.title)..."
        }

        return isBalanceUnlocked ? "Unlocked for this session" : "Tap to unlock with \(unlockMethod.title)"
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Cash Actions")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(FinancePalette.textPrimary)

            LazyVGrid(columns: actionColumns, spacing: 14) {
                Button(action: {
                    activeRoute = .addMoney
                }) {
                    WalletActionCard(
                        title: "Add Money",
                        subtitle: "Log liquid cash added",
                        amount: concealedAmount(financeStore.walletMonthlyIn.signedCurrencyText),
                        icon: "arrow.down.circle.fill",
                        color: FinancePalette.royalBlue
                    )
                }
                .buttonStyle(.plain)

                Button(action: {
                    activeRoute = .withdraw
                }) {
                    WalletActionCard(
                        title: "Withdraw",
                        subtitle: "Record money taken out",
                        amount: concealedAmount((-financeStore.walletMonthlyOut).signedCurrencyText),
                        icon: "arrow.up.circle.fill",
                        color: FinancePalette.sapphireBlue
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Cash Log")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)

                Spacer()

                Button(action: {
                    activeRoute = .history
                }) {
                    Text("View All")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(FinancePalette.royalBlue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(FinancePalette.softBlueBackground(for: colorScheme))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            VStack(spacing: 12) {
                if recentEntries.isEmpty {
                    EmptyWalletEntriesCard()
                } else {
                    ForEach(recentEntries) { entry in
                        WalletEntryRow(entry: entry, showsAmount: !shouldConcealWalletAmounts)
                    }
                }
            }
        }
        .opacity(authStore.profilePreferences.showWalletActivityPreview ? 1 : 0)
        .frame(height: authStore.profilePreferences.showWalletActivityPreview ? nil : 0)
        .clipped()
    }

    private func unlockBalance() {
        guard !isUnlockingBalance else { return }

        balanceSecurityMessage = nil
        unlockMethod = DeviceAuthenticationMethod.availableMethod()

        Task {
            isUnlockingBalance = true
            let result = await DeviceAuthenticator.authenticate(
                reason: "Reveal your liquid wallet balance."
            )

            switch result {
            case let .success(method):
                unlockMethod = method
                withAnimation(.smooth(duration: 0.25)) {
                    isBalanceUnlocked = true
                    balanceSecurityMessage = nil
                }
            case let .failure(message):
                balanceSecurityMessage = message
                withAnimation(.smooth(duration: 0.25)) {
                    isBalanceUnlocked = false
                }
            }

            isUnlockingBalance = false
        }
    }
}

private enum WalletRoute: String, Identifiable {
    case addMoney
    case withdraw
    case history

    var id: String { rawValue }
}

private enum WalletQuickAction {
    case addMoney
    case withdraw

    var title: String {
        switch self {
        case .addMoney:
            return "Add Money"
        case .withdraw:
            return "Withdraw Cash"
        }
    }

    var subtitle: String {
        switch self {
        case .addMoney:
            return "Log money flowing into your liquid wallet balance."
        case .withdraw:
            return "Record cash moving out for spending or transfer."
        }
    }

    var icon: String {
        switch self {
        case .addMoney:
            return "arrow.down.circle.fill"
        case .withdraw:
            return "arrow.up.circle.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .addMoney:
            return FinancePalette.royalBlue
        case .withdraw:
            return FinancePalette.sapphireBlue
        }
    }

    var badgeTitle: String {
        switch self {
        case .addMoney:
            return "Wallet In"
        case .withdraw:
            return "Wallet Out"
        }
    }

    var amountPlaceholder: String {
        switch self {
        case .addMoney:
            return "2,500"
        case .withdraw:
            return "850"
        }
    }

    var sourceTitle: String {
        switch self {
        case .addMoney:
            return "Source"
        case .withdraw:
            return "Destination"
        }
    }

    var sourcePlaceholder: String {
        switch self {
        case .addMoney:
            return "Bank / Salary / Cash"
        case .withdraw:
            return "Groceries / ATM / Travel"
        }
    }

    var notePlaceholder: String {
        switch self {
        case .addMoney:
            return "Optional note about this money"
        case .withdraw:
            return "Optional reason for this cash out"
        }
    }

    var tagTitle: String {
        switch self {
        case .addMoney:
            return "Deposit Type"
        case .withdraw:
            return "Purpose"
        }
    }

    var tags: [String] {
        switch self {
        case .addMoney:
            return ["Cash", "Salary", "Refund", "Transfer"]
        case .withdraw:
            return ["Food", "Travel", "Bills", "Shopping"]
        }
    }

    var actionTitle: String {
        switch self {
        case .addMoney:
            return "Confirm Add Money"
        case .withdraw:
            return "Confirm Withdraw"
        }
    }
}

private struct WalletActionSheet: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var financeStore: FinanceStore
    @EnvironmentObject private var premiumStore: PremiumStore

    let action: WalletQuickAction

    @State private var amount: String
    @State private var source: String
    @State private var note: String
    @State private var selectedTag: String
    @State private var selectedDate: Date
    @State private var errorMessage: String?

    init(action: WalletQuickAction) {
        self.action = action
        _amount = State(initialValue: "")
        _source = State(initialValue: "")
        _note = State(initialValue: "")
        _selectedTag = State(initialValue: action.tags.first ?? "")
        _selectedDate = State(initialValue: .now)
    }

    private var availableTags: [String] {
        let customTags: [String]

        switch action {
        case .addMoney:
            customTags = premiumStore.hasAccess(to: .customCategories)
                ? authStore.profilePreferences.walletAddCategories
                : []
        case .withdraw:
            customTags = premiumStore.hasAccess(to: .customCategories)
                ? authStore.profilePreferences.walletWithdrawCategories
                : []
        }

        return uniqueTags(from: action.tags + customTags)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(action.accentColor.opacity(0.12))
                            .frame(width: 58, height: 58)

                        Image(systemName: action.icon)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(action.accentColor)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(action.title)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(FinancePalette.textPrimary)

                        Text(action.subtitle)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(FinancePalette.textSecondary)
                    }

                    Spacer(minLength: 8)

                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(FinancePalette.textSecondary)
                            .frame(width: 34, height: 34)
                            .background(FinancePalette.cardBackground(for: colorScheme))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(FinancePalette.border(for: colorScheme), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Liquid Balance")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.76))

                            Text(financeStore.walletBalanceText)
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .contentTransition(.numericText())
                        }

                        Spacer()

                        Text(action.badgeTitle)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(FinancePalette.navyBlue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.92))
                            .clipShape(Capsule())
                    }

                    HStack(spacing: 12) {
                        HomeSheetMiniStat(title: "Money In", value: financeStore.walletMonthlyIn.currencyText)
                        HomeSheetMiniStat(title: "Money Out", value: financeStore.walletMonthlyOut.currencyText)
                    }
                }
                .padding(22)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [FinancePalette.navyBlue, action.accentColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: action.accentColor.opacity(0.20), radius: 20, y: 14)

                VStack(alignment: .leading, spacing: 16) {
                    if let errorMessage {
                        WalletSheetStatusBanner(message: errorMessage)
                    }

                    HomeSheetField(
                        title: "Amount",
                        prefix: "₹",
                        placeholder: action.amountPlaceholder,
                        text: $amount
                    )

                    HomeSheetField(
                        title: action.sourceTitle,
                        prefix: nil,
                        placeholder: action.sourcePlaceholder,
                        text: $source
                    )

                    HomeSheetDateField(
                        title: "Date & Time",
                        date: $selectedDate
                    )

                    VStack(alignment: .leading, spacing: 10) {
                        Text(action.tagTitle)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(FinancePalette.textSecondary)

                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                            ForEach(availableTags, id: \.self) { tag in
                                HomeActionTagChip(
                                    title: tag,
                                    isSelected: selectedTag == tag,
                                    accentColor: action.accentColor,
                                    action: {
                                        selectedTag = tag
                                    }
                                )
                            }
                        }
                    }

                    HomeSheetField(
                        title: "Note",
                        prefix: nil,
                        placeholder: action.notePlaceholder,
                        text: $note
                    )
                }

                PrimaryActionButton(
                    title: action.actionTitle,
                    symbol: action == .addMoney ? "plus" : "arrow.up.right",
                    fill: action.accentColor,
                    foreground: .white,
                    stroke: .clear,
                    action: {
                        let result: String?

                        switch action {
                        case .addMoney:
                            result = financeStore.submitWalletAddMoney(
                                amountText: amount,
                                source: source,
                                note: note,
                                category: selectedTag,
                                entryDate: selectedDate
                            )
                        case .withdraw:
                            result = financeStore.submitWalletWithdraw(
                                amountText: amount,
                                destination: source,
                                note: note,
                                category: selectedTag,
                                entryDate: selectedDate
                            )
                        }

                        if let result {
                            errorMessage = result
                        } else {
                            dismiss()
                        }
                    }
                )
            }
            .padding(.horizontal, 22)
            .padding(.top, 20)
            .padding(.bottom, 28)
        }
        .background(
            LinearGradient(
                colors: FinancePalette.sheetGradientColors(for: colorScheme),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear {
            if action == .addMoney {
                let preferredSource = authStore.profilePreferences.preferredWalletSource

                if source.isEmpty {
                    source = preferredSource.title
                }

                if availableTags.contains(preferredSource.walletTag) {
                    selectedTag = preferredSource.walletTag
                } else if !availableTags.contains(selectedTag), let firstTag = availableTags.first {
                    selectedTag = firstTag
                }
            } else if !availableTags.contains(selectedTag), let firstTag = availableTags.first {
                selectedTag = firstTag
            }
        }
    }

    private func uniqueTags(from items: [String]) -> [String] {
        var seen = Set<String>()

        return items.compactMap { item in
            let cleaned = item.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !cleaned.isEmpty else { return nil }
            let key = cleaned.lowercased()
            guard !seen.contains(key) else { return nil }
            seen.insert(key)
            return cleaned
        }
    }
}

private struct WalletActivityScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    let sections: [WalletActivitySection]
    let currentBalance: Double

    @State private var selectedFilter: WalletHistoryFilter = .all

    private var filteredSections: [WalletActivitySection] {
        sections.compactMap { section in
            let filteredEntries = section.entries.filter { entry in
                selectedFilter.matches(sectionTitle: section.title, entry: entry)
            }

            guard !filteredEntries.isEmpty else { return nil }
            return WalletActivitySection(title: section.title, entries: filteredEntries)
        }
    }

    private var allVisibleEntries: [WalletEntry] {
        filteredSections.flatMap(\.entries)
    }

    private var totalIn: Double {
        allVisibleEntries
            .filter { $0.kind == .deposit }
            .reduce(0) { $0 + $1.numericAmount }
    }

    private var totalOut: Double {
        allVisibleEntries
            .filter { $0.kind == .withdrawal }
            .reduce(0) { $0 + abs($1.numericAmount) }
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    summaryCard
                    filtersRow
                    activityList
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
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(FinancePalette.textPrimary)
                    .frame(width: 42, height: 42)
                    .background(FinancePalette.cardBackground(for: colorScheme))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(FinancePalette.border(for: colorScheme), lineWidth: 1)
                    )
                    .shadow(color: FinancePalette.shadow(for: colorScheme).opacity(0.45), radius: 12, y: 8)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text("Wallet Activity")
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)

                Text("Every liquid money movement in one place")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(FinancePalette.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            HeaderIconButton(symbol: "clock.arrow.circlepath")
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Visible Wallet Balance")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.76))

                    Text(currentBalance.currencyText)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                }

                Spacer()

                Text(selectedFilter.rawValue)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(FinancePalette.navyBlue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.92))
                    .clipShape(Capsule())
            }

            HStack(spacing: 12) {
                HomeSheetMiniStat(title: "Money In", value: totalIn.currencyText)
                HomeSheetMiniStat(title: "Money Out", value: totalOut.currencyText)
            }
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [FinancePalette.navyBlue, FinancePalette.sapphireBlue, FinancePalette.royalBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: FinancePalette.royalBlue.opacity(0.20), radius: 20, y: 14)
    }

    private var filtersRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(WalletHistoryFilter.allCases) { filter in
                    Button(action: {
                        withAnimation(.smooth(duration: 0.25)) {
                            selectedFilter = filter
                        }
                    }) {
                        Text(filter.rawValue)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(selectedFilter == filter ? .white : FinancePalette.royalBlue)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                Group {
                                    if selectedFilter == filter {
                                        LinearGradient(
                                            colors: [FinancePalette.royalBlue, FinancePalette.oceanBlue],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    } else {
                                        FinancePalette.cardBackground(for: colorScheme)
                                    }
                                }
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(
                                        selectedFilter == filter ? Color.clear : FinancePalette.border(for: colorScheme),
                                        lineWidth: 1
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }

    private var activityList: some View {
        VStack(alignment: .leading, spacing: 16) {
            if filteredSections.isEmpty {
                EmptyWalletHistoryCard()
            } else {
                ForEach(filteredSections) { section in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(section.title)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(FinancePalette.textSecondary)

                        ForEach(section.entries) { entry in
                            WalletEntryRow(entry: entry)
                        }
                    }
                }
            }
        }
    }
}

private struct WalletSheetStatusBanner: View {
    @Environment(\.colorScheme) private var colorScheme
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color(red: 0.72, green: 0.16, blue: 0.20))
                .padding(.top, 2)

            Text(message)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(red: 0.72, green: 0.16, blue: 0.20))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(
            colorScheme == .dark
                ? Color(red: 0.27, green: 0.14, blue: 0.16)
                : Color(red: 1.0, green: 0.94, blue: 0.95)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private enum WalletHistoryFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case today = "Today"
    case moneyIn = "Money In"
    case moneyOut = "Money Out"

    var id: String { rawValue }

    func matches(sectionTitle: String, entry: WalletEntry) -> Bool {
        switch self {
        case .all:
            return true
        case .today:
            return sectionTitle == "Today"
        case .moneyIn:
            return entry.kind == .deposit
        case .moneyOut:
            return entry.kind == .withdrawal
        }
    }
}

private struct WalletMetricPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))

            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
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

private struct WalletActionCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let subtitle: String
    let amount: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(color.opacity(0.10))
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(color)
                }

                Spacer()

                Text(amount)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)

                Text(subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(FinancePalette.textSecondary)
                    .lineLimit(2)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 144, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(FinancePalette.elevatedBackground(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(FinancePalette.border(for: colorScheme), lineWidth: 1)
        )
        .shadow(color: FinancePalette.shadow(for: colorScheme).opacity(0.44), radius: 14, y: 10)
    }
}

private struct WalletEntryRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let entry: WalletEntry
    var showsAmount: Bool = true

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(entry.kind.color.opacity(0.10))
                    .frame(width: 50, height: 50)

                Image(systemName: entry.kind.icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(entry.kind.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)

                Text(entry.subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(FinancePalette.textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(showsAmount ? entry.amount : "••••••")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(entry.kind.color)

                Text(entry.time)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(FinancePalette.textSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(FinancePalette.elevatedBackground(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(FinancePalette.border(for: colorScheme), lineWidth: 1)
        )
        .shadow(color: FinancePalette.shadow(for: colorScheme).opacity(0.36), radius: 12, y: 8)
    }
}

private struct EmptyWalletEntriesCard: View {
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SettingsIconBadge(icon: "wallet.pass.fill", color: FinancePalette.royalBlue)

            Text("No wallet activity yet")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(FinancePalette.textPrimary)

            Text("Use Add Money or Withdraw to start tracking your liquid wallet balance.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(FinancePalette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(FinancePalette.elevatedBackground(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(FinancePalette.border(for: colorScheme), lineWidth: 1)
        )
        .shadow(color: FinancePalette.shadow(for: colorScheme).opacity(0.34), radius: 12, y: 8)
    }
}

private struct EmptyWalletHistoryCard: View {
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("No wallet history yet")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(FinancePalette.textPrimary)

            Text("Your cash adds and withdraws will appear here once you start using the wallet.")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(FinancePalette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(FinancePalette.elevatedBackground(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(FinancePalette.border(for: colorScheme), lineWidth: 1)
        )
        .shadow(color: FinancePalette.shadow(for: colorScheme).opacity(0.36), radius: 12, y: 8)
    }
}

enum DeviceAuthenticationMethod {
    case faceID
    case touchID
    case passcode

    var title: String {
        switch self {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .passcode:
            return "Passcode"
        }
    }

    var symbol: String {
        switch self {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        case .passcode:
            return "lock.fill"
        }
    }

    static func availableMethod() -> DeviceAuthenticationMethod {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            return DeviceAuthenticationMethod(biometryType: context.biometryType)
        }

        return .passcode
    }

    init(biometryType: LABiometryType) {
        switch biometryType {
        case .faceID:
            self = .faceID
        case .touchID:
            self = .touchID
        default:
            self = .passcode
        }
    }
}

enum DeviceAuthenticationResult {
    case success(DeviceAuthenticationMethod)
    case failure(String)
}

enum DeviceAuthenticator {
    static func authenticate(reason: String) async -> DeviceAuthenticationResult {
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"

        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let method = DeviceAuthenticationMethod(biometryType: context.biometryType)

            do {
                let success = try await context.evaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics,
                    localizedReason: reason
                )

                return success ? .success(method) : .failure("Authentication did not complete.")
            } catch {
                return .failure(message(for: error))
            }
        }

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            do {
                let success = try await context.evaluatePolicy(
                    .deviceOwnerAuthentication,
                    localizedReason: reason
                )

                return success ? .success(.passcode) : .failure("Authentication did not complete.")
            } catch {
                return .failure(message(for: error))
            }
        }

        return .failure(message(for: error))
    }

    private static func message(for error: Error?) -> String {
        guard let laError = error as? LAError else {
            return "Face ID or device authentication is not available on this device yet."
        }

        switch laError.code {
        case .biometryNotAvailable:
            return "Face ID or Touch ID is not available on this device."
        case .biometryNotEnrolled:
            return "Set up Face ID or Touch ID in Settings to protect the wallet balance."
        case .passcodeNotSet:
            return "Set a device passcode first before using balance protection."
        case .userCancel, .systemCancel, .appCancel:
            return "Balance unlock was cancelled."
        case .authenticationFailed:
            return "The identity check failed. Please try again."
        default:
            return laError.localizedDescription
        }
    }
}
