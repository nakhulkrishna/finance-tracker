import SwiftUI

struct TransactionDaySection: Identifiable {
    let id = UUID()
    let title: String
    let transactions: [Transaction]
}

struct Transaction: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let amount: String
    let badgeText: String
    let brandColor: Color
    let status: String
    let linkedRecordID: UUID?

    init(
        title: String,
        subtitle: String,
        amount: String,
        badgeText: String,
        brandColor: Color,
        status: String,
        linkedRecordID: UUID? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.amount = amount
        self.badgeText = badgeText
        self.brandColor = brandColor
        self.status = status
        self.linkedRecordID = linkedRecordID
    }

    var numericAmount: Double {
        let cleaned = amount
            .replacingOccurrences(of: "₹", with: "")
            .replacingOccurrences(of: ",", with: "")

        return Double(cleaned) ?? 0
    }
}

struct WalletEntry: Identifiable {
    enum Kind {
        case deposit
        case withdrawal

        var icon: String {
            switch self {
            case .deposit:
                return "arrow.down.circle.fill"
            case .withdrawal:
                return "arrow.up.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .deposit:
                return FinancePalette.royalBlue
            case .withdrawal:
                return FinancePalette.sapphireBlue
            }
        }
    }

    let id: UUID
    let title: String
    let subtitle: String
    let amount: String
    let time: String
    let kind: Kind

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        amount: String,
        time: String,
        kind: Kind
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.amount = amount
        self.time = time
        self.kind = kind
    }

    var numericAmount: Double {
        let cleaned = amount
            .replacingOccurrences(of: "₹", with: "")
            .replacingOccurrences(of: ",", with: "")

        return Double(cleaned) ?? 0
    }

}

struct WalletActivitySection: Identifiable {
    let id = UUID()
    let title: String
    let entries: [WalletEntry]
}

extension Double {
    var currencyText: String {
        "₹\(financeCurrencyFormatter.string(from: NSNumber(value: abs(self))) ?? String(format: "%.2f", abs(self)))"
    }

    var signedCurrencyText: String {
        let prefix: String

        if self > 0 {
            prefix = "+"
        } else if self < 0 {
            prefix = "-"
        } else {
            prefix = ""
        }

        return prefix + abs(self).currencyText
    }
}

private let financeCurrencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.locale = Locale(identifier: "en_IN")
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    return formatter
}()

enum InvestmentHoldingKind: String, CaseIterable, Identifiable, Codable {
    case familyReserve
    case mutualFund
    case gold
    case fixedDeposit

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .familyReserve:
            return "person.2.fill"
        case .mutualFund:
            return "chart.line.uptrend.xyaxis"
        case .gold:
            return "seal.fill"
        case .fixedDeposit:
            return "building.columns.fill"
        }
    }

    var color: Color {
        switch self {
        case .familyReserve:
            return FinancePalette.royalBlue
        case .mutualFund:
            return FinancePalette.oceanBlue
        case .gold:
            return FinancePalette.sapphireBlue
        case .fixedDeposit:
            return FinancePalette.iceBlue
        }
    }

    var badgeTitle: String {
        switch self {
        case .familyReserve:
            return "Family Held"
        case .mutualFund:
            return "SIP"
        case .gold:
            return "Gold"
        case .fixedDeposit:
            return "FD"
        }
    }

    var selectionTitle: String {
        switch self {
        case .familyReserve:
            return "Family Hold"
        case .mutualFund:
            return "SIP"
        case .gold:
            return "Gold"
        case .fixedDeposit:
            return "FD"
        }
    }

    var portfolioTitle: String {
        switch self {
        case .familyReserve:
            return "Family Reserve"
        case .mutualFund:
            return "SIP Basket"
        case .gold:
            return "Gold Reserve"
        case .fixedDeposit:
            return "Fixed Deposit"
        }
    }

    var defaultSubtitle: String {
        switch self {
        case .familyReserve:
            return "Family-held money that still belongs to you"
        case .mutualFund:
            return "Recurring investment tracked separately from spending"
        case .gold:
            return "Protected value kept outside your liquid balance"
        case .fixedDeposit:
            return "Locked savings asset kept for future use"
        }
    }

    static func from(selectionTag: String) -> InvestmentHoldingKind? {
        switch selectionTag.lowercased() {
        case "family hold", "family held", "family reserve", "family":
            return .familyReserve
        case "sip", "mutual fund", "fund":
            return .mutualFund
        case "gold":
            return .gold
        case "fd", "fixed deposit":
            return .fixedDeposit
        default:
            return nil
        }
    }
}

struct InvestmentHolding: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let holderName: String
    let investedAmount: Double
    let currentValue: Double
    let monthlyContribution: Double
    let note: String
    let kind: InvestmentHoldingKind

    var growthAmount: Double {
        currentValue - investedAmount
    }
}

struct InvestmentActivitySection: Identifiable {
    let id = UUID()
    let title: String
    let activities: [InvestmentActivity]
}

struct InvestmentActivity: Identifiable {
    enum Kind {
        case invested
        case redeemed
        case growth

        var icon: String {
            switch self {
            case .invested:
                return "arrow.down.circle.fill"
            case .redeemed:
                return "arrow.up.circle.fill"
            case .growth:
                return "sparkles"
            }
        }

        var color: Color {
            switch self {
            case .invested:
                return FinancePalette.royalBlue
            case .redeemed:
                return FinancePalette.sapphireBlue
            case .growth:
                return FinancePalette.oceanBlue
            }
        }

        var signedAmount: Double {
            switch self {
            case .invested, .growth:
                return 1
            case .redeemed:
                return -1
            }
        }
    }

    let id = UUID()
    let title: String
    let subtitle: String
    let amount: Double
    let time: String
    let badge: String
    let kind: Kind

    var amountText: String {
        (amount * kind.signedAmount).signedCurrencyText
    }
}

enum InsightRange: String, CaseIterable, Identifiable {
    case week
    case month
    case year

    var id: String { rawValue }

    var displayTitle: String {
        rawValue.capitalized
    }
}

struct InsightSnapshot {
    let badgeTitle: String
    let summaryTitle: String
    let totalAmount: String
    let supportingText: String
    let chartBars: [InsightBar]
    let categories: [InsightCategory]
}

struct InsightBar: Identifiable {
    let title: String
    let amount: String
    let percentage: String
    let color: Color
    let fillRatio: CGFloat

    var id: String { title }
}

struct InsightCategory: Identifiable {
    let title: String
    let caption: String
    let amount: String
    let percentage: String
    let footnote: String
    let icon: String
    let color: Color
    let backgroundTint: Color

    var id: String { title }
}
