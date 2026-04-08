import SwiftUI

struct HomeDashboardScreen: View {
    private let sections = TransactionDaySection.sampleData
    private let allSections = TransactionDaySection.fullHistorySampleData
    @State private var activeQuickAction: HomeQuickAction?
    @State private var isShowingAllTransactions = false
    @State private var isShowingNotifications = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                DashboardHeader(
                    title: "Nakhul Krishna",
                    subtitle: "Welcome back",
                    notificationAction: {
                        isShowingNotifications = true
                    }
                )
                heroCard
                quickStats
                operationsSection
            }
            .frame(maxWidth: 430)
            .padding(.horizontal, 22)
            .padding(.top, 18)
            .padding(.bottom, 120)
        }
        .sheet(item: $activeQuickAction) { action in
            HomeActionSheet(action: action)
                .presentationDetents([.height(560), .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isShowingAllTransactions) {
            ViewAllTransactionsScreen(sections: allSections)
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
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Available on card")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.86))

                    Spacer()

                    Text("Premium")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(FinancePalette.navyBlue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.92))
                        .clipShape(Capsule())
                }

                Text("₹1,35,280.31")
                    .font(.system(size: 37, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.8)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Transfer Limit")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.92))

                        Spacer()

                        Text("₹12,000")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                    }

                    ProgressView(value: 0.42)
                        .tint(.white)
                        .scaleEffect(x: 1, y: 1.35, anchor: .center)
                        .background(Color.white.opacity(0.18))
                        .clipShape(Capsule())

                    HStack {
                        Text("Spent ₹1,244.65")
                        Spacer()
                        Text("42% used")
                    }
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.76))
                }
            }
            .padding(22)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [FinancePalette.royalBlue, FinancePalette.oceanBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.22), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottom
                            )
                        )

                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 170, height: 170)
                        .offset(x: 120, y: -65)

                    Circle()
                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                        .frame(width: 240, height: 240)
                        .offset(x: 125, y: 95)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: FinancePalette.cardShadow, radius: 24, y: 18)

            HStack(spacing: 12) {
                PrimaryActionButton(
                    title: "Pay",
                    symbol: "arrow.up.right",
                    fill: FinancePalette.royalBlue,
                    foreground: .white,
                    stroke: .clear,
                    action: {
                        activeQuickAction = .pay
                    }
                )

                PrimaryActionButton(
                    title: "Deposit",
                    symbol: "plus",
                    fill: .white,
                    foreground: FinancePalette.royalBlue,
                    stroke: FinancePalette.icyBlue,
                    action: {
                        activeQuickAction = .deposit
                    }
                )
            }
        }
    }

    private var quickStats: some View {
        HStack(spacing: 14) {
            PremiumWidgetCard(
                title: "Today",
                value: "₹3,460",
                subtitle: "6 transactions",
                icon: "waveform.path.ecg",
                isHighlighted: true
            )

            PremiumWidgetCard(
                title: "This Month",
                value: "₹42,180",
                subtitle: "Up by 8%",
                icon: "chart.bar.fill",
                isHighlighted: false
            )
        }
    }

    private var operationsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Operations")
                    .font(.system(size: 21, weight: .semibold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)

                Spacer()

                Button(action: {
                    isShowingAllTransactions = true
                }) {
                    Text("View All")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(FinancePalette.royalBlue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(FinancePalette.paleBlue)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            ForEach(sections) { section in
                VStack(alignment: .leading, spacing: 12) {
                    Text(section.title)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(FinancePalette.textSecondary)

                    ForEach(section.transactions) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                }
            }
        }
    }
}

private enum HomeQuickAction: String, Identifiable {
    case pay
    case deposit

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pay:
            return "Send Payment"
        case .deposit:
            return "Add Deposit"
        }
    }

    var subtitle: String {
        switch self {
        case .pay:
            return "Transfer money quickly from your liquid balance."
        case .deposit:
            return "Log new money added into your wallet balance."
        }
    }

    var icon: String {
        switch self {
        case .pay:
            return "arrow.up.right.circle.fill"
        case .deposit:
            return "plus.circle.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .pay:
            return FinancePalette.royalBlue
        case .deposit:
            return FinancePalette.oceanBlue
        }
    }

    var balanceTitle: String {
        switch self {
        case .pay:
            return "Available to spend"
        case .deposit:
            return "Current wallet"
        }
    }

    var balanceValue: String {
        switch self {
        case .pay:
            return "₹24,850.00"
        case .deposit:
            return "₹24,850.00"
        }
    }

    var amountPlaceholder: String {
        switch self {
        case .pay:
            return "1,250"
        case .deposit:
            return "5,000"
        }
    }

    var targetTitle: String {
        switch self {
        case .pay:
            return "Pay to"
        case .deposit:
            return "Source"
        }
    }

    var targetPlaceholder: String {
        switch self {
        case .pay:
            return "Enter name or UPI"
        case .deposit:
            return "Cash / Bank transfer"
        }
    }

    var notePlaceholder: String {
        switch self {
        case .pay:
            return "Add a note"
        case .deposit:
            return "Where did this money come from?"
        }
    }

    var categoryTitle: String {
        switch self {
        case .pay:
            return "Purpose"
        case .deposit:
            return "Deposit Type"
        }
    }

    var tags: [String] {
        switch self {
        case .pay:
            return ["Food", "Travel", "Bills", "Shopping"]
        case .deposit:
            return ["Cash", "Salary", "Refund", "Transfer"]
        }
    }

    var actionTitle: String {
        switch self {
        case .pay:
            return "Continue Payment"
        case .deposit:
            return "Confirm Deposit"
        }
    }

    var defaultTarget: String {
        switch self {
        case .pay:
            return "Akhil N."
        case .deposit:
            return "Bank Transfer"
        }
    }

    var defaultNote: String {
        switch self {
        case .pay:
            return "Dinner split"
        case .deposit:
            return "Monthly cash top-up"
        }
    }
}

private struct HomeActionSheet: View {
    @Environment(\.dismiss) private var dismiss

    let action: HomeQuickAction
    @State private var amount: String
    @State private var target: String
    @State private var note: String
    @State private var selectedTag: String

    init(action: HomeQuickAction) {
        self.action = action
        _amount = State(initialValue: action.amountPlaceholder)
        _target = State(initialValue: action.defaultTarget)
        _note = State(initialValue: action.defaultNote)
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
                            Text(action.balanceTitle)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.76))

                            Text(action.balanceValue)
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .contentTransition(.numericText())
                        }

                        Spacer()

                        Text(action == .pay ? "Secure Pay" : "Wallet Entry")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(FinancePalette.navyBlue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.92))
                            .clipShape(Capsule())
                    }

                    HStack(spacing: 12) {
                        HomeSheetMiniStat(title: "Today", value: action == .pay ? "₹3,460" : "₹8,200")
                        HomeSheetMiniStat(title: "Limit", value: action == .pay ? "₹12,000" : "No limit")
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
                        title: action.targetTitle,
                        prefix: nil,
                        text: $target
                    )

                    VStack(alignment: .leading, spacing: 10) {
                        Text(action.categoryTitle)
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
                    symbol: action == .pay ? "arrow.up.right" : "checkmark",
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

private struct ViewAllTransactionsScreen: View {
    @Environment(\.dismiss) private var dismiss

    let sections: [TransactionDaySection]
    @State private var selectedFilter: TransactionHistoryFilter = .all

    private var filteredSections: [TransactionDaySection] {
        sections.compactMap { section in
            let transactions = section.transactions.filter { transaction in
                selectedFilter.matches(sectionTitle: section.title, transaction: transaction)
            }

            guard !transactions.isEmpty else { return nil }
            return TransactionDaySection(title: section.title, transactions: transactions)
        }
    }

    private var transactionCount: Int {
        filteredSections.reduce(0) { partialResult, section in
            partialResult + section.transactions.count
        }
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    summaryCard
                    filtersRow
                    transactionList
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
                Text("All Transactions")
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)

                Text("Complete activity from your home dashboard")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(FinancePalette.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            HeaderIconButton(symbol: "line.3.horizontal.decrease.circle.fill")
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Visible Transactions")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.76))

                    Text("\(transactionCount)")
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
                HomeSheetMiniStat(title: "Spent", value: "₹6,984")
                HomeSheetMiniStat(title: "Incoming", value: "₹8,350")
            }
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [FinancePalette.royalBlue, FinancePalette.oceanBlue],
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
                ForEach(TransactionHistoryFilter.allCases) { filter in
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

    private var transactionList: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(filteredSections) { section in
                VStack(alignment: .leading, spacing: 12) {
                    Text(section.title)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(FinancePalette.textSecondary)

                    ForEach(section.transactions) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                }
            }
        }
    }
}

private enum TransactionHistoryFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case today = "Today"
    case yesterday = "Yesterday"
    case recurring = "Recurring"

    var id: String { rawValue }

    func matches(sectionTitle: String, transaction: Transaction) -> Bool {
        switch self {
        case .all:
            return true
        case .today:
            return sectionTitle == "Today"
        case .yesterday:
            return sectionTitle == "Yesterday"
        case .recurring:
            return transaction.status == "Subscription" || transaction.status == "Auto-paid" || transaction.status == "Streaming"
        }
    }
}

private struct PremiumWidgetCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let isHighlighted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack {
                Circle()
                    .fill(isHighlighted ? Color.white.opacity(0.24) : FinancePalette.paleBlue)
                    .frame(width: 38, height: 38)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(isHighlighted ? .white : FinancePalette.royalBlue)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(isHighlighted ? .white.opacity(0.82) : FinancePalette.textSecondary)

                Text(value)
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .foregroundStyle(isHighlighted ? .white : FinancePalette.textPrimary)

                Text(subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(isHighlighted ? .white.opacity(0.72) : FinancePalette.royalBlue)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 142, alignment: .leading)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(isHighlighted ? Color.white.opacity(0.16) : FinancePalette.icyBlue.opacity(0.9), lineWidth: 1)
        )
        .shadow(color: isHighlighted ? FinancePalette.royalBlue.opacity(0.22) : FinancePalette.cardShadow, radius: 18, y: 12)
    }

    @ViewBuilder
    private var background: some View {
        if isHighlighted {
            LinearGradient(
                colors: [FinancePalette.navyBlue, FinancePalette.royalBlue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            LinearGradient(
                colors: [.white, FinancePalette.mistBlue],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
