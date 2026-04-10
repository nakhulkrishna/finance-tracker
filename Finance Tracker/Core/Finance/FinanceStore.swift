import Combine
import Foundation
import FirebaseFirestore
import SwiftUI

enum HomeOperationKind: String, Codable {
    case payment
    case deposit

    var signedMultiplier: Double {
        switch self {
        case .payment:
            return -1
        case .deposit:
            return 1
        }
    }
}

struct HomeOperationRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let note: String
    let amount: Double
    let category: String
    let createdAt: Date
    let kind: HomeOperationKind

    init(
        id: UUID = UUID(),
        title: String,
        note: String,
        amount: Double,
        category: String,
        createdAt: Date = .now,
        kind: HomeOperationKind
    ) {
        self.id = id
        self.title = title
        self.note = note
        self.amount = amount
        self.category = category
        self.createdAt = createdAt
        self.kind = kind
    }

    var signedAmount: Double {
        amount * kind.signedMultiplier
    }

    var displaySubtitle: String {
        note.isEmpty ? category : note
    }

    var badgeText: String {
        let letters = title
            .split(separator: " ")
            .prefix(2)
            .compactMap(\.first)

        let badge = letters.map(String.init).joined()
        return badge.isEmpty ? "FT" : badge.uppercased()
    }

    var brandColor: Color {
        switch category.lowercased() {
        case "food":
            return FinancePalette.royalBlue
        case "travel":
            return FinancePalette.oceanBlue
        case "bills":
            return FinancePalette.sapphireBlue
        case "shopping":
            return FinancePalette.iceBlue
        case "salary":
            return FinancePalette.oceanBlue
        case "cash":
            return FinancePalette.royalBlue
        case "refund":
            return FinancePalette.iceBlue
        case "transfer":
            return FinancePalette.sapphireBlue
        default:
            return kind == .payment ? FinancePalette.royalBlue : FinancePalette.oceanBlue
        }
    }

    var transactionModel: Transaction {
        Transaction(
            title: title,
            subtitle: displaySubtitle,
            amount: signedAmount.signedCurrencyText,
            badgeText: badgeText,
            brandColor: brandColor,
            status: category,
            linkedRecordID: id
        )
    }
}

private struct HomeDashboardSnapshot: Codable {
    let openingBalance: Double
    let availableBalance: Double
    let transferLimit: Double
    let operations: [HomeOperationRecord]

    init(
        openingBalance: Double = 0,
        availableBalance: Double,
        transferLimit: Double = 0,
        operations: [HomeOperationRecord]
    ) {
        self.openingBalance = openingBalance
        self.availableBalance = availableBalance
        self.transferLimit = transferLimit
        self.operations = operations
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let availableBalance = try container.decodeIfPresent(Double.self, forKey: .availableBalance) ?? 0
        let transferLimit = try container.decodeIfPresent(Double.self, forKey: .transferLimit) ?? 0
        let operations = try container.decodeIfPresent([HomeOperationRecord].self, forKey: .operations) ?? []

        self.availableBalance = availableBalance
        self.transferLimit = transferLimit
        self.operations = operations
        self.openingBalance = try container.decodeIfPresent(Double.self, forKey: .openingBalance)
            ?? max(availableBalance - operations.reduce(0) { $0 + $1.signedAmount }, 0)
    }
}

private struct HomeSummarySnapshot: Codable {
    let openingBalance: Double
    let availableBalance: Double
    let transferLimit: Double

    init(
        openingBalance: Double = 0,
        availableBalance: Double = 0,
        transferLimit: Double = 0
    ) {
        self.openingBalance = openingBalance
        self.availableBalance = availableBalance
        self.transferLimit = transferLimit
    }
}

struct InitialInvestmentSetupEntry {
    let amountText: String
    let holder: String
    let selectionTag: String
}

enum InvestmentRecordKind: String, Codable {
    case added
    case redeemed

    var activityKind: InvestmentActivity.Kind {
        switch self {
        case .added:
            return .invested
        case .redeemed:
            return .redeemed
        }
    }
}

struct InvestmentRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let amount: Double
    let counterparty: String
    let note: String
    let assetKind: InvestmentHoldingKind
    let createdAt: Date
    let kind: InvestmentRecordKind
    let isSetupSeed: Bool

    init(
        id: UUID = UUID(),
        amount: Double,
        counterparty: String,
        note: String,
        assetKind: InvestmentHoldingKind,
        createdAt: Date = .now,
        kind: InvestmentRecordKind,
        isSetupSeed: Bool = false
    ) {
        self.id = id
        self.amount = amount
        self.counterparty = counterparty
        self.note = note
        self.assetKind = assetKind
        self.createdAt = createdAt
        self.kind = kind
        self.isSetupSeed = isSetupSeed
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        amount = try container.decode(Double.self, forKey: .amount)
        counterparty = try container.decode(String.self, forKey: .counterparty)
        note = try container.decode(String.self, forKey: .note)
        assetKind = try container.decode(InvestmentHoldingKind.self, forKey: .assetKind)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        kind = try container.decode(InvestmentRecordKind.self, forKey: .kind)
        isSetupSeed = try container.decodeIfPresent(Bool.self, forKey: .isSetupSeed) ?? false
    }

    var activityModel: InvestmentActivity {
        InvestmentActivity(
            title: activityTitle,
            subtitle: activitySubtitle,
            amount: amount,
            time: investmentTimeFormatter.string(from: createdAt),
            badge: assetKind.badgeTitle,
            kind: kind.activityKind
        )
    }

    private var activityTitle: String {
        switch kind {
        case .added:
            return "\(assetKind.portfolioTitle) added"
        case .redeemed:
            return "\(assetKind.portfolioTitle) redeemed"
        }
    }

    private var activitySubtitle: String {
        if !note.trimmed.isEmpty {
            return note
        }

        switch kind {
        case .added:
            return "Held by \(counterparty)"
        case .redeemed:
            return "Moved to \(counterparty)"
        }
    }
}

private struct InvestmentDashboardSnapshot: Codable {
    let records: [InvestmentRecord]

    init(records: [InvestmentRecord] = []) {
        self.records = records
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        records = try container.decodeIfPresent([InvestmentRecord].self, forKey: .records) ?? []
    }
}

enum WalletRecordKind: String, Codable {
    case addMoney
    case withdraw

    var signedMultiplier: Double {
        switch self {
        case .addMoney:
            return 1
        case .withdraw:
            return -1
        }
    }

    var entryKind: WalletEntry.Kind {
        switch self {
        case .addMoney:
            return .deposit
        case .withdraw:
            return .withdrawal
        }
    }
}

struct WalletRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let note: String
    let amount: Double
    let category: String
    let createdAt: Date
    let kind: WalletRecordKind
    let isSetupSeed: Bool

    init(
        id: UUID = UUID(),
        title: String,
        note: String,
        amount: Double,
        category: String,
        createdAt: Date = .now,
        kind: WalletRecordKind,
        isSetupSeed: Bool = false
    ) {
        self.id = id
        self.title = title
        self.note = note
        self.amount = amount
        self.category = category
        self.createdAt = createdAt
        self.kind = kind
        self.isSetupSeed = isSetupSeed
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        note = try container.decode(String.self, forKey: .note)
        amount = try container.decode(Double.self, forKey: .amount)
        category = try container.decode(String.self, forKey: .category)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        kind = try container.decode(WalletRecordKind.self, forKey: .kind)
        isSetupSeed = try container.decodeIfPresent(Bool.self, forKey: .isSetupSeed) ?? false
    }

    var signedAmount: Double {
        amount * kind.signedMultiplier
    }

    var displaySubtitle: String {
        note.isEmpty ? category : note
    }

    var entryModel: WalletEntry {
        WalletEntry(
            id: id,
            title: title,
            subtitle: displaySubtitle,
            amount: signedAmount.signedCurrencyText,
            time: walletTimeFormatter.string(from: createdAt),
            kind: kind.entryKind
        )
    }
}

private struct WalletDashboardSnapshot: Codable {
    let records: [WalletRecord]

    init(records: [WalletRecord] = []) {
        self.records = records
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        records = try container.decodeIfPresent([WalletRecord].self, forKey: .records) ?? []
    }
}

@MainActor
final class FinanceStore: ObservableObject {
    @Published private(set) var openingBalance: Double = 0
    @Published private(set) var availableBalance: Double = 0
    @Published private(set) var transferLimit: Double = 0
    @Published private(set) var operations: [HomeOperationRecord] = []
    @Published private(set) var investmentRecords: [InvestmentRecord] = []
    @Published private(set) var walletRecords: [WalletRecord] = []

    private let encoder = JSONEncoder()
    private let calendar = Calendar.current
    private let firestore: Firestore
    private var activeUserID: String?
    private var homeSummaryListener: ListenerRegistration?
    private var homeOperationsListener: ListenerRegistration?
    private var investmentRecordsListener: ListenerRegistration?
    private var walletRecordsListener: ListenerRegistration?
    private var syncBootstrapTask: Task<Void, Never>?

    init(firestore: Firestore = Firestore.firestore()) {
        self.firestore = firestore
    }

    deinit {
        homeSummaryListener?.remove()
        homeOperationsListener?.remove()
        investmentRecordsListener?.remove()
        walletRecordsListener?.remove()
        syncBootstrapTask?.cancel()
    }

    var availableBalanceText: String {
        availableBalance.currencyText
    }

    var openingBalanceText: String {
        openingBalance.currencyText
    }

    var openingBalanceDisplayText: String {
        openingBalance > 0 ? openingBalance.currencyText : "Not set"
    }

    var hasOpeningBalance: Bool {
        openingBalance > 0
    }

    var transferLimitText: String {
        transferLimit.currencyText
    }

    var transferLimitDisplayText: String {
        transferLimit > 0 ? transferLimit.currencyText : "Not set"
    }

    var hasTransferLimit: Bool {
        transferLimit > 0
    }

    var todaySpend: Double {
        operations
            .filter { $0.kind == .payment && calendar.isDateInToday($0.createdAt) }
            .reduce(0) { $0 + $1.amount }
    }

    var todayDeposits: Double {
        operations
            .filter { $0.kind == .deposit && calendar.isDateInToday($0.createdAt) }
            .reduce(0) { $0 + $1.amount }
    }

    var todayTransactionCount: Int {
        operations.filter { calendar.isDateInToday($0.createdAt) }.count
    }

    var monthlySpend: Double {
        operations
            .filter { $0.kind == .payment && calendar.isDate($0.createdAt, equalTo: .now, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }

    var monthlyTransactionCount: Int {
        operations.filter { calendar.isDate($0.createdAt, equalTo: .now, toGranularity: .month) }.count
    }

    var limitUsageRatio: Double {
        guard transferLimit > 0 else { return 0 }
        return min(todaySpend / transferLimit, 1)
    }

    var limitUsageText: String {
        "\(Int((limitUsageRatio * 100).rounded()))% used"
    }

    var homeSections: [TransactionDaySection] {
        groupedSections(from: Array(operations.prefix(6)))
    }

    var allSections: [TransactionDaySection] {
        groupedSections(from: operations)
    }

    var investmentHoldings: [InvestmentHolding] {
        InvestmentHoldingKind.allCases.compactMap { assetKind in
            let activeBalance = activeInvestmentBalance(for: assetKind)
            guard activeBalance > 0 else { return nil }

            let records = investmentRecords
                .filter { $0.assetKind == assetKind }
                .sorted { $0.createdAt > $1.createdAt }
            let latestAdd = records.first(where: { $0.kind == .added })
            let holdingSubtitle: String

            if let latestAdd, !latestAdd.note.trimmed.isEmpty {
                holdingSubtitle = latestAdd.note
            } else {
                holdingSubtitle = assetKind.defaultSubtitle
            }

            return InvestmentHolding(
                title: assetKind.portfolioTitle,
                subtitle: holdingSubtitle,
                holderName: latestAdd?.counterparty ?? assetKind.badgeTitle,
                investedAmount: activeBalance,
                currentValue: activeBalance,
                monthlyContribution: records
                    .filter { $0.kind == .added && calendar.isDate($0.createdAt, equalTo: .now, toGranularity: .month) }
                    .reduce(0) { $0 + $1.amount },
                note: latestAdd?.note ?? assetKind.defaultSubtitle,
                kind: assetKind
            )
        }
    }

    var investmentActivitySections: [InvestmentActivitySection] {
        groupedInvestmentSections(from: investmentRecords)
    }

    var totalInvestmentBalance: Double {
        investmentHoldings.reduce(0) { $0 + $1.currentValue }
    }

    var totalInvestedAmount: Double {
        investmentRecords
            .filter { $0.kind == .added }
            .reduce(0) { $0 + $1.amount }
    }

    var totalRedeemedAmount: Double {
        investmentRecords
            .filter { $0.kind == .redeemed }
            .reduce(0) { $0 + $1.amount }
    }

    var familyHeldInvestmentValue: Double {
        investmentHoldings
            .filter { $0.kind == .familyReserve }
            .reduce(0) { $0 + $1.currentValue }
    }

    var activeInvestmentCount: Int {
        investmentHoldings.count
    }

    var walletBalance: Double {
        walletRecords.reduce(0) { $0 + $1.signedAmount }
    }

    var walletBalanceText: String {
        walletBalance.currencyText
    }

    var walletEntries: [WalletEntry] {
        walletRecords.map(\.entryModel)
    }

    var recentWalletEntries: [WalletEntry] {
        Array(walletEntries.prefix(4))
    }

    var walletSections: [WalletActivitySection] {
        groupedWalletSections(from: walletRecords)
    }

    var walletMonthlyIn: Double {
        walletRecords
            .filter { $0.kind == .addMoney && calendar.isDate($0.createdAt, equalTo: .now, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }

    var walletMonthlyOut: Double {
        walletRecords
            .filter { $0.kind == .withdraw && calendar.isDate($0.createdAt, equalTo: .now, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }

    var walletEntryCount: Int {
        walletRecords.count
    }

    var walletLastUpdatedText: String {
        guard let latestRecord = walletRecords.first else {
            return "No activity yet"
        }

        if calendar.isDateInToday(latestRecord.createdAt) {
            return "Today \(walletTimeFormatter.string(from: latestRecord.createdAt))"
        }

        return walletCardTimestampFormatter.string(from: latestRecord.createdAt)
    }

    func insightSnapshot(for range: InsightRange) -> InsightSnapshot {
        let payments = operations.filter { record in
            record.kind == .payment && includes(record.createdAt, in: range)
        }

        let totalSpend = payments.reduce(0) { $0 + $1.amount }
        let categoryStats = InsightTrackedCategory.allCases.map { category in
            insightStat(for: category, from: payments)
        }
        let maxAmount = categoryStats.map(\.amount).max() ?? 0

        return InsightSnapshot(
            badgeTitle: insightBadgeTitle(for: range),
            summaryTitle: insightSummaryTitle(for: range),
            totalAmount: totalSpend.currencyText,
            supportingText: insightSupportingText(paymentCount: payments.count, range: range),
            chartBars: categoryStats.map { stat in
                InsightBar(
                    title: stat.category.barTitle,
                    amount: stat.amount.currencyText,
                    percentage: insightPercentageText(amount: stat.amount, total: totalSpend),
                    color: stat.category.color,
                    fillRatio: maxAmount > 0 ? CGFloat(stat.amount / maxAmount) : 0
                )
            },
            categories: categoryStats.map { stat in
                InsightCategory(
                    title: stat.category.title,
                    caption: stat.category.caption,
                    amount: stat.amount.currencyText,
                    percentage: insightPercentageText(amount: stat.amount, total: totalSpend),
                    footnote: paymentCountLabel(stat.count),
                    icon: stat.category.icon,
                    color: stat.category.color,
                    backgroundTint: stat.category.backgroundTint
                )
            }
        )
    }

    func setActiveUser(_ userID: String?) {
        guard activeUserID != userID else { return }
        detachCloudListeners()
        syncBootstrapTask?.cancel()
        activeUserID = userID

        guard let userID else {
            resetState()
            return
        }

        apply(Self.emptyHomeSummary)
        applyHomeOperations([])
        apply(Self.emptyInvestmentSnapshot)
        apply(Self.emptyWalletSnapshot)

        attachCloudListeners(for: userID)
        syncBootstrapTask = Task { @MainActor [weak self] in
            await self?.bootstrapCloudState(for: userID)
        }
    }

    func submitPayment(amountText: String, target: String, note: String, category: String, entryDate: Date) -> String? {
        submitAction(
            kind: .payment,
            amountText: amountText,
            title: target,
            note: note,
            category: category,
            entryDate: entryDate
        )
    }

    func submitDeposit(amountText: String, source: String, note: String, category: String, entryDate: Date) -> String? {
        submitAction(
            kind: .deposit,
            amountText: amountText,
            title: source,
            note: note,
            category: category,
            entryDate: entryDate
        )
    }

    func setOpeningBalance(amountText: String) -> String? {
        guard activeUserID != nil else {
            return "Your finance session is not ready yet. Please sign in again."
        }

        guard let amount = parsedAmount(from: amountText), amount >= 0 else {
            return "Enter a valid opening balance."
        }

        let previousOpeningBalance = openingBalance
        let balanceOffset = hasOpeningBalance
            ? availableBalance - previousOpeningBalance
            : operations.reduce(0) { $0 + $1.signedAmount }

        openingBalance = amount
        availableBalance = max(amount + balanceOffset, 0)

        if transferLimit == 0 || transferLimit == previousOpeningBalance {
            transferLimit = amount
        }

        persistCurrentState()
        return nil
    }

    func setTransferLimit(amountText: String) -> String? {
        guard activeUserID != nil else {
            return "Your finance session is not ready yet. Please sign in again."
        }

        guard let amount = parsedAmount(from: amountText), amount >= 0 else {
            return "Enter a valid transfer limit."
        }

        transferLimit = amount
        persistCurrentState()
        return nil
    }

    func seedInitialInvestment(
        amountText: String,
        holder: String,
        selectionTag: String
    ) -> String? {
        guard activeUserID != nil else {
            return "Your finance session is not ready yet. Please sign in again."
        }

        let normalizedAmountText = amountText.trimmed.isEmpty ? "0" : amountText
        let cleanHolder = holder.trimmed

        guard let amount = parsedAmount(from: normalizedAmountText), amount >= 0 else {
            return "Enter a valid opening investment amount."
        }

        guard amount > 0 else {
            return nil
        }

        guard !cleanHolder.isEmpty else {
            return "Enter who is holding this existing investment."
        }

        guard let assetKind = InvestmentHoldingKind.from(selectionTag: selectionTag) else {
            return "Select an investment type before continuing."
        }

        investmentRecords.removeAll { $0.isSetupSeed }

        let record = InvestmentRecord(
            amount: amount,
            counterparty: cleanHolder,
            note: "",
            assetKind: assetKind,
            createdAt: .now,
            kind: .added,
            isSetupSeed: true
        )

        investmentRecords.insert(record, at: 0)
        persistCurrentInvestmentState()
        return nil
    }

    func replaceInitialSetupInvestments(_ entries: [InitialInvestmentSetupEntry]) -> String? {
        guard activeUserID != nil else {
            return "Your finance session is not ready yet. Please sign in again."
        }

        var preservedRecords = investmentRecords.filter { !$0.isSetupSeed }
        let baseDate = Date()
        var stagedRecords: [InvestmentRecord] = []

        for (index, entry) in entries.enumerated() {
            let normalizedAmountText = entry.amountText.trimmed.isEmpty ? "0" : entry.amountText
            let cleanHolder = entry.holder.trimmed

            guard let amount = parsedAmount(from: normalizedAmountText), amount >= 0 else {
                return "Enter a valid opening investment amount."
            }

            guard amount > 0 else {
                continue
            }

            guard let assetKind = InvestmentHoldingKind.from(selectionTag: entry.selectionTag) else {
                return "Select a valid investment type before continuing."
            }

            if assetKind == .familyReserve && cleanHolder.isEmpty {
                return "Enter who is holding your family-held investment."
            }

            let counterparty = cleanHolder.isEmpty ? assetKind.badgeTitle : cleanHolder
            let createdAt = baseDate.addingTimeInterval(TimeInterval(index))

            stagedRecords.append(
                InvestmentRecord(
                    amount: amount,
                    counterparty: counterparty,
                    note: "",
                    assetKind: assetKind,
                    createdAt: createdAt,
                    kind: .added,
                    isSetupSeed: true
                )
            )
        }

        preservedRecords.insert(contentsOf: stagedRecords, at: 0)
        investmentRecords = preservedRecords.sorted { $0.createdAt > $1.createdAt }
        persistCurrentInvestmentState()
        return nil
    }

    func seedInitialWalletBalance(amountText: String) -> String? {
        guard activeUserID != nil else {
            return "Your finance session is not ready yet. Please sign in again."
        }

        let normalizedAmountText = amountText.trimmed.isEmpty ? "0" : amountText

        guard let amount = parsedAmount(from: normalizedAmountText), amount >= 0 else {
            return "Enter a valid opening wallet amount."
        }

        guard amount > 0 else {
            return nil
        }

        walletRecords.removeAll { $0.isSetupSeed }

        let record = WalletRecord(
            title: "Opening Wallet",
            note: "",
            amount: amount,
            category: "Opening",
            createdAt: .now,
            kind: .addMoney,
            isSetupSeed: true
        )

        walletRecords.insert(record, at: 0)
        persistCurrentWalletState()
        return nil
    }

    func submitInvestment(
        amountText: String,
        holder: String,
        note: String,
        selectionTag: String,
        entryDate: Date
    ) -> String? {
        submitInvestmentAction(
            kind: .added,
            amountText: amountText,
            counterparty: holder,
            note: note,
            selectionTag: selectionTag,
            entryDate: entryDate
        )
    }

    func redeemInvestment(
        amountText: String,
        destination: String,
        note: String,
        selectionTag: String,
        entryDate: Date
    ) -> String? {
        submitInvestmentAction(
            kind: .redeemed,
            amountText: amountText,
            counterparty: destination,
            note: note,
            selectionTag: selectionTag,
            entryDate: entryDate
        )
    }

    func submitWalletAddMoney(
        amountText: String,
        source: String,
        note: String,
        category: String,
        entryDate: Date
    ) -> String? {
        submitWalletAction(
            kind: .addMoney,
            amountText: amountText,
            title: source,
            note: note,
            category: category,
            entryDate: entryDate
        )
    }

    func submitWalletWithdraw(
        amountText: String,
        destination: String,
        note: String,
        category: String,
        entryDate: Date
    ) -> String? {
        submitWalletAction(
            kind: .withdraw,
            amountText: amountText,
            title: destination,
            note: note,
            category: category,
            entryDate: entryDate
        )
    }

    func deleteOperation(id: UUID) {
        guard let index = operations.firstIndex(where: { $0.id == id }) else { return }
        operations.remove(at: index)
        availableBalance = max(openingBalance + operations.reduce(0) { $0 + $1.signedAmount }, 0)
        persistCurrentState()
    }

    private func resetState() {
        openingBalance = 0
        availableBalance = 0
        transferLimit = 0
        operations = []
        investmentRecords = []
        walletRecords = []
    }

    private func detachCloudListeners() {
        homeSummaryListener?.remove()
        homeSummaryListener = nil
        homeOperationsListener?.remove()
        homeOperationsListener = nil
        investmentRecordsListener?.remove()
        investmentRecordsListener = nil
        walletRecordsListener?.remove()
        walletRecordsListener = nil
    }

    private func submitAction(
        kind: HomeOperationKind,
        amountText: String,
        title: String,
        note: String,
        category: String,
        entryDate: Date
    ) -> String? {
        guard activeUserID != nil else {
            return "Your finance session is not ready yet. Please sign in again."
        }

        let cleanTitle = title.trimmed
        let cleanCategory = category.trimmed
        let cleanNote = note.trimmed

        guard let amount = parsedAmount(from: amountText), amount > 0 else {
            return "Enter a valid amount greater than zero."
        }

        guard !cleanTitle.isEmpty else {
            return kind == .payment ? "Enter who you are paying." : "Enter where the deposit came from."
        }

        guard !cleanCategory.isEmpty else {
            return "Select a category before continuing."
        }

        if kind == .payment {
            guard amount <= availableBalance else {
                return "This payment is higher than your available balance."
            }
        }

        let record = HomeOperationRecord(
            title: cleanTitle,
            note: cleanNote,
            amount: amount,
            category: cleanCategory,
            createdAt: normalizedEntryDate(entryDate),
            kind: kind
        )

        operations.insert(record, at: 0)

        switch kind {
        case .payment:
            availableBalance -= amount
        case .deposit:
            availableBalance += amount
        }

        persistCurrentState()
        return nil
    }

    private func submitInvestmentAction(
        kind: InvestmentRecordKind,
        amountText: String,
        counterparty: String,
        note: String,
        selectionTag: String,
        entryDate: Date
    ) -> String? {
        guard activeUserID != nil else {
            return "Your finance session is not ready yet. Please sign in again."
        }

        let cleanCounterparty = counterparty.trimmed
        let cleanNote = note.trimmed

        guard let amount = parsedAmount(from: amountText), amount > 0 else {
            return "Enter a valid investment amount greater than zero."
        }

        guard !cleanCounterparty.isEmpty else {
            return kind == .added ? "Enter who is holding this investment." : "Enter where you are redeeming this amount."
        }

        guard let assetKind = InvestmentHoldingKind.from(selectionTag: selectionTag) else {
            return "Select an investment type before continuing."
        }

        switch kind {
        case .added:
            guard amount <= availableBalance else {
                return "This investment amount is higher than your available balance."
            }
        case .redeemed:
            let activeBalance = activeInvestmentBalance(for: assetKind)
            guard activeBalance > 0 else {
                return "There is no active balance in this investment type yet."
            }

            guard amount <= activeBalance else {
                return "This redeem amount is higher than your active investment balance."
            }
        }

        let record = InvestmentRecord(
            amount: amount,
            counterparty: cleanCounterparty,
            note: cleanNote,
            assetKind: assetKind,
            createdAt: normalizedEntryDate(entryDate),
            kind: kind
        )

        investmentRecords.insert(record, at: 0)
        switch kind {
        case .added:
            availableBalance -= amount
        case .redeemed:
            availableBalance += amount
        }

        persistCurrentInvestmentState()
        persistCurrentState()
        return nil
    }

    private func submitWalletAction(
        kind: WalletRecordKind,
        amountText: String,
        title: String,
        note: String,
        category: String,
        entryDate: Date
    ) -> String? {
        guard activeUserID != nil else {
            return "Your finance session is not ready yet. Please sign in again."
        }

        let cleanTitle = title.trimmed
        let cleanNote = note.trimmed
        let cleanCategory = category.trimmed

        guard let amount = parsedAmount(from: amountText), amount > 0 else {
            return "Enter a valid wallet amount greater than zero."
        }

        guard !cleanTitle.isEmpty else {
            return kind == .addMoney ? "Enter where this money came from." : "Enter where this money is going."
        }

        guard !cleanCategory.isEmpty else {
            return "Select a wallet category before continuing."
        }

        switch kind {
        case .addMoney:
            guard amount <= availableBalance else {
                return "This wallet amount is higher than your available balance."
            }
        case .withdraw:
            guard walletBalance > 0 else {
                return "There is no liquid balance available to withdraw."
            }

            guard amount <= walletBalance else {
                return "This withdraw amount is higher than your liquid wallet balance."
            }
        }

        let record = WalletRecord(
            title: cleanTitle,
            note: cleanNote,
            amount: amount,
            category: cleanCategory,
            createdAt: normalizedEntryDate(entryDate),
            kind: kind
        )

        walletRecords.insert(record, at: 0)
        if kind == .addMoney {
            availableBalance -= amount
        }

        persistCurrentWalletState()
        if kind == .addMoney {
            persistCurrentState()
        }
        return nil
    }

    private func apply(_ snapshot: HomeDashboardSnapshot) {
        apply(
            HomeSummarySnapshot(
                openingBalance: snapshot.openingBalance,
                availableBalance: snapshot.availableBalance,
                transferLimit: snapshot.transferLimit
            )
        )
        applyHomeOperations(snapshot.operations)
    }

    private func apply(_ snapshot: HomeSummarySnapshot) {
        openingBalance = snapshot.openingBalance
        availableBalance = snapshot.availableBalance
        transferLimit = snapshot.transferLimit
    }

    private func applyHomeOperations(_ records: [HomeOperationRecord]) {
        operations = records.sorted { $0.createdAt > $1.createdAt }
    }

    private func apply(_ snapshot: InvestmentDashboardSnapshot) {
        applyInvestmentRecords(snapshot.records)
    }

    private func applyInvestmentRecords(_ records: [InvestmentRecord]) {
        investmentRecords = records.sorted { $0.createdAt > $1.createdAt }
    }

    private func apply(_ snapshot: WalletDashboardSnapshot) {
        applyWalletRecords(snapshot.records)
    }

    private func applyWalletRecords(_ records: [WalletRecord]) {
        walletRecords = records.sorted { $0.createdAt > $1.createdAt }
    }

    private func persistCurrentState() {
        guard let activeUserID else { return }
        let summary = HomeSummarySnapshot(
            openingBalance: openingBalance,
            availableBalance: availableBalance,
            transferLimit: transferLimit
        )
        persistHomeState(summary, operations: operations, for: activeUserID)
    }

    private func persistCurrentInvestmentState() {
        guard let activeUserID else { return }
        persistInvestmentRecords(investmentRecords, for: activeUserID)
    }

    private func persistCurrentWalletState() {
        guard let activeUserID else { return }
        persistWalletRecords(walletRecords, for: activeUserID)
    }

    private func attachCloudListeners(for userID: String) {
        let homeReference = FirestorePaths.homeDocument(for: userID, in: firestore)
        homeSummaryListener = homeReference.addSnapshotListener { [weak self] snapshot, error in
            Task { @MainActor in
                guard let self else { return }
                guard self.activeUserID == userID else { return }

                if let error {
                    print("Home snapshot listener error: \(error.localizedDescription)")
                    return
                }

                guard let snapshot, snapshot.exists, let data = snapshot.data() else { return }

                do {
                    let decoded = try FirestoreDocumentCodec.decode(HomeSummarySnapshot.self, from: data)
                    self.apply(decoded)
                } catch {
                    print("Home summary decode error: \(error.localizedDescription)")
                }
            }
        }

        let operationsReference = FirestorePaths.homeOperationsCollection(for: userID, in: firestore)
            .order(by: "createdAt", descending: true)
        homeOperationsListener = operationsReference.addSnapshotListener { [weak self] snapshot, error in
            Task { @MainActor in
                guard let self else { return }
                guard self.activeUserID == userID else { return }

                if let error {
                    print("Home operations listener error: \(error.localizedDescription)")
                    return
                }

                do {
                    self.applyHomeOperations(try self.decodeDocuments(snapshot?.documents ?? [], as: HomeOperationRecord.self))
                } catch {
                    print("Home operations decode error: \(error.localizedDescription)")
                }
            }
        }

        let investmentsReference = FirestorePaths.investmentRecordsCollection(for: userID, in: firestore)
            .order(by: "createdAt", descending: true)
        investmentRecordsListener = investmentsReference.addSnapshotListener { [weak self] snapshot, error in
            Task { @MainActor in
                guard let self else { return }
                guard self.activeUserID == userID else { return }

                if let error {
                    print("Investment records listener error: \(error.localizedDescription)")
                    return
                }

                do {
                    self.applyInvestmentRecords(try self.decodeDocuments(snapshot?.documents ?? [], as: InvestmentRecord.self))
                } catch {
                    print("Investment records decode error: \(error.localizedDescription)")
                }
            }
        }

        let walletReference = FirestorePaths.walletRecordsCollection(for: userID, in: firestore)
            .order(by: "createdAt", descending: true)
        walletRecordsListener = walletReference.addSnapshotListener { [weak self] snapshot, error in
            Task { @MainActor in
                guard let self else { return }
                guard self.activeUserID == userID else { return }

                if let error {
                    print("Wallet records listener error: \(error.localizedDescription)")
                    return
                }

                do {
                    self.applyWalletRecords(try self.decodeDocuments(snapshot?.documents ?? [], as: WalletRecord.self))
                } catch {
                    print("Wallet records decode error: \(error.localizedDescription)")
                }
            }
        }
    }

    private func bootstrapCloudState(for userID: String) async {
        await ensureHomeState(for: userID)
        await ensureInvestmentState(for: userID)
        await ensureWalletState(for: userID)
    }

    private func ensureHomeState(for userID: String) async {
        let reference = FirestorePaths.homeDocument(for: userID, in: firestore)

        do {
            let snapshot = try await reference.getDocumentAsync()

            if let data = snapshot.data(), snapshot.exists {
                let remoteSnapshot = migrated(try FirestoreDocumentCodec.decode(HomeDashboardSnapshot.self, from: data))
                let summary = HomeSummarySnapshot(
                    openingBalance: remoteSnapshot.openingBalance,
                    availableBalance: remoteSnapshot.availableBalance,
                    transferLimit: remoteSnapshot.transferLimit
                )
                try await saveHomeSummaryToCloud(summary, for: userID)
                if !remoteSnapshot.operations.isEmpty {
                    try await saveHomeOperationsToCloud(remoteSnapshot.operations, for: userID)
                }
                guard activeUserID == userID else { return }
                apply(summary)
                if !remoteSnapshot.operations.isEmpty {
                    applyHomeOperations(remoteSnapshot.operations)
                }
                return
            }

            let summary = Self.emptyHomeSummary
            try await saveHomeSummaryToCloud(summary, for: userID)
            guard activeUserID == userID else { return }
            apply(summary)
        } catch {
            print("Home state bootstrap failed: \(error.localizedDescription)")
        }
    }

    private func ensureInvestmentState(for userID: String) async {
        let reference = FirestorePaths.investmentsDocument(for: userID, in: firestore)

        do {
            let snapshot = try await reference.getDocumentAsync()

            if let data = snapshot.data(), snapshot.exists {
                let remoteSnapshot = try FirestoreDocumentCodec.decode(InvestmentDashboardSnapshot.self, from: data)
                if !remoteSnapshot.records.isEmpty {
                    try await saveInvestmentRecordsToCloud(remoteSnapshot.records, for: userID)
                    try await saveCollectionContainer(to: reference)
                }
                guard activeUserID == userID else { return }
                if !remoteSnapshot.records.isEmpty {
                    applyInvestmentRecords(remoteSnapshot.records)
                }
                return
            }

            try await saveCollectionContainer(to: reference)
        } catch {
            print("Investment state bootstrap failed: \(error.localizedDescription)")
        }
    }

    private func ensureWalletState(for userID: String) async {
        let reference = FirestorePaths.walletDocument(for: userID, in: firestore)

        do {
            let snapshot = try await reference.getDocumentAsync()

            if let data = snapshot.data(), snapshot.exists {
                let remoteSnapshot = try FirestoreDocumentCodec.decode(WalletDashboardSnapshot.self, from: data)
                if !remoteSnapshot.records.isEmpty {
                    try await saveWalletRecordsToCloud(remoteSnapshot.records, for: userID)
                    try await saveCollectionContainer(to: reference)
                }
                guard activeUserID == userID else { return }
                if !remoteSnapshot.records.isEmpty {
                    applyWalletRecords(remoteSnapshot.records)
                }
                return
            }

            try await saveCollectionContainer(to: reference)
        } catch {
            print("Wallet state bootstrap failed: \(error.localizedDescription)")
        }
    }

    private func persistHomeState(_ summary: HomeSummarySnapshot, operations: [HomeOperationRecord], for userID: String) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                try await self.saveHomeSummaryToCloud(summary, for: userID)
                try await self.saveHomeOperationsToCloud(operations, for: userID)
            } catch {
                print("Home state save failed: \(error.localizedDescription)")
            }
        }
    }

    private func persistInvestmentRecords(_ records: [InvestmentRecord], for userID: String) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                try await self.saveInvestmentRecordsToCloud(records, for: userID)
            } catch {
                print("Investment records save failed: \(error.localizedDescription)")
            }
        }
    }

    private func persistWalletRecords(_ records: [WalletRecord], for userID: String) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                try await self.saveWalletRecordsToCloud(records, for: userID)
            } catch {
                print("Wallet records save failed: \(error.localizedDescription)")
            }
        }
    }

    private func saveHomeSummaryToCloud(_ snapshot: HomeSummarySnapshot, for userID: String) async throws {
        let reference = FirestorePaths.homeDocument(for: userID, in: firestore)
        let documentData = try FirestoreDocumentCodec.dictionary(from: snapshot, encoder: encoder)
        try await reference.setDataAsync(documentData, merge: false)
    }

    private func saveHomeOperationsToCloud(_ operations: [HomeOperationRecord], for userID: String) async throws {
        try await syncCollection(
            operations,
            in: FirestorePaths.homeOperationsCollection(for: userID, in: firestore),
            documentID: { $0.id.uuidString }
        )
    }

    private func saveInvestmentRecordsToCloud(_ records: [InvestmentRecord], for userID: String) async throws {
        try await syncCollection(
            records,
            in: FirestorePaths.investmentRecordsCollection(for: userID, in: firestore),
            documentID: { $0.id.uuidString }
        )
    }

    private func saveWalletRecordsToCloud(_ records: [WalletRecord], for userID: String) async throws {
        try await syncCollection(
            records,
            in: FirestorePaths.walletRecordsCollection(for: userID, in: firestore),
            documentID: { $0.id.uuidString }
        )
    }

    private func saveCollectionContainer(to reference: DocumentReference) async throws {
        try await reference.setDataAsync(["schemaVersion": 2], merge: false)
    }

    private func syncCollection<T: Encodable>(
        _ records: [T],
        in collection: CollectionReference,
        documentID: (T) -> String
    ) async throws {
        let snapshot = try await collection.getDocumentsAsync()
        let existingIDs = Set(snapshot.documents.map(\.documentID))
        let currentIDs = Set(records.map(documentID))

        guard !records.isEmpty || !existingIDs.isEmpty else {
            return
        }

        let batch = firestore.batch()

        for record in records {
            let reference = collection.document(documentID(record))
            let documentData = try FirestoreDocumentCodec.dictionary(from: record, encoder: encoder)
            batch.setData(documentData, forDocument: reference, merge: false)
        }

        for obsoleteID in existingIDs.subtracting(currentIDs) {
            batch.deleteDocument(collection.document(obsoleteID))
        }

        try await batch.commitAsync()
    }

    private func decodeDocuments<T: Decodable>(
        _ documents: [QueryDocumentSnapshot],
        as type: T.Type
    ) throws -> [T] {
        try documents.map { document in
            try FirestoreDocumentCodec.decode(type, from: document.data())
        }
    }

    private func migrated(_ snapshot: HomeDashboardSnapshot) -> HomeDashboardSnapshot {
        guard isLegacySeedSnapshot(snapshot) else {
            return snapshot
        }

        return Self.emptySnapshot
    }

    private func isLegacySeedSnapshot(_ snapshot: HomeDashboardSnapshot) -> Bool {
        let legacyTitles = Set([
            "Swiggy",
            "Uber",
            "Bank Transfer",
            "Spotify",
            "Amazon",
            "Salary Credit"
        ])

        return snapshot.availableBalance == 135_280.31
            && snapshot.transferLimit == 12_000
            && snapshot.operations.count == legacyTitles.count
            && Set(snapshot.operations.map(\.title)) == legacyTitles
    }

    private func parsedAmount(from text: String) -> Double? {
        let normalized = text
            .replacingOccurrences(of: "₹", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmed

        return Double(normalized)
    }

    private func normalizedEntryDate(_ date: Date) -> Date {
        min(date, Date())
    }

    private func groupedSections(from records: [HomeOperationRecord]) -> [TransactionDaySection] {
        let groupedRecords = Dictionary(grouping: records) { record in
            calendar.startOfDay(for: record.createdAt)
        }

        return groupedRecords.keys
            .sorted(by: >)
            .compactMap { day in
                guard let records = groupedRecords[day] else { return nil }

                let transactions = records
                    .sorted { $0.createdAt > $1.createdAt }
                    .map(\.transactionModel)

                return TransactionDaySection(
                    title: sectionTitle(for: day),
                    transactions: transactions
                )
            }
    }

    private func groupedInvestmentSections(from records: [InvestmentRecord]) -> [InvestmentActivitySection] {
        let groupedRecords = Dictionary(grouping: records) { record in
            calendar.startOfDay(for: record.createdAt)
        }

        return groupedRecords.keys
            .sorted(by: >)
            .compactMap { day in
                guard let records = groupedRecords[day] else { return nil }

                let activities = records
                    .sorted { $0.createdAt > $1.createdAt }
                    .map(\.activityModel)

                return InvestmentActivitySection(
                    title: sectionTitle(for: day),
                    activities: activities
                )
            }
    }

    private func groupedWalletSections(from records: [WalletRecord]) -> [WalletActivitySection] {
        let groupedRecords = Dictionary(grouping: records) { record in
            calendar.startOfDay(for: record.createdAt)
        }

        return groupedRecords.keys
            .sorted(by: >)
            .compactMap { day in
                guard let records = groupedRecords[day] else { return nil }

                let entries = records
                    .sorted { $0.createdAt > $1.createdAt }
                    .map(\.entryModel)

                return WalletActivitySection(
                    title: sectionTitle(for: day),
                    entries: entries
                )
            }
    }

    private func activeInvestmentBalance(for assetKind: InvestmentHoldingKind) -> Double {
        let added = investmentRecords
            .filter { $0.assetKind == assetKind && $0.kind == .added }
            .reduce(0) { $0 + $1.amount }
        let redeemed = investmentRecords
            .filter { $0.assetKind == assetKind && $0.kind == .redeemed }
            .reduce(0) { $0 + $1.amount }

        return max(added - redeemed, 0)
    }

    private func sectionTitle(for date: Date) -> String {
        if calendar.isDateInToday(date) {
            return "Today"
        }

        if calendar.isDateInYesterday(date) {
            return "Yesterday"
        }

        if calendar.isDate(date, equalTo: .now, toGranularity: .weekOfYear) {
            return weekdayFormatter.string(from: date)
        }

        return shortDateFormatter.string(from: date)
    }

    private func includes(_ date: Date, in range: InsightRange) -> Bool {
        switch range {
        case .week:
            return calendar.isDate(date, equalTo: .now, toGranularity: .weekOfYear)
        case .month:
            return calendar.isDate(date, equalTo: .now, toGranularity: .month)
        case .year:
            return calendar.isDate(date, equalTo: .now, toGranularity: .year)
        }
    }

    private func insightStat(
        for category: InsightTrackedCategory,
        from payments: [HomeOperationRecord]
    ) -> InsightCategoryStat {
        let matchingPayments = payments.filter { category.matches($0.category) }
        return InsightCategoryStat(
            category: category,
            amount: matchingPayments.reduce(0) { $0 + $1.amount },
            count: matchingPayments.count
        )
    }

    private func insightBadgeTitle(for range: InsightRange) -> String {
        switch range {
        case .week:
            return "This Week"
        case .month:
            return monthYearFormatter.string(from: .now)
        case .year:
            return yearFormatter.string(from: .now)
        }
    }

    private func insightSummaryTitle(for range: InsightRange) -> String {
        switch range {
        case .week:
            return "Spent this week"
        case .month:
            return "Spent this \(monthNameFormatter.string(from: .now))"
        case .year:
            return "Spent this year"
        }
    }

    private func insightSupportingText(paymentCount: Int, range: InsightRange) -> String {
        guard paymentCount > 0 else {
            switch range {
            case .week:
                return "No payments this week"
            case .month:
                return "No payments this month"
            case .year:
                return "No payments this year"
            }
        }

        return paymentCountLabel(paymentCount)
    }

    private func insightPercentageText(amount: Double, total: Double) -> String {
        guard total > 0 else { return "0%" }
        let percentage = Int(((amount / total) * 100).rounded())
        return "\(percentage)%"
    }

    private func paymentCountLabel(_ count: Int) -> String {
        if count == 0 {
            return "No payments"
        }

        return count == 1 ? "1 payment" : "\(count) payments"
    }

    private static var emptySnapshot: HomeDashboardSnapshot {
        HomeDashboardSnapshot(
            openingBalance: 0,
            availableBalance: 0,
            transferLimit: 0,
            operations: []
        )
    }

    private static var emptyHomeSummary: HomeSummarySnapshot {
        HomeSummarySnapshot(
            openingBalance: 0,
            availableBalance: 0,
            transferLimit: 0
        )
    }

    private static var emptyInvestmentSnapshot: InvestmentDashboardSnapshot {
        InvestmentDashboardSnapshot(records: [])
    }

    private static var emptyWalletSnapshot: WalletDashboardSnapshot {
        WalletDashboardSnapshot(records: [])
    }
}

private let weekdayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE"
    return formatter
}()

private let shortDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMM"
    return formatter
}()

private let investmentTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm a"
    return formatter
}()

private let walletTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm a"
    return formatter
}()

private let walletCardTimestampFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd MMM, hh:mm a"
    return formatter
}()

private let monthYearFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter
}()

private let monthNameFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM"
    return formatter
}()

private let yearFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy"
    return formatter
}()

private struct InsightCategoryStat {
    let category: InsightTrackedCategory
    let amount: Double
    let count: Int
}

private enum InsightTrackedCategory: String, CaseIterable {
    case food = "Food"
    case travel = "Travel"
    case shopping = "Shopping"
    case bills = "Bills"

    var title: String {
        rawValue
    }

    var barTitle: String {
        switch self {
        case .shopping:
            return "Shop"
        default:
            return rawValue
        }
    }

    var caption: String {
        switch self {
        case .food:
            return "Dining"
        case .travel:
            return "Transport"
        case .shopping:
            return "Lifestyle"
        case .bills:
            return "Utilities"
        }
    }

    var icon: String {
        switch self {
        case .food:
            return "fork.knife"
        case .travel:
            return "car.fill"
        case .shopping:
            return "bag.fill"
        case .bills:
            return "doc.text.fill"
        }
    }

    var color: Color {
        switch self {
        case .food:
            return FinancePalette.royalBlue
        case .travel:
            return FinancePalette.oceanBlue
        case .shopping:
            return FinancePalette.iceBlue
        case .bills:
            return FinancePalette.sapphireBlue
        }
    }

    var backgroundTint: Color {
        switch self {
        case .food:
            return Color(red: 0.95, green: 0.97, blue: 1.0)
        case .travel:
            return Color(red: 0.94, green: 0.98, blue: 1.0)
        case .shopping:
            return Color(red: 0.95, green: 0.98, blue: 1.0)
        case .bills:
            return Color(red: 0.94, green: 0.96, blue: 0.99)
        }
    }

    func matches(_ category: String) -> Bool {
        rawValue.caseInsensitiveCompare(category) == .orderedSame
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
