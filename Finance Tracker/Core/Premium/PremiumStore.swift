import Combine
import Foundation
import StoreKit

enum PremiumPlan: String, Codable, Equatable {
    case free
    case monthly
    case yearly

    var badgeTitle: String {
        switch self {
        case .free:
            return "Standard"
        case .monthly:
            return "Premium Monthly"
        case .yearly:
            return "Premium Yearly"
        }
    }

    var title: String {
        switch self {
        case .free:
            return "Standard"
        case .monthly:
            return "Monthly"
        case .yearly:
            return "Yearly"
        }
    }

    var featureSummary: String {
        switch self {
        case .free:
            return "Core finance tracking with essential budgeting tools."
        case .monthly:
            return "Flexible premium access with monthly renewal."
        case .yearly:
            return "Best long-term value for advanced finance tools."
        }
    }
}

enum PremiumFeature {
    case customCategories
    case yearlyInsights
    case premiumAlerts

    var title: String {
        switch self {
        case .customCategories:
            return "Custom Categories"
        case .yearlyInsights:
            return "Yearly Insights"
        case .premiumAlerts:
            return "Premium Alerts"
        }
    }

    var subtitle: String {
        switch self {
        case .customCategories:
            return "Create your own entry categories for payments, deposits, and wallet flows."
        case .yearlyInsights:
            return "Unlock the yearly range in Insights for a bigger spending picture."
        case .premiumAlerts:
            return "Enable premium insight reminders and advanced finance prompts."
        }
    }
}

enum PremiumCatalog {
    static let monthlyProductID = "com.nakhul.financeTracker.premium.monthly"
    static let yearlyProductID = "com.nakhul.financeTracker.premium.yearly"
    static let productIDs = [monthlyProductID, yearlyProductID]

    static func plan(for productID: String) -> PremiumPlan {
        switch productID {
        case yearlyProductID:
            return .yearly
        case monthlyProductID:
            return .monthly
        default:
            return .free
        }
    }
}

@MainActor
final class PremiumStore: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var activePlan: PremiumPlan = .free
    @Published private(set) var activeProductID: String?
    @Published private(set) var activeExpirationDate: Date?
    @Published private(set) var isPremium = false
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var isRefreshingEntitlements = false
    @Published private(set) var isProcessingPurchase = false
    @Published private(set) var isRestoringPurchases = false
    @Published var errorMessage: String?
    @Published var infoMessage: String?

    private var transactionUpdatesTask: Task<Void, Never>?

    init() {
        transactionUpdatesTask = observeTransactionUpdates()

        Task {
            await prepare()
        }
    }

    deinit {
        transactionUpdatesTask?.cancel()
    }

    var premiumBadgeTitle: String {
        activePlan.badgeTitle
    }

    func prepare() async {
        await fetchProducts()
        await refreshEntitlements()
    }

    func fetchProducts() async {
        guard !isLoadingProducts else { return }

        isLoadingProducts = true
        errorMessage = nil

        defer {
            isLoadingProducts = false
        }

        do {
            let fetchedProducts = try await Product.products(for: PremiumCatalog.productIDs)
            products = fetchedProducts.sorted(by: Self.sortProducts)
        } catch {
            errorMessage = "Premium plans could not be loaded right now. \(error.localizedDescription)"
        }
    }

    func refreshEntitlements() async {
        guard !isRefreshingEntitlements else { return }

        isRefreshingEntitlements = true
        defer {
            isRefreshingEntitlements = false
        }

        var activeTransactions: [StoreKit.Transaction] = []

        for await result in StoreKit.Transaction.currentEntitlements {
            do {
                let transaction = try Self.checkVerified(result)
                activeTransactions.append(transaction)
            } catch {
                errorMessage = "One premium entitlement could not be verified."
            }
        }

        applyEntitlements(activeTransactions)
    }

    func purchase(_ product: Product) async {
        guard !isProcessingPurchase else { return }

        isProcessingPurchase = true
        errorMessage = nil
        infoMessage = nil

        defer {
            isProcessingPurchase = false
        }

        do {
            let result = try await product.purchase()

            switch result {
            case let .success(verification):
                let transaction = try Self.checkVerified(verification)
                await transaction.finish()
                await refreshEntitlements()
                infoMessage = "\(product.displayName) is now active on this Apple ID."
            case .userCancelled:
                infoMessage = "Purchase was cancelled."
            case .pending:
                infoMessage = "Purchase is pending approval."
            @unknown default:
                infoMessage = "Purchase state updated."
            }
        } catch {
            errorMessage = "Premium purchase failed. \(error.localizedDescription)"
        }
    }

    func restorePurchases() async {
        guard !isRestoringPurchases else { return }

        isRestoringPurchases = true
        errorMessage = nil
        infoMessage = nil

        defer {
            isRestoringPurchases = false
        }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
            infoMessage = isPremium
                ? "Premium access restored successfully."
                : "No active premium purchases were found for this Apple ID."
        } catch {
            errorMessage = "Restore purchases failed. \(error.localizedDescription)"
        }
    }

    func clearMessages() {
        errorMessage = nil
        infoMessage = nil
    }

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task.detached(priority: .background) { [weak self] in
            guard let self else { return }

            for await result in StoreKit.Transaction.updates {
                do {
                    let transaction = try Self.checkVerified(result)
                    await transaction.finish()
                    await self.refreshEntitlements()
                } catch {
                    await MainActor.run {
                        self.errorMessage = "Premium entitlement update could not be verified."
                    }
                }
            }
        }
    }

    func hasAccess(to feature: PremiumFeature) -> Bool {
        switch feature {
        case .customCategories, .yearlyInsights, .premiumAlerts:
            return isPremium
        }
    }

    private func applyEntitlements(_ transactions: [StoreKit.Transaction]) {
        let preferredTransaction = transactions.max(by: { lhs, rhs in
            let lhsRank = Self.planRank(for: lhs.productID)
            let rhsRank = Self.planRank(for: rhs.productID)

            if lhsRank == rhsRank {
                return (lhs.expirationDate ?? .distantPast) < (rhs.expirationDate ?? .distantPast)
            }

            return lhsRank < rhsRank
        })

        activeProductID = preferredTransaction?.productID
        activeExpirationDate = preferredTransaction?.expirationDate
        isPremium = preferredTransaction != nil
        activePlan = preferredTransaction.map { PremiumCatalog.plan(for: $0.productID) } ?? .free
    }

    private nonisolated static func checkVerified<T>(_ result: StoreKit.VerificationResult<T>) throws -> T {
        switch result {
        case let .verified(safe):
            return safe
        case let .unverified(_, error):
            throw error
        }
    }

    private static func sortProducts(_ lhs: Product, _ rhs: Product) -> Bool {
        sortIndex(for: lhs) < sortIndex(for: rhs)
    }

    private static func sortIndex(for product: Product) -> Int {
        switch product.id {
        case PremiumCatalog.monthlyProductID:
            return 0
        case PremiumCatalog.yearlyProductID:
            return 1
        default:
            return 99
        }
    }

    private static func planRank(for productID: String) -> Int {
        switch PremiumCatalog.plan(for: productID) {
        case .free:
            return 0
        case .monthly:
            return 1
        case .yearly:
            return 2
        }
    }
}
