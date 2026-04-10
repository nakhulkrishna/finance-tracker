import Foundation
import SwiftUI

struct InsightsScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var financeStore: FinanceStore
    @EnvironmentObject private var premiumStore: PremiumStore
    @State private var selectedRange: InsightRange = .month
    @State private var hasAnimatedIn = false
    @State private var isShowingPremium = false
    @Namespace private var rangePickerAnimation

    private let categoryColumns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    private var snapshot: InsightSnapshot {
        financeStore.insightSnapshot(for: selectedRange)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                chartSection
                    .opacity(hasAnimatedIn ? 1 : 0)
                    .offset(y: hasAnimatedIn ? 0 : 18)
                    .animation(.spring(response: 0.62, dampingFraction: 0.88), value: hasAnimatedIn)

                rangePicker
                    .opacity(hasAnimatedIn ? 1 : 0)
                    .offset(y: hasAnimatedIn ? 0 : 14)
                    .animation(.spring(response: 0.60, dampingFraction: 0.90).delay(0.05), value: hasAnimatedIn)

                categoriesSection
                    .opacity(hasAnimatedIn ? 1 : 0)
                    .offset(y: hasAnimatedIn ? 0 : 20)
                    .animation(.spring(response: 0.70, dampingFraction: 0.90).delay(0.10), value: hasAnimatedIn)
            }
            .frame(maxWidth: 430)
            .padding(.horizontal, 20)
            .padding(.top, 28)
            .padding(.bottom, 120)
        }
        .onAppear {
            guard !hasAnimatedIn else { return }
            hasAnimatedIn = true
        }
        .onChange(of: premiumStore.isPremium) { _, isPremium in
            if !isPremium && selectedRange == .year {
                selectedRange = .month
            }
        }
        .sheet(isPresented: $isShowingPremium) {
            PremiumSubscriptionScreen()
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(snapshot.summaryTitle)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(FinancePalette.textSecondary)
                        .contentTransition(.opacity)

                    Text(snapshot.totalAmount)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(FinancePalette.textPrimary)
                        .contentTransition(.numericText())

                    Text(snapshot.supportingText)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(FinancePalette.royalBlue)
                        .contentTransition(.opacity)
                }

                Spacer(minLength: 12)

                Text(snapshot.badgeTitle)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(FinancePalette.royalBlue)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(FinancePalette.softBlueBackground(for: colorScheme))
                    .clipShape(Capsule())
            }

            InsightBarChart(bars: snapshot.chartBars)
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(FinancePalette.elevatedBackground(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(FinancePalette.border(for: colorScheme), lineWidth: 1)
        )
        .shadow(color: FinancePalette.shadow(for: colorScheme).opacity(1.05), radius: 22, y: 14)
    }

    private var rangePicker: some View {
        HStack(spacing: 28) {
                ForEach(InsightRange.allCases) { range in
                    Button(action: {
                        if range == .year && !premiumStore.hasAccess(to: .yearlyInsights) {
                            isShowingPremium = true
                            return
                        }

                        withAnimation(.spring(response: 0.48, dampingFraction: 0.86)) {
                            selectedRange = range
                        }
                    }) {
                    VStack(spacing: 9) {
                        HStack(spacing: 5) {
                            Text(range.displayTitle)
                                .font(.system(size: 14, weight: selectedRange == range ? .bold : .semibold, design: .rounded))
                                .foregroundStyle(selectedRange == range ? FinancePalette.textPrimary : FinancePalette.textSecondary)

                            if range == .year && !premiumStore.hasAccess(to: .yearlyInsights) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(FinancePalette.royalBlue)
                            }
                        }

                        ZStack {
                            Capsule()
                                .fill(Color.clear)
                                .frame(width: 24, height: 3)

                            if selectedRange == range {
                                Capsule()
                                    .fill(FinancePalette.royalBlue)
                                    .frame(width: 24, height: 3)
                                    .matchedGeometryEffect(id: "range-indicator", in: rangePickerAnimation)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 2)
        .animation(.spring(response: 0.42, dampingFraction: 0.86), value: selectedRange)
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Spending Categories")
                        .font(.system(size: 21, weight: .semibold, design: .rounded))
                        .foregroundStyle(FinancePalette.textPrimary)

                    Text("Clear breakdown of where your money went")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(FinancePalette.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Text(selectedRange.displayTitle)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(FinancePalette.royalBlue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(FinancePalette.softBlueBackground(for: colorScheme))
                    .clipShape(Capsule())
            }

            LazyVGrid(columns: categoryColumns, spacing: 16) {
                ForEach(snapshot.categories) { category in
                    InsightCategoryCard(category: category)
                }
            }
        }
        .padding(.top, 6)
        .animation(.spring(response: 0.50, dampingFraction: 0.88), value: selectedRange)
    }
}

struct InsightsNotificationsScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var financeStore: FinanceStore

    @State private var selectedFilter: InsightNotificationFilter = .all

    private var allNotifications: [InsightNotification] {
        var notifications: [InsightNotification] = []
        let now = Date()

        let monthlyPayments = financeStore.operations.filter { record in
            record.kind == .payment && Calendar.current.isDate(record.createdAt, equalTo: now, toGranularity: .month)
        }
        let todayPayments = monthlyPayments.filter { Calendar.current.isDateInToday($0.createdAt) }

        if financeStore.todaySpend > 0 {
            notifications.append(
                InsightNotification(
                    title: "Today's spending updated",
                    subtitle: "You spent \(financeStore.todaySpend.currencyText) across \(financeStore.todayTransactionCount) entry\(financeStore.todayTransactionCount == 1 ? "" : "ies").",
                    detail: todayPayments.first.map {
                        "Latest payment was \($0.title) under \($0.category)."
                    } ?? "Your spending dashboard has fresh totals for today.",
                    createdAt: todayPayments.first?.createdAt ?? now,
                    badge: "Today",
                    kind: .spending
                )
            )
        }

        if financeStore.monthlySpend > 0 {
            let topCategory = monthlyPayments
                .reduce(into: [String: Double]()) { partial, record in
                    partial[record.category, default: 0] += record.amount
                }
                .max(by: { $0.value < $1.value })?
                .key ?? "Spending"

            notifications.append(
                InsightNotification(
                    title: "Monthly trend refreshed",
                    subtitle: "This month you have logged \(financeStore.monthlySpend.currencyText) in payments.",
                    detail: "\(topCategory) is currently the largest spending category in your tracker.",
                    createdAt: monthlyPayments.first?.createdAt ?? now.addingTimeInterval(-3600),
                    badge: "Month",
                    kind: .trend
                )
            )
        }

        if let latestWalletRecord = financeStore.walletRecords.first {
            notifications.append(
                InsightNotification(
                    title: "Wallet activity changed",
                    subtitle: "Liquid wallet balance is now \(financeStore.walletBalance.currencyText).",
                    detail: "Latest wallet entry was \(latestWalletRecord.title) under \(latestWalletRecord.category).",
                    createdAt: latestWalletRecord.createdAt,
                    badge: "Wallet",
                    kind: .reminder
                )
            )
        }

        if let latestInvestmentRecord = financeStore.investmentRecords.first, financeStore.totalInvestmentBalance > 0 {
            notifications.append(
                InsightNotification(
                    title: "Assets are being tracked",
                    subtitle: "Investment value is \(financeStore.totalInvestmentBalance.currencyText) across \(financeStore.activeInvestmentCount) active holding\(financeStore.activeInvestmentCount == 1 ? "" : "s").",
                    detail: "Latest investment update was in \(latestInvestmentRecord.assetKind.badgeTitle) with \(latestInvestmentRecord.counterparty).",
                    createdAt: latestInvestmentRecord.createdAt,
                    badge: latestInvestmentRecord.assetKind.badgeTitle,
                    kind: .trend
                )
            )
        }

        if notifications.isEmpty, financeStore.availableBalance > 0 || financeStore.openingBalance > 0 {
            notifications.append(
                InsightNotification(
                    title: "Your account is ready",
                    subtitle: "Start adding payments, wallet activity, or investments to generate insights here.",
                    detail: "This inbox stays dynamic and updates from your real finance activity only.",
                    createdAt: now,
                    badge: "Ready",
                    kind: .reminder
                )
            )
        }

        return notifications.sorted { $0.createdAt > $1.createdAt }
    }

    private var filteredSections: [InsightNotificationSection] {
        let filteredNotifications = allNotifications.filter { selectedFilter.matches($0) }
        let groupedNotifications = Dictionary(grouping: filteredNotifications) { notificationBucketTitle(for: $0.createdAt) }
        let orderedTitles = ["Today", "Yesterday", "Earlier"]

        return orderedTitles.compactMap { title in
            guard let notifications = groupedNotifications[title], !notifications.isEmpty else { return nil }
            return InsightNotificationSection(
                title: title,
                notifications: notifications.sorted { $0.createdAt > $1.createdAt }
            )
        }
    }

    private var unreadCount: Int {
        filteredSections
            .flatMap(\.notifications)
            .filter(\.isUnread)
            .count
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    heroCard
                    filtersRow
                    notificationList
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
                Text("Notifications")
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)

                Text("Local insights only, no FCM or push service")
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
                    .background(FinancePalette.cardBackground(for: colorScheme))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(FinancePalette.border(for: colorScheme), lineWidth: 1)
                    )
                    .shadow(color: FinancePalette.shadow(for: colorScheme).opacity(0.45), radius: 12, y: 8)
            }
            .buttonStyle(.plain)
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Insight Inbox")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.76))

                    Text("\(unreadCount) unread")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())

                    Text("Generated inside the app from your balances, wallet activity, and spending trends.")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.78))
                }

                Spacer()

                Text("In-App Only")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(FinancePalette.navyBlue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.92))
                    .clipShape(Capsule())
            }

            HStack(spacing: 12) {
                HomeSheetMiniStat(title: "Source", value: "Insights")
                HomeSheetMiniStat(title: "Delivery", value: "Local")
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
                ForEach(InsightNotificationFilter.allCases) { filter in
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

    private var notificationList: some View {
        VStack(alignment: .leading, spacing: 16) {
            if filteredSections.isEmpty {
                EmptyInsightNotificationsCard()
            } else {
                ForEach(filteredSections) { section in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(section.title)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(FinancePalette.textSecondary)

                        ForEach(section.notifications) { notification in
                            InsightNotificationCard(notification: notification)
                        }
                    }
                }
            }
        }
    }

    private func notificationBucketTitle(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        }

        if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        }

        return "Earlier"
    }
}

private enum InsightNotificationFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case spending = "Spending"
    case trends = "Trends"
    case reminders = "Reminders"

    var id: String { rawValue }

    func matches(_ notification: InsightNotification) -> Bool {
        switch self {
        case .all:
            return true
        case .spending:
            return notification.kind == .spending
        case .trends:
            return notification.kind == .trend
        case .reminders:
            return notification.kind == .reminder
        }
    }
}

private struct InsightNotificationSection: Identifiable {
    let id = UUID()
    let title: String
    let notifications: [InsightNotification]
}

private struct InsightNotification: Identifiable {
    enum Kind {
        case spending
        case trend
        case reminder

        var icon: String {
            switch self {
            case .spending:
                return "indianrupeesign.circle.fill"
            case .trend:
                return "chart.line.uptrend.xyaxis.circle.fill"
            case .reminder:
                return "bell.badge.fill"
            }
        }

        var color: Color {
            switch self {
            case .spending:
                return FinancePalette.royalBlue
            case .trend:
                return FinancePalette.oceanBlue
            case .reminder:
                return FinancePalette.sapphireBlue
            }
        }
    }

    let id = UUID()
    let title: String
    let subtitle: String
    let detail: String
    let createdAt: Date
    let badge: String
    let kind: Kind

    var time: String {
        notificationRelativeTimeFormatter.localizedString(for: createdAt, relativeTo: .now)
    }

    var isUnread: Bool {
        Date().timeIntervalSince(createdAt) < 43_200
    }
}

private struct InsightNotificationCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let notification: InsightNotification

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                SettingsIconBadge(
                    icon: notification.kind.icon,
                    color: notification.kind.color
                )

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(notification.title)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(FinancePalette.textPrimary)
                            .lineLimit(1)

                        if notification.isUnread {
                            Circle()
                                .fill(notification.kind.color)
                                .frame(width: 8, height: 8)
                        }
                    }

                    Text(notification.subtitle)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(FinancePalette.textSecondary)
                }

                Spacer(minLength: 8)

                Text(notification.time)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(FinancePalette.textSecondary)
            }

            Text(notification.detail)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(FinancePalette.textSecondary)

            HStack {
                Text(notification.badge)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(notification.kind.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(notification.kind.color.opacity(0.10))
                    .clipShape(Capsule())

                Spacer()

                Text("Local insight")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(FinancePalette.textSecondary)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(FinancePalette.elevatedBackground(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(FinancePalette.border(for: colorScheme), lineWidth: 1)
        )
        .shadow(color: FinancePalette.shadow(for: colorScheme).opacity(0.36), radius: 14, y: 10)
    }
}

private struct EmptyInsightNotificationsCard: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("No insight notifications yet")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(FinancePalette.textPrimary)

            Text("Once you add real transactions, wallet logs, or investments, this inbox will show live insight updates.")
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
        .shadow(color: FinancePalette.shadow(for: colorScheme).opacity(0.32), radius: 12, y: 8)
    }
}

private struct InsightBarChart: View {
    let bars: [InsightBar]

    var body: some View {
        HStack(alignment: .bottom, spacing: 14) {
            ForEach(Array(bars.enumerated()), id: \.element.id) { index, bar in
                InsightBarColumn(bar: bar, index: index)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 250, alignment: .bottom)
        .padding(.horizontal, 2)
        .padding(.top, 8)
    }
}

private struct InsightBarColumn: View {
    @Environment(\.colorScheme) private var colorScheme
    let bar: InsightBar
    let index: Int
    @State private var animateIn = false

    var body: some View {
        VStack(spacing: 12) {
            PercentageBadge(label: bar.percentage, color: bar.color)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 10)

            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(FinancePalette.softBlueBackground(for: colorScheme))
                    .frame(width: 60, height: 164)

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [bar.color.opacity(0.78), bar.color],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 60, height: max(36, 164 * (animateIn ? bar.fillRatio : 0.10)))
                    .overlay(alignment: .top) {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.18))
                            .frame(width: 60, height: 24)
                            .blur(radius: 8)
                            .offset(y: -4)
                    }
                    .shadow(color: bar.color.opacity(0.22), radius: 12, y: 8)
            }

            VStack(spacing: 4) {
                Text(bar.title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)
                    .lineLimit(1)

                Text(bar.amount)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(FinancePalette.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            guard !animateIn else { return }
            withAnimation(.spring(response: 0.70, dampingFraction: 0.84).delay(Double(index) * 0.05)) {
                animateIn = true
            }
        }
        .animation(.spring(response: 0.52, dampingFraction: 0.84), value: bar.fillRatio)
        .animation(.spring(response: 0.45, dampingFraction: 0.88), value: bar.amount)
    }
}

private struct PercentageBadge: View {
    @Environment(\.colorScheme) private var colorScheme
    let label: String
    let color: Color

    var body: some View {
        Text(label)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(FinancePalette.textPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(FinancePalette.elevatedBackground(for: colorScheme))
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.16), lineWidth: 1)
            )
            .clipShape(Capsule())
            .shadow(color: FinancePalette.shadow(for: colorScheme).opacity(0.78), radius: 10, y: 8)
    }
}

private struct InsightCategoryCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let category: InsightCategory
    @State private var animateIn = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [category.color.opacity(0.16), category.color.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)

                    Image(systemName: category.icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(category.color)
                }

                Spacer(minLength: 0)

                Text(category.percentage)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(category.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(FinancePalette.elevatedBackground(for: colorScheme))
                    .overlay(
                        Capsule()
                            .stroke(category.color.opacity(0.18), lineWidth: 1)
                    )
                    .clipShape(Capsule())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(category.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)
                    .lineLimit(1)

                Text(category.caption)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(FinancePalette.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 6) {
                Text(category.amount)
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)
                    .lineLimit(1)
                    .contentTransition(.numericText())

                Text(category.footnote)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(FinancePalette.textSecondary)
                    .lineLimit(1)
            }

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [category.color.opacity(0.65), category.color],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 38, height: 6)
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 168, alignment: .leading)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(FinancePalette.elevatedBackground(for: colorScheme))

                Circle()
                    .fill(category.color.opacity(0.08))
                    .frame(width: 104, height: 104)
                    .blur(radius: 12)
                    .offset(x: 54, y: -46)

                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                FinancePalette.elevatedBackground(for: colorScheme),
                                colorScheme == .dark ? category.color.opacity(0.18) : category.backgroundTint
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(0.92)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(FinancePalette.border(for: colorScheme), lineWidth: 1)
        )
        .shadow(color: FinancePalette.shadow(for: colorScheme).opacity(0.58), radius: 18, y: 12)
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 12)
        .scaleEffect(animateIn ? 1 : 0.98)
        .onAppear {
            guard !animateIn else { return }
            withAnimation(.spring(response: 0.66, dampingFraction: 0.88)) {
                animateIn = true
            }
        }
        .animation(.spring(response: 0.48, dampingFraction: 0.88), value: category.amount)
    }
}

private let notificationRelativeTimeFormatter: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .short
    return formatter
}()
