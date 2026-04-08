import SwiftUI

struct TransactionDaySection: Identifiable {
    let id = UUID()
    let title: String
    let transactions: [Transaction]

    static let sampleData: [TransactionDaySection] = [
        TransactionDaySection(
            title: "Today",
            transactions: [
                Transaction(
                    title: "AT&T",
                    subtitle: "Unlimited Family Plan",
                    amount: "-₹34.99",
                    badgeText: "AT",
                    brandColor: FinancePalette.oceanBlue,
                    status: "Auto-paid"
                ),
                Transaction(
                    title: "Creative Cloud",
                    subtitle: "CC All Apps",
                    amount: "-₹59.99",
                    badgeText: "CC",
                    brandColor: Color(red: 0.33, green: 0.55, blue: 1.0),
                    status: "Subscription"
                )
            ]
        ),
        TransactionDaySection(
            title: "Yesterday",
            transactions: [
                Transaction(
                    title: "Blizzard Entertainment",
                    subtitle: "6-Month Subscription",
                    amount: "-₹79.89",
                    badgeText: "BZ",
                    brandColor: Color(red: 0.09, green: 0.36, blue: 0.92),
                    status: "Gaming"
                ),
                Transaction(
                    title: "Netflix",
                    subtitle: "Basic Plan",
                    amount: "-₹7.99",
                    badgeText: "N",
                    brandColor: Color(red: 0.15, green: 0.46, blue: 0.98),
                    status: "Streaming"
                )
            ]
        )
    ]

    static let fullHistorySampleData: [TransactionDaySection] = [
        TransactionDaySection(
            title: "Today",
            transactions: [
                Transaction(
                    title: "Swiggy",
                    subtitle: "Lunch order",
                    amount: "-₹249.00",
                    badgeText: "SW",
                    brandColor: FinancePalette.royalBlue,
                    status: "Food"
                ),
                Transaction(
                    title: "Uber",
                    subtitle: "Office commute",
                    amount: "-₹188.40",
                    badgeText: "UB",
                    brandColor: FinancePalette.oceanBlue,
                    status: "Travel"
                ),
                Transaction(
                    title: "Deposit",
                    subtitle: "Wallet top-up",
                    amount: "+₹2,500.00",
                    badgeText: "DP",
                    brandColor: FinancePalette.sapphireBlue,
                    status: "Incoming"
                )
            ]
        ),
        TransactionDaySection(
            title: "Yesterday",
            transactions: [
                Transaction(
                    title: "Spotify",
                    subtitle: "Premium plan",
                    amount: "-₹119.00",
                    badgeText: "SP",
                    brandColor: FinancePalette.iceBlue,
                    status: "Subscription"
                ),
                Transaction(
                    title: "Amazon",
                    subtitle: "Home essentials",
                    amount: "-₹648.00",
                    badgeText: "AM",
                    brandColor: FinancePalette.royalBlue,
                    status: "Shopping"
                )
            ]
        ),
        TransactionDaySection(
            title: "Monday",
            transactions: [
                Transaction(
                    title: "Electricity Bill",
                    subtitle: "BESCOM payment",
                    amount: "-₹1,420.00",
                    badgeText: "EB",
                    brandColor: FinancePalette.sapphireBlue,
                    status: "Auto-paid"
                ),
                Transaction(
                    title: "Salary Credit",
                    subtitle: "Monthly income",
                    amount: "+₹48,000.00",
                    badgeText: "SC",
                    brandColor: FinancePalette.oceanBlue,
                    status: "Incoming"
                )
            ]
        ),
        TransactionDaySection(
            title: "Sunday",
            transactions: [
                Transaction(
                    title: "Netflix",
                    subtitle: "Monthly plan",
                    amount: "-₹199.00",
                    badgeText: "NF",
                    brandColor: FinancePalette.royalBlue,
                    status: "Streaming"
                ),
                Transaction(
                    title: "BigBasket",
                    subtitle: "Weekly groceries",
                    amount: "-₹934.50",
                    badgeText: "BB",
                    brandColor: FinancePalette.oceanBlue,
                    status: "Food"
                )
            ]
        )
    ]
}

struct Transaction: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let amount: String
    let badgeText: String
    let brandColor: Color
    let status: String
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

    let id = UUID()
    let title: String
    let subtitle: String
    let amount: String
    let time: String
    let kind: Kind

    var numericAmount: Double {
        let cleaned = amount
            .replacingOccurrences(of: "₹", with: "")
            .replacingOccurrences(of: ",", with: "")

        return Double(cleaned) ?? 0
    }

    static let sampleData: [WalletEntry] = [
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
        ),
        WalletEntry(
            title: "Cash Added",
            subtitle: "Office reimbursement",
            amount: "+₹850",
            time: "Yesterday",
            kind: .deposit
        ),
        WalletEntry(
            title: "Wallet Spend",
            subtitle: "Travel cash out",
            amount: "-₹320",
            time: "Yesterday",
            kind: .withdrawal
        )
    ]
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

struct SalaryAllocationItem: Identifiable {
    let id = UUID()
    let title: String
    let amount: Double
    let share: Int
    let note: String
    let color: Color

    static let sampleData: [SalaryAllocationItem] = [
        SalaryAllocationItem(
            title: "Investment",
            amount: 15000,
            share: 31,
            note: "Family-held money and SIP",
            color: FinancePalette.royalBlue
        ),
        SalaryAllocationItem(
            title: "EMI",
            amount: 12000,
            share: 25,
            note: "Loan and fixed commitments",
            color: FinancePalette.sapphireBlue
        ),
        SalaryAllocationItem(
            title: "Living",
            amount: 14500,
            share: 30,
            note: "Food, travel, and bills",
            color: FinancePalette.oceanBlue
        ),
        SalaryAllocationItem(
            title: "Free Cash",
            amount: 6500,
            share: 14,
            note: "Wallet and safety buffer",
            color: FinancePalette.iceBlue
        )
    ]
}

enum InvestmentHoldingKind: String, CaseIterable, Identifiable {
    case familyReserve
    case mutualFund
    case gold

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .familyReserve:
            return "person.2.fill"
        case .mutualFund:
            return "chart.line.uptrend.xyaxis"
        case .gold:
            return "seal.fill"
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

    static let sampleData: [InvestmentHolding] = [
        InvestmentHolding(
            title: "Family Growth Pool",
            subtitle: "Money sent to father but still yours",
            holderName: "Held by Father",
            investedAmount: 180000,
            currentValue: 198500,
            monthlyContribution: 12000,
            note: "Use this when money is safe with family and remains your asset.",
            kind: .familyReserve
        ),
        InvestmentHolding(
            title: "Monthly SIP Basket",
            subtitle: "Salary-based mutual fund allocation",
            holderName: "AMC Direct",
            investedAmount: 92000,
            currentValue: 101240,
            monthlyContribution: 8000,
            note: "Good for long-term wealth building and regular growth.",
            kind: .mutualFund
        ),
        InvestmentHolding(
            title: "Gold Reserve",
            subtitle: "Protected value for long-term saving",
            holderName: "Digital Gold",
            investedAmount: 48000,
            currentValue: 53640,
            monthlyContribution: 3000,
            note: "Useful as a reserve that should not count as spending.",
            kind: .gold
        )
    ]
}

struct InvestmentActivitySection: Identifiable {
    let id = UUID()
    let title: String
    let activities: [InvestmentActivity]

    static let sampleData: [InvestmentActivitySection] = [
        InvestmentActivitySection(
            title: "Today",
            activities: [
                InvestmentActivity(
                    title: "Family reserve contribution",
                    subtitle: "Transferred to father for long-term holding",
                    amount: 12000,
                    time: "09:20 AM",
                    badge: "Family",
                    kind: .invested
                ),
                InvestmentActivity(
                    title: "SIP auto allocation",
                    subtitle: "Salary split into monthly fund basket",
                    amount: 8000,
                    time: "08:10 AM",
                    badge: "SIP",
                    kind: .invested
                )
            ]
        ),
        InvestmentActivitySection(
            title: "Yesterday",
            activities: [
                InvestmentActivity(
                    title: "Gold reserve top-up",
                    subtitle: "Added more protected value from salary",
                    amount: 3000,
                    time: "Yesterday",
                    badge: "Gold",
                    kind: .invested
                ),
                InvestmentActivity(
                    title: "Family pool redemption",
                    subtitle: "Brought part of your asset back to wallet",
                    amount: 5000,
                    time: "Yesterday",
                    badge: "Redeem",
                    kind: .redeemed
                )
            ]
        ),
        InvestmentActivitySection(
            title: "Earlier",
            activities: [
                InvestmentActivity(
                    title: "Portfolio growth tracked",
                    subtitle: "Current value increased across your active assets",
                    amount: 7240,
                    time: "Sunday",
                    badge: "Growth",
                    kind: .growth
                )
            ]
        )
    ]
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

    var badgeTitle: String {
        switch self {
        case .week:
            return "This Week"
        case .month:
            return "April 2026"
        case .year:
            return "2026"
        }
    }

    var summaryTitle: String {
        switch self {
        case .week:
            return "Spent this week"
        case .month:
            return "Spent this April"
        case .year:
            return "Spent this year"
        }
    }

    var totalAmount: String {
        switch self {
        case .week:
            return "₹312.40"
        case .month:
            return "₹1,244.65"
        case .year:
            return "₹14,962.10"
        }
    }

    var supportingText: String {
        switch self {
        case .week:
            return "12 transactions"
        case .month:
            return "43 transactions"
        case .year:
            return "516 transactions"
        }
    }

    var chartBars: [InsightBar] {
        switch self {
        case .week:
            return [
                InsightBar(title: "Food", amount: "₹62.48", percentage: "20%", color: FinancePalette.royalBlue, fillRatio: 0.42),
                InsightBar(title: "Travel", amount: "₹124.96", percentage: "40%", color: FinancePalette.oceanBlue, fillRatio: 0.82),
                InsightBar(title: "Shop", amount: "₹56.23", percentage: "18%", color: FinancePalette.iceBlue, fillRatio: 0.38),
                InsightBar(title: "Bills", amount: "₹68.73", percentage: "22%", color: FinancePalette.sapphireBlue, fillRatio: 0.48)
            ]
        case .month:
            return [
                InsightBar(title: "Food", amount: "₹249.12", percentage: "20%", color: FinancePalette.royalBlue, fillRatio: 0.44),
                InsightBar(title: "Travel", amount: "₹149.28", percentage: "12%", color: FinancePalette.oceanBlue, fillRatio: 0.32),
                InsightBar(title: "Shop", amount: "₹348.25", percentage: "28%", color: FinancePalette.iceBlue, fillRatio: 0.58),
                InsightBar(title: "Bills", amount: "₹498.00", percentage: "40%", color: FinancePalette.sapphireBlue, fillRatio: 0.88)
            ]
        case .year:
            return [
                InsightBar(title: "Food", amount: "₹3,890", percentage: "26%", color: FinancePalette.royalBlue, fillRatio: 0.54),
                InsightBar(title: "Travel", amount: "₹2,693", percentage: "18%", color: FinancePalette.oceanBlue, fillRatio: 0.38),
                InsightBar(title: "Shop", amount: "₹3,142", percentage: "21%", color: FinancePalette.iceBlue, fillRatio: 0.46),
                InsightBar(title: "Bills", amount: "₹5,237", percentage: "35%", color: FinancePalette.sapphireBlue, fillRatio: 0.78)
            ]
        }
    }

    var categoryData: [InsightCategory] {
        switch self {
        case .week:
            return [
                InsightCategory(title: "Food", caption: "Dining", amount: "₹62.48", percentage: "20%", footnote: "4 payments", icon: "fork.knife", color: FinancePalette.royalBlue, backgroundTint: Color(red: 0.95, green: 0.97, blue: 1.0)),
                InsightCategory(title: "Travel", caption: "Transport", amount: "₹124.96", percentage: "40%", footnote: "3 payments", icon: "car.fill", color: FinancePalette.oceanBlue, backgroundTint: Color(red: 0.94, green: 0.98, blue: 1.0)),
                InsightCategory(title: "Shopping", caption: "Lifestyle", amount: "₹56.23", percentage: "18%", footnote: "2 payments", icon: "bag.fill", color: FinancePalette.iceBlue, backgroundTint: Color(red: 0.95, green: 0.98, blue: 1.0)),
                InsightCategory(title: "Bills", caption: "Utilities", amount: "₹68.73", percentage: "22%", footnote: "3 payments", icon: "doc.text.fill", color: FinancePalette.sapphireBlue, backgroundTint: Color(red: 0.94, green: 0.96, blue: 0.99))
            ]
        case .month:
            return [
                InsightCategory(title: "Food", caption: "Dining", amount: "₹249.12", percentage: "20%", footnote: "14 payments", icon: "fork.knife", color: FinancePalette.royalBlue, backgroundTint: Color(red: 0.95, green: 0.97, blue: 1.0)),
                InsightCategory(title: "Travel", caption: "Transport", amount: "₹149.28", percentage: "12%", footnote: "8 payments", icon: "car.fill", color: FinancePalette.oceanBlue, backgroundTint: Color(red: 0.94, green: 0.98, blue: 1.0)),
                InsightCategory(title: "Shopping", caption: "Lifestyle", amount: "₹348.25", percentage: "28%", footnote: "11 payments", icon: "bag.fill", color: FinancePalette.iceBlue, backgroundTint: Color(red: 0.95, green: 0.98, blue: 1.0)),
                InsightCategory(title: "Bills", caption: "Utilities", amount: "₹498.00", percentage: "40%", footnote: "10 payments", icon: "doc.text.fill", color: FinancePalette.sapphireBlue, backgroundTint: Color(red: 0.94, green: 0.96, blue: 0.99))
            ]
        case .year:
            return [
                InsightCategory(title: "Food", caption: "Dining", amount: "₹3,890", percentage: "26%", footnote: "136 payments", icon: "fork.knife", color: FinancePalette.royalBlue, backgroundTint: Color(red: 0.95, green: 0.97, blue: 1.0)),
                InsightCategory(title: "Travel", caption: "Transport", amount: "₹2,693", percentage: "18%", footnote: "92 payments", icon: "car.fill", color: FinancePalette.oceanBlue, backgroundTint: Color(red: 0.94, green: 0.98, blue: 1.0)),
                InsightCategory(title: "Shopping", caption: "Lifestyle", amount: "₹3,142", percentage: "21%", footnote: "108 payments", icon: "bag.fill", color: FinancePalette.iceBlue, backgroundTint: Color(red: 0.95, green: 0.98, blue: 1.0)),
                InsightCategory(title: "Bills", caption: "Utilities", amount: "₹5,237", percentage: "35%", footnote: "180 payments", icon: "doc.text.fill", color: FinancePalette.sapphireBlue, backgroundTint: Color(red: 0.94, green: 0.96, blue: 0.99))
            ]
        }
    }
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
