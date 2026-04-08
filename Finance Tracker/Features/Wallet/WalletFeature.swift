import SwiftUI

struct WalletScreen: View {
    private let entries = WalletEntry.sampleData
    private let historySections = WalletActivitySection.sampleData
    private let actionColumns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]
    @State private var activeRoute: WalletRoute?
    @State private var isShowingNotifications = false

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
                    .presentationDetents([.height(560), .large])
                    .presentationDragIndicator(.visible)
            case .withdraw:
                WalletActionSheet(action: .withdraw)
                    .presentationDetents([.height(560), .large])
                    .presentationDragIndicator(.visible)
            case .history:
                WalletActivityScreen(sections: historySections)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
            }
        }
        .sheet(isPresented: $isShowingNotifications) {
            InsightsNotificationsScreen()
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
    }

    private var walletCard: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Liquid Wallet")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.82))

                    Text("₹24,850.00")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                }

                Spacer(minLength: 12)

                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 12, weight: .bold))

                    Text("Available")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                }
                .foregroundStyle(FinancePalette.navyBlue)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.94))
                .clipShape(Capsule())
            }

            HStack(spacing: 12) {
                WalletMetricPill(title: "Cash In Hand", value: "₹18,500")
                WalletMetricPill(title: "Safe Reserve", value: "₹6,350")
            }

            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Card access")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.74))

                    Text("•••• 2485")
                        .font(.system(size: 19, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text("Last sync")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.74))

                    Text("Today 01:40 PM")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
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
                        amount: "+₹1,500",
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
                        amount: "-₹500",
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
                        .background(FinancePalette.paleBlue)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            VStack(spacing: 12) {
                ForEach(entries) { entry in
                    WalletEntryRow(entry: entry)
                }
            }
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

    var sourceDefault: String {
        switch self {
        case .addMoney:
            return "Bank Transfer"
        case .withdraw:
            return "Daily Expenses"
        }
    }

    var noteDefault: String {
        switch self {
        case .addMoney:
            return "Added for monthly cash use"
        case .withdraw:
            return "Cash taken for groceries"
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
    @Environment(\.dismiss) private var dismiss

    let action: WalletQuickAction
    @State private var amount: String
    @State private var source: String
    @State private var note: String
    @State private var selectedTag: String

    init(action: WalletQuickAction) {
        self.action = action
        _amount = State(initialValue: action.amountPlaceholder)
        _source = State(initialValue: action.sourceDefault)
        _note = State(initialValue: action.noteDefault)
        _selectedTag = State(initialValue: action.tags.first ?? "")
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
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(FinancePalette.icyBlue, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }

                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Wallet Balance")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.76))

                            Text("₹24,850.00")
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
                        HomeSheetMiniStat(title: "Cash In Hand", value: "₹18,500")
                        HomeSheetMiniStat(title: "Safe Reserve", value: "₹6,350")
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
                    HomeSheetField(
                        title: "Amount",
                        prefix: "₹",
                        text: $amount
                    )

                    HomeSheetField(
                        title: action.sourceTitle,
                        prefix: nil,
                        text: $source
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
                        dismiss()
                    }
                )
            }
            .padding(.horizontal, 22)
            .padding(.top, 20)
            .padding(.bottom, 28)
        }
        .background(
            LinearGradient(
                colors: [Color.white, FinancePalette.mistBlue],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

private struct WalletActivityScreen: View {
    @Environment(\.dismiss) private var dismiss

    let sections: [WalletActivitySection]
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
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(FinancePalette.icyBlue, lineWidth: 1)
                    )
                    .shadow(color: FinancePalette.cardShadow.opacity(0.45), radius: 12, y: 8)
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
                    Text("Visible Wallet Entries")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.76))

                    Text("\(allVisibleEntries.count)")
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
                                        Color.white
                                    }
                                }
                            )
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(
                                        selectedFilter == filter ? Color.clear : FinancePalette.icyBlue,
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

private struct WalletActivitySection: Identifiable {
    let id = UUID()
    let title: String
    let entries: [WalletEntry]

    static let sampleData: [WalletActivitySection] = [
        WalletActivitySection(
            title: "Today",
            entries: [
                WalletEntry(
                    title: "Cash Added",
                    subtitle: "Pocket deposit",
                    amount: "+₹1,500",
                    time: "12:30 PM",
                    kind: .deposit
                ),
                WalletEntry(
                    title: "ATM Withdraw",
                    subtitle: "Daily expenses",
                    amount: "-₹500",
                    time: "11:10 AM",
                    kind: .withdrawal
                )
            ]
        ),
        WalletActivitySection(
            title: "Yesterday",
            entries: [
                WalletEntry(
                    title: "Cash Added",
                    subtitle: "Office reimbursement",
                    amount: "+₹850",
                    time: "05:40 PM",
                    kind: .deposit
                ),
                WalletEntry(
                    title: "Wallet Spend",
                    subtitle: "Travel cash out",
                    amount: "-₹320",
                    time: "01:20 PM",
                    kind: .withdrawal
                )
            ]
        ),
        WalletActivitySection(
            title: "This Week",
            entries: [
                WalletEntry(
                    title: "Cash Added",
                    subtitle: "Family transfer",
                    amount: "+₹2,000",
                    time: "Monday",
                    kind: .deposit
                ),
                WalletEntry(
                    title: "Wallet Spend",
                    subtitle: "Bills payment",
                    amount: "-₹1,240",
                    time: "Sunday",
                    kind: .withdrawal
                )
            ]
        )
    ]
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
                .fill(
                    LinearGradient(
                        colors: [Color.white, FinancePalette.mistBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(FinancePalette.icyBlue.opacity(0.95), lineWidth: 1)
        )
        .shadow(color: FinancePalette.cardShadow.opacity(0.44), radius: 14, y: 10)
    }
}

private struct WalletEntryRow: View {
    let entry: WalletEntry

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
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(entry.amount)
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
                .fill(Color.white.opacity(0.98))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(FinancePalette.icyBlue.opacity(0.92), lineWidth: 1)
        )
        .shadow(color: FinancePalette.cardShadow.opacity(0.36), radius: 12, y: 8)
    }
}
