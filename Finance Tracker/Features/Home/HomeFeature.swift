import SwiftUI

struct HomeDashboardScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var financeStore: FinanceStore
    @State private var activeQuickAction: HomeQuickAction?
    @State private var isShowingAllTransactions = false
    @State private var isShowingNotifications = false
    @State private var isShowingOpeningBalanceSheet = false
    @State private var isShowingTransferLimitSheet = false
    @State private var isShowingCardSettings = false
    @State private var pendingDeleteOperation: PendingHomeDeletion?
    @State private var animatedAvailableBalance: Double = 0
    @State private var hasAnimatedBalanceIn = false
    @State private var isBalancePulsing = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                DashboardHeader(
                    avatarText: authStore.currentUser?.initials ?? "FT",
                    title: authStore.currentUser?.firstName ?? authStore.currentUser?.fullName ?? "Finance Tracker",
                    subtitle: greetingText,
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
                .environmentObject(financeStore)
                .presentationDetents([.height(560), .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isShowingOpeningBalanceSheet) {
            OpeningBalanceSheet()
                .environmentObject(financeStore)
                .presentationDetents([.height(430)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isShowingTransferLimitSheet) {
            TransferLimitSheet()
                .environmentObject(financeStore)
                .presentationDetents([.height(430)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isShowingCardSettings) {
            CardSettingsSheet(
                openOpeningBalance: {
                    isShowingCardSettings = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                        isShowingOpeningBalanceSheet = true
                    }
                },
                openTransferLimit: {
                    isShowingCardSettings = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                        isShowingTransferLimitSheet = true
                    }
                }
            )
            .environmentObject(financeStore)
            .presentationDetents([.height(455)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isShowingAllTransactions) {
            ViewAllTransactionsScreen(sections: financeStore.allSections)
                .environmentObject(financeStore)
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $isShowingNotifications) {
            InsightsNotificationsScreen()
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
        .alert(
            "Delete operation?",
            isPresented: Binding(
                get: { pendingDeleteOperation != nil },
                set: { if !$0 { pendingDeleteOperation = nil } }
            ),
            actions: {
                Button("Cancel", role: .cancel) {
                    pendingDeleteOperation = nil
                }

                Button("Delete", role: .destructive) {
                    if let operationID = pendingDeleteOperation?.id {
                        financeStore.deleteOperation(id: operationID)
                    }
                    pendingDeleteOperation = nil
                }
            },
            message: {
                Text("This will remove \(pendingDeleteOperation?.title ?? "this operation") from your history and update the balance.")
            }
        )
        .onAppear {
            guard !hasAnimatedBalanceIn else { return }
            hasAnimatedBalanceIn = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                withAnimation(.spring(response: 0.88, dampingFraction: 0.90)) {
                    animatedAvailableBalance = financeStore.availableBalance
                }
            }
        }
        .onChange(of: financeStore.availableBalance) { _, newValue in
            withAnimation(.spring(response: 0.72, dampingFraction: 0.88)) {
                animatedAvailableBalance = newValue
                isBalancePulsing = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                withAnimation(.spring(response: 0.42, dampingFraction: 0.92)) {
                    isBalancePulsing = false
                }
            }
        }
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: .now)

        switch hour {
        case 5..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        case 17..<22:
            return "Good evening"
        default:
            return "Welcome back"
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

                    HStack(spacing: 8) {
                        Text(authStore.currentUser?.accountType.badgeTitle ?? FinanceAccountType.standard.badgeTitle)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(FinancePalette.navyBlue)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.92))
                            .clipShape(Capsule())

                        Button(action: {
                            isShowingCardSettings = true
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 30, height: 30)
                                .background(Color.white.opacity(0.16))
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.16), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }

                Text(animatedAvailableBalance.currencyText)
                    .font(.system(size: 37, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.8)
                    .contentTransition(.numericText())
                    .scaleEffect(isBalancePulsing ? 1.018 : 1, anchor: .leading)
                    .animation(.spring(response: 0.42, dampingFraction: 0.84), value: isBalancePulsing)

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Transfer Limit")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.72))

                            Text(financeStore.transferLimitDisplayText)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .contentTransition(.numericText())
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Spent Today")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.72))

                            Text(financeStore.todaySpend.currencyText)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .contentTransition(.numericText())
                        }
                    }

                    Text("\(financeStore.todayTransactionCount) entries today")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.76))
                        .contentTransition(.numericText())
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
                value: financeStore.todaySpend.currencyText,
                subtitle: "\(financeStore.todayTransactionCount) transactions",
                icon: "waveform.path.ecg",
                isHighlighted: true
            )

            PremiumWidgetCard(
                title: "This Month",
                value: financeStore.monthlySpend.currencyText,
                subtitle: "\(financeStore.monthlyTransactionCount) entries",
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
                        .background(FinancePalette.softBlueBackground(for: colorScheme))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            if financeStore.homeSections.isEmpty {
                EmptyOperationsCard()
            } else {
                ForEach(financeStore.homeSections) { section in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(section.title)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(FinancePalette.textSecondary)

                        ForEach(section.transactions) { transaction in
                            TransactionRow(
                                transaction: transaction,
                                onDelete: deleteAction(for: transaction)
                            )
                        }
                    }
                }
            }
        }
    }

    private func deleteAction(for transaction: Transaction) -> (() -> Void)? {
        guard let linkedRecordID = transaction.linkedRecordID else { return nil }

        return {
            pendingDeleteOperation = PendingHomeDeletion(id: linkedRecordID, title: transaction.title)
        }
    }
}

private struct PendingHomeDeletion: Identifiable {
    let id: UUID
    let title: String
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

}

private struct HomeActionSheet: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var financeStore: FinanceStore
    @EnvironmentObject private var premiumStore: PremiumStore

    let action: HomeQuickAction
    @State private var amount: String
    @State private var target: String
    @State private var note: String
    @State private var selectedTag: String
    @State private var selectedDate: Date
    @State private var errorMessage: String?

    init(action: HomeQuickAction) {
        self.action = action
        _amount = State(initialValue: "")
        _target = State(initialValue: "")
        _note = State(initialValue: "")
        _selectedTag = State(initialValue: action.tags.first ?? "")
        _selectedDate = State(initialValue: .now)
    }

    private var availableTags: [String] {
        let customTags: [String]

        switch action {
        case .pay:
            customTags = premiumStore.hasAccess(to: .customCategories)
                ? authStore.profilePreferences.paymentCategories
                : []
        case .deposit:
            customTags = premiumStore.hasAccess(to: .customCategories)
                ? authStore.profilePreferences.depositCategories
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
                            Text(action.balanceTitle)
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.76))

                            Text(financeStore.availableBalanceText)
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
                        HomeSheetMiniStat(
                            title: "Today",
                            value: action == .pay ? financeStore.todaySpend.currencyText : financeStore.todayDeposits.currencyText
                        )
                        HomeSheetMiniStat(
                            title: action == .pay ? "Limit" : "Opening",
                            value: action == .pay ? financeStore.transferLimitDisplayText : financeStore.openingBalanceDisplayText
                        )
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
                        HomeSheetStatusBanner(message: errorMessage)
                    }

                    HomeSheetField(
                        title: "Amount",
                        prefix: "₹",
                        placeholder: action.amountPlaceholder,
                        text: $amount
                    )

                    HomeSheetField(
                        title: action.targetTitle,
                        prefix: nil,
                        placeholder: action.targetPlaceholder,
                        text: $target
                    )

                    HomeSheetDateField(
                        title: "Date & Time",
                        date: $selectedDate
                    )

                    VStack(alignment: .leading, spacing: 10) {
                        Text(action.categoryTitle)
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
                    symbol: action == .pay ? "arrow.up.right" : "checkmark",
                    fill: action.accentColor,
                    foreground: .white,
                    stroke: .clear,
                    action: {
                        let result: String?

                        switch action {
                        case .pay:
                            result = financeStore.submitPayment(
                                amountText: amount,
                                target: target,
                                note: note,
                                category: selectedTag,
                                entryDate: selectedDate
                            )
                        case .deposit:
                            result = financeStore.submitDeposit(
                                amountText: amount,
                                source: target,
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
            if !availableTags.contains(selectedTag), let firstTag = availableTags.first {
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

private struct OpeningBalanceSheet: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var financeStore: FinanceStore

    @State private var amount = ""
    @State private var errorMessage: String?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(FinancePalette.royalBlue.opacity(0.12))
                            .frame(width: 58, height: 58)

                        Image(systemName: "wallet.pass.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(FinancePalette.royalBlue)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Opening Balance")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(FinancePalette.textPrimary)

                        Text("Set the starting amount currently available on this card.")
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
                            Text("Current Available")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.76))

                            Text(financeStore.availableBalanceText)
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .contentTransition(.numericText())
                        }

                        Spacer()

                        Text(financeStore.hasOpeningBalance ? "Saved" : "Required")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(FinancePalette.navyBlue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.92))
                            .clipShape(Capsule())
                    }

                    HStack(spacing: 12) {
                        HomeSheetMiniStat(title: "Opening", value: financeStore.openingBalanceDisplayText)
                        HomeSheetMiniStat(title: "Entries", value: "\(financeStore.allSections.flatMap(\.transactions).count)")
                    }
                }
                .padding(22)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [FinancePalette.navyBlue, FinancePalette.royalBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: FinancePalette.royalBlue.opacity(0.20), radius: 20, y: 14)

                VStack(alignment: .leading, spacing: 16) {
                    if let errorMessage {
                        HomeSheetStatusBanner(message: errorMessage)
                    }

                    HomeSheetField(
                        title: "Opening Amount",
                        prefix: "₹",
                        placeholder: "25,000",
                        text: $amount
                    )

                    Text("This becomes the starting balance for your Home card.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(FinancePalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                PrimaryActionButton(
                    title: financeStore.hasOpeningBalance ? "Update Opening Balance" : "Save Opening Balance",
                    symbol: "checkmark",
                    fill: FinancePalette.royalBlue,
                    foreground: .white,
                    stroke: .clear,
                    action: {
                        if let result = financeStore.setOpeningBalance(amountText: amount) {
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
            guard amount.isEmpty, financeStore.openingBalance > 0 else { return }
            amount = financeStore.openingBalance.formInputText
        }
    }
}

private struct CardSettingsSheet: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var financeStore: FinanceStore

    let openOpeningBalance: () -> Void
    let openTransferLimit: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(FinancePalette.royalBlue.opacity(0.12))
                            .frame(width: 58, height: 58)

                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(FinancePalette.royalBlue)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Card Settings")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(FinancePalette.textPrimary)

                        Text("Manage your card values without changing the clean home card layout.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(FinancePalette.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
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
                            Text("Card Overview")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.76))

                            Text(financeStore.availableBalanceText)
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .minimumScaleFactor(0.85)
                                .contentTransition(.numericText())
                        }

                        Spacer()

                        Text(financeStore.hasTransferLimit ? "Protected" : "Flexible")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(FinancePalette.navyBlue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.92))
                            .clipShape(Capsule())
                    }

                    HStack(spacing: 12) {
                        HomeSheetMiniStat(title: "Opening", value: financeStore.openingBalanceDisplayText)
                        HomeSheetMiniStat(title: "Limit", value: financeStore.transferLimitDisplayText)
                    }
                }
                .padding(22)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [FinancePalette.navyBlue, FinancePalette.royalBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: FinancePalette.royalBlue.opacity(0.18), radius: 20, y: 14)

                VStack(spacing: 14) {
                    CardSettingsActionCard(
                        title: financeStore.hasOpeningBalance ? "Edit Opening Balance" : "Set Opening Balance",
                        subtitle: "Choose the starting amount that should appear on your home card.",
                        value: financeStore.openingBalanceDisplayText,
                        symbol: "banknote.fill",
                        tint: FinancePalette.royalBlue,
                        action: openOpeningBalance
                    )

                    CardSettingsActionCard(
                        title: financeStore.hasTransferLimit ? "Edit Transfer Limit" : "Set Transfer Limit",
                        subtitle: "Control the maximum amount allowed in a single payment.",
                        value: financeStore.transferLimitDisplayText,
                        symbol: "slider.horizontal.3",
                        tint: FinancePalette.oceanBlue,
                        action: openTransferLimit
                    )
                }
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

private struct TransferLimitSheet: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var financeStore: FinanceStore

    @State private var amount = ""
    @State private var errorMessage: String?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(FinancePalette.oceanBlue.opacity(0.12))
                            .frame(width: 58, height: 58)

                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(FinancePalette.oceanBlue)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Transfer Limit")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(FinancePalette.textPrimary)

                        Text("Set the maximum single payment amount allowed from this card.")
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
                            Text("Current Limit")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.76))

                            Text(financeStore.transferLimitDisplayText)
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .contentTransition(.numericText())
                        }

                        Spacer()

                        Text(financeStore.hasTransferLimit ? "Active" : "Optional")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(FinancePalette.navyBlue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.92))
                            .clipShape(Capsule())
                    }

                    HStack(spacing: 12) {
                        HomeSheetMiniStat(title: "Opening", value: financeStore.openingBalanceDisplayText)
                        HomeSheetMiniStat(title: "Spent Today", value: financeStore.todaySpend.currencyText)
                    }
                }
                .padding(22)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [FinancePalette.navyBlue, FinancePalette.oceanBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: FinancePalette.oceanBlue.opacity(0.20), radius: 20, y: 14)

                VStack(alignment: .leading, spacing: 16) {
                    if let errorMessage {
                        HomeSheetStatusBanner(message: errorMessage)
                    }

                    HomeSheetField(
                        title: "Limit Amount",
                        prefix: "₹",
                        placeholder: "12,000",
                        text: $amount
                    )

                    Text("Use `0` if you do not want to enforce a transfer limit right now.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(FinancePalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                PrimaryActionButton(
                    title: financeStore.hasTransferLimit ? "Update Transfer Limit" : "Save Transfer Limit",
                    symbol: "checkmark",
                    fill: FinancePalette.oceanBlue,
                    foreground: .white,
                    stroke: .clear,
                    action: {
                        if let result = financeStore.setTransferLimit(amountText: amount) {
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
            guard amount.isEmpty, financeStore.transferLimit > 0 else { return }
            amount = financeStore.transferLimit.formInputText
        }
    }
}

private struct CardSettingsActionCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let subtitle: String
    let value: String
    let symbol: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(tint.opacity(0.12))
                        .frame(width: 52, height: 52)

                    Image(systemName: symbol)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(tint)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(FinancePalette.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(FinancePalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(value)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(tint)
                        .contentTransition(.numericText())
                }

                Spacer(minLength: 10)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(FinancePalette.textSecondary.opacity(0.75))
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(FinancePalette.elevatedBackground(for: colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(FinancePalette.border(for: colorScheme), lineWidth: 1)
            )
            .shadow(color: FinancePalette.shadow(for: colorScheme).opacity(0.42), radius: 16, y: 10)
        }
        .buttonStyle(.plain)
    }
}

private struct ViewAllTransactionsScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var financeStore: FinanceStore

    let sections: [TransactionDaySection]
    @State private var selectedFilter: TransactionHistoryFilter = .all
    @State private var pendingDeleteOperation: PendingHomeDeletion?

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

    private var filteredTransactions: [Transaction] {
        filteredSections.flatMap(\.transactions)
    }

    private var spentTotal: Double {
        filteredTransactions
            .map(\.numericAmount)
            .filter { $0 < 0 }
            .reduce(0, +)
    }

    private var incomingTotal: Double {
        filteredTransactions
            .map(\.numericAmount)
            .filter { $0 > 0 }
            .reduce(0, +)
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
                HomeSheetMiniStat(title: "Spent", value: abs(spentTotal).currencyText)
                HomeSheetMiniStat(title: "Incoming", value: incomingTotal.currencyText)
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

    private var transactionList: some View {
        VStack(alignment: .leading, spacing: 16) {
            if filteredSections.isEmpty {
                EmptyOperationsCard(
                    title: "No operations found",
                    subtitle: "Try another filter or add a new payment or deposit."
                )
            } else {
                ForEach(filteredSections) { section in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(section.title)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(FinancePalette.textSecondary)

                        ForEach(section.transactions) { transaction in
                            TransactionRow(
                                transaction: transaction,
                                onDelete: deleteAction(for: transaction)
                            )
                        }
                    }
                }
            }
        }
        .alert(
            "Delete operation?",
            isPresented: Binding(
                get: { pendingDeleteOperation != nil },
                set: { if !$0 { pendingDeleteOperation = nil } }
            ),
            actions: {
                Button("Cancel", role: .cancel) {
                    pendingDeleteOperation = nil
                }

                Button("Delete", role: .destructive) {
                    if let operationID = pendingDeleteOperation?.id {
                        financeStore.deleteOperation(id: operationID)
                    }
                    pendingDeleteOperation = nil
                }
            },
            message: {
                Text("This will remove \(pendingDeleteOperation?.title ?? "this operation") from your history and update the balance.")
            }
        )
    }

    private func deleteAction(for transaction: Transaction) -> (() -> Void)? {
        guard let linkedRecordID = transaction.linkedRecordID else { return nil }

        return {
            pendingDeleteOperation = PendingHomeDeletion(id: linkedRecordID, title: transaction.title)
        }
    }
}

private struct EmptyOperationsCard: View {
    @Environment(\.colorScheme) private var colorScheme
    var title: String = "No operations yet"
    var subtitle: String = "Set an opening balance or use Pay and Deposit to start building your activity feed."

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(FinancePalette.textPrimary)

            Text(subtitle)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(FinancePalette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(FinancePalette.elevatedBackground(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(FinancePalette.border(for: colorScheme), lineWidth: 1)
        )
        .shadow(color: FinancePalette.shadow(for: colorScheme).opacity(0.24), radius: 14, y: 8)
    }
}

private extension Double {
    var formInputText: String {
        if rounded(.towardZero) == self {
            return String(Int(self))
        }

        return String(format: "%.2f", self)
    }
}

private struct HomeSheetStatusBanner: View {
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
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let isHighlighted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack {
                Circle()
                    .fill(isHighlighted ? Color.white.opacity(0.24) : FinancePalette.softBlueBackground(for: colorScheme))
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
                .stroke(isHighlighted ? Color.white.opacity(0.16) : FinancePalette.border(for: colorScheme), lineWidth: 1)
        )
        .shadow(color: isHighlighted ? FinancePalette.royalBlue.opacity(0.22) : FinancePalette.shadow(for: colorScheme), radius: 18, y: 12)
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
            FinancePalette.elevatedBackground(for: colorScheme)
        }
    }
}
