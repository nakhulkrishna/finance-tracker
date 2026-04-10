import SwiftUI

struct InvestmentsScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var financeStore: FinanceStore

    @State private var activeAction: InvestmentActionKind?
    @State private var isShowingHistory = false
    @State private var isShowingNotifications = false

    private var totalInvested: Double {
        financeStore.totalInvestedAmount
    }

    private var totalCurrentValue: Double {
        financeStore.totalInvestmentBalance
    }

    private var familyHeldValue: Double {
        financeStore.familyHeldInvestmentValue
    }

    private var totalRedeemed: Double {
        financeStore.totalRedeemedAmount
    }

    private var holdings: [InvestmentHolding] {
        financeStore.investmentHoldings
    }

    private var activitySections: [InvestmentActivitySection] {
        financeStore.investmentActivitySections
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                DashboardHeader(
                    title: "Investments",
                    subtitle: "Your money, tracked as assets",
                    notificationAction: {
                        isShowingNotifications = true
                    }
                )

                heroCard
                overviewRow
                holdingsSection
            }
            .frame(maxWidth: 430)
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 120)
        }
        .sheet(item: $activeAction) { action in
            InvestmentActionSheet(
                action: action,
                totalCurrentValue: totalCurrentValue,
                familyHeldValue: familyHeldValue
            )
            .environmentObject(financeStore)
            .presentationDetents([.height(590), .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isShowingHistory) {
            InvestmentHistoryScreen(sections: activitySections, totalInvested: totalInvested, totalCurrentValue: totalCurrentValue)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $isShowingNotifications) {
            InsightsNotificationsScreen()
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Asset Balance")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.78))

                    Text(totalCurrentValue.currencyText)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.78)
                        .contentTransition(.numericText())

                    Text(holdings.isEmpty ? "Start tracking money outside your bank" : "Not counted in expenses")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.78))
                }

                Spacer(minLength: 10)

                Text("Asset")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(FinancePalette.navyBlue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.94))
                    .clipShape(Capsule())
            }

            HStack(spacing: 12) {
                PrimaryActionButton(
                    title: "Add",
                    symbol: "plus",
                    fill: .white,
                    foreground: FinancePalette.royalBlue,
                    stroke: .clear,
                    action: {
                        activeAction = .add
                    }
                )

                PrimaryActionButton(
                    title: "Redeem",
                    symbol: "arrow.up.right",
                    fill: FinancePalette.sapphireBlue.opacity(0.94),
                    foreground: .white,
                    stroke: .clear,
                    action: {
                        activeAction = .redeem
                    }
                )
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
                    .frame(width: 184, height: 184)
                    .blur(radius: 10)
                    .offset(x: 116, y: -74)

                Circle()
                    .fill(FinancePalette.iceBlue.opacity(0.24))
                    .frame(width: 140, height: 140)
                    .blur(radius: 14)
                    .offset(x: -124, y: 80)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: FinancePalette.royalBlue.opacity(0.22), radius: 24, y: 16)
    }

    private var overviewRow: some View {
        HStack(spacing: 12) {
            MinimalInvestmentMetricCard(
                title: "Invested",
                value: totalInvested.currencyText,
                accentColor: FinancePalette.royalBlue
            )

            MinimalInvestmentMetricCard(
                title: "Redeemed",
                value: totalRedeemed.currencyText,
                accentColor: FinancePalette.oceanBlue
            )

            MinimalInvestmentMetricCard(
                title: "Active",
                value: "\(financeStore.activeInvestmentCount) items",
                accentColor: FinancePalette.sapphireBlue
            )
        }
    }

    private var holdingsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Portfolio")
                    .font(.system(size: 21, weight: .semibold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)

                Spacer()

                Button(action: {
                    isShowingHistory = true
                }) {
                    Text("History")
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
                if holdings.isEmpty {
                    EmptyInvestmentPortfolioCard()
                } else {
                    ForEach(holdings) { holding in
                        InvestmentHoldingCard(holding: holding)
                    }
                }
            }
        }
    }
}

private enum InvestmentActionKind: String, Identifiable {
    case add
    case redeem

    var id: String { rawValue }

    var title: String {
        switch self {
        case .add:
            return "Add Investment"
        case .redeem:
            return "Redeem Asset"
        }
    }

    var subtitle: String {
        switch self {
        case .add:
            return "Track money that is yours but should not count as spending."
        case .redeem:
            return "Bring your invested money back into wallet or bank."
        }
    }

    var accentColor: Color {
        switch self {
        case .add:
            return FinancePalette.royalBlue
        case .redeem:
            return FinancePalette.sapphireBlue
        }
    }

    var icon: String {
        switch self {
        case .add:
            return "plus.circle.fill"
        case .redeem:
            return "arrow.up.right.circle.fill"
        }
    }

    var badgeTitle: String {
        switch self {
        case .add:
            return "Asset In"
        case .redeem:
            return "Asset Out"
        }
    }

    var amountPlaceholder: String {
        switch self {
        case .add:
            return "12,000"
        case .redeem:
            return "5,000"
        }
    }

    var primaryFieldTitle: String {
        switch self {
        case .add:
            return "Held By"
        case .redeem:
            return "Redeem To"
        }
    }

    var primaryFieldPlaceholder: String {
        switch self {
        case .add:
            return "Father / Broker / Bank"
        case .redeem:
            return "Wallet / Bank"
        }
    }

    var notePlaceholder: String {
        switch self {
        case .add:
            return "Optional note about this asset"
        case .redeem:
            return "Optional reason for redeeming"
        }
    }

    var tagTitle: String {
        switch self {
        case .add:
            return "Investment Type"
        case .redeem:
            return "Redeem From"
        }
    }

    var tags: [String] {
        switch self {
        case .add:
            return ["Family Hold", "SIP", "Gold", "FD"]
        case .redeem:
            return ["Family Hold", "SIP", "Gold", "FD"]
        }
    }

    var actionTitle: String {
        switch self {
        case .add:
            return "Save Investment"
        case .redeem:
            return "Confirm Redeem"
        }
    }
}

private struct InvestmentActionSheet: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var financeStore: FinanceStore

    let action: InvestmentActionKind
    let totalCurrentValue: Double
    let familyHeldValue: Double

    @State private var amount: String
    @State private var primaryField: String
    @State private var note: String
    @State private var selectedTag: String
    @State private var selectedDate: Date
    @State private var errorMessage: String?

    init(action: InvestmentActionKind, totalCurrentValue: Double, familyHeldValue: Double) {
        self.action = action
        self.totalCurrentValue = totalCurrentValue
        self.familyHeldValue = familyHeldValue
        _amount = State(initialValue: "")
        _primaryField = State(initialValue: "")
        _note = State(initialValue: "")
        _selectedTag = State(initialValue: action.tags.first ?? "")
        _selectedDate = State(initialValue: .now)
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
                            Text("Tracked Value")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.76))

                            Text(totalCurrentValue.currencyText)
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
                        HomeSheetMiniStat(title: "Family Held", value: familyHeldValue.currencyText)
                        HomeSheetMiniStat(title: "Rule", value: "Not Expense")
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
                        InvestmentSheetStatusBanner(message: errorMessage)
                    }

                    HomeSheetField(
                        title: "Amount",
                        prefix: "₹",
                        placeholder: action.amountPlaceholder,
                        text: $amount
                    )

                    HomeSheetField(
                        title: action.primaryFieldTitle,
                        prefix: nil,
                        placeholder: action.primaryFieldPlaceholder,
                        text: $primaryField
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
                            ForEach(action.tags, id: \.self) { tag in
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
                    symbol: action == .add ? "checkmark" : "arrow.up.right",
                    fill: action.accentColor,
                    foreground: .white,
                    stroke: .clear,
                    action: {
                        let result: String?

                        switch action {
                        case .add:
                            result = financeStore.submitInvestment(
                                amountText: amount,
                                holder: primaryField,
                                note: note,
                                selectionTag: selectedTag,
                                entryDate: selectedDate
                            )
                        case .redeem:
                            result = financeStore.redeemInvestment(
                                amountText: amount,
                                destination: primaryField,
                                note: note,
                                selectionTag: selectedTag,
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
    }
}

private struct InvestmentSheetStatusBanner: View {
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

private struct InvestmentHistoryScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    let sections: [InvestmentActivitySection]
    let totalInvested: Double
    let totalCurrentValue: Double

    @State private var selectedFilter: InvestmentHistoryFilter = .all

    private var filteredSections: [InvestmentActivitySection] {
        sections.compactMap { section in
            let activities = section.activities.filter { activity in
                selectedFilter.matches(activity: activity, sectionTitle: section.title)
            }

            guard !activities.isEmpty else { return nil }
            return InvestmentActivitySection(title: section.title, activities: activities)
        }
    }

    private var visibleActivities: [InvestmentActivity] {
        filteredSections.flatMap(\.activities)
    }

    private var totalAdded: Double {
        visibleActivities
            .filter { $0.kind == .invested }
            .reduce(0) { $0 + $1.amount }
    }

    private var totalRedeemed: Double {
        visibleActivities
            .filter { $0.kind == .redeemed }
            .reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    summaryCard
                    filtersRow
                    historyList
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
                Text("Investment History")
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)

                Text("Every contribution, redemption, and portfolio update")
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
                    Text("Visible Asset Value")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.76))

                    Text(totalCurrentValue.currencyText)
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
                HomeSheetMiniStat(title: "Added", value: max(totalAdded, totalInvested).currencyText)
                HomeSheetMiniStat(title: "Redeemed", value: totalRedeemed.currencyText)
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
                ForEach(InvestmentHistoryFilter.allCases) { filter in
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

    private var historyList: some View {
        VStack(alignment: .leading, spacing: 16) {
            if filteredSections.isEmpty {
                EmptyInvestmentHistoryCard()
            } else {
                ForEach(filteredSections) { section in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(section.title)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(FinancePalette.textSecondary)

                        ForEach(section.activities) { activity in
                            InvestmentActivityRow(activity: activity)
                        }
                    }
                }
            }
        }
    }
}

private struct MinimalInvestmentMetricCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let value: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(FinancePalette.textSecondary)

            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(FinancePalette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(FinancePalette.elevatedBackground(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    colorScheme == .dark ? FinancePalette.border(for: colorScheme) : accentColor.opacity(0.10),
                    lineWidth: 1
                )
        )
        .shadow(color: FinancePalette.shadow(for: colorScheme).opacity(0.28), radius: 10, y: 8)
    }
}

private enum InvestmentHistoryFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case invested = "Invested"
    case redeemed = "Redeemed"
    case family = "Family"

    var id: String { rawValue }

    func matches(activity: InvestmentActivity, sectionTitle: String) -> Bool {
        switch self {
        case .all:
            return true
        case .invested:
            return activity.kind == .invested
        case .redeemed:
            return activity.kind == .redeemed
        case .family:
            return activity.badge == "Family" || activity.title.localizedCaseInsensitiveContains("family")
        }
    }
}

private struct InvestmentHoldingCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let holding: InvestmentHolding

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                HStack(spacing: 12) {
                    SettingsIconBadge(icon: holding.kind.icon, color: holding.kind.color)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(holding.title)
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(FinancePalette.textPrimary)

                        Text(holding.holderName)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(FinancePalette.textSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 10)

                Text(holding.kind.badgeTitle)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(holding.kind.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(holding.kind.color.opacity(0.10))
                    .clipShape(Capsule())
            }

            HStack {
                Text(holding.currentValue.currencyText)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)

                Spacer()

                Text(holding.growthAmount.signedCurrencyText)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(holding.growthAmount >= 0 ? holding.kind.color : FinancePalette.sapphireBlue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        (holding.growthAmount >= 0 ? holding.kind.color : FinancePalette.sapphireBlue)
                            .opacity(0.10)
                    )
                    .clipShape(Capsule())
            }

            HStack {
                Text("Invested \(holding.investedAmount.currencyText)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(FinancePalette.textSecondary)

                Spacer()

                Text(holding.subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(FinancePalette.textSecondary)
                    .lineLimit(1)
            }
        }
        .padding(16)
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

private struct EmptyInvestmentPortfolioCard: View {
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SettingsIconBadge(icon: "chart.line.uptrend.xyaxis.circle.fill", color: FinancePalette.royalBlue)

            Text("No active investments yet")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(FinancePalette.textPrimary)

            Text("Use Add to track family-held money, SIP, gold, or FD without counting it as an expense.")
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

private struct EmptyInvestmentHistoryCard: View {
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("No history yet")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(FinancePalette.textPrimary)

            Text("Investment adds and redeems will appear here once you start using this page.")
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

private struct PortfolioMetricTile: View {
    let title: String
    let value: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(FinancePalette.textSecondary)

            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(FinancePalette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.76)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(accentColor.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct InvestmentActivityRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let activity: InvestmentActivity

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(activity.kind.color.opacity(0.10))
                    .frame(width: 50, height: 50)

                Image(systemName: activity.kind.icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(activity.kind.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)

                Text(activity.subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(FinancePalette.textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(activity.amountText)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(activity.kind.color)

                Text(activity.badge)
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
