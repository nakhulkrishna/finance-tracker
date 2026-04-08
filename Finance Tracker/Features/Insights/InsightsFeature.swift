import SwiftUI

struct InsightsScreen: View {
    @State private var selectedRange: InsightRange = .month
    @State private var hasAnimatedIn = false
    @Namespace private var rangePickerAnimation

    private let categoryColumns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    private var chartBars: [InsightBar] {
        selectedRange.chartBars
    }

    private var categories: [InsightCategory] {
        selectedRange.categoryData
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
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(selectedRange.summaryTitle)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(FinancePalette.textSecondary)
                        .contentTransition(.opacity)

                    Text(selectedRange.totalAmount)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(FinancePalette.textPrimary)
                        .contentTransition(.numericText())

                    Text(selectedRange.supportingText)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(FinancePalette.royalBlue)
                        .contentTransition(.opacity)
                }

                Spacer(minLength: 12)

                Text(selectedRange.badgeTitle)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(FinancePalette.royalBlue)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(FinancePalette.paleBlue)
                    .clipShape(Capsule())
            }

            InsightBarChart(bars: chartBars)
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white, FinancePalette.mistBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(FinancePalette.icyBlue.opacity(0.95), lineWidth: 1)
        )
        .shadow(color: FinancePalette.cardShadow.opacity(1.05), radius: 22, y: 14)
    }

    private var rangePicker: some View {
        HStack(spacing: 28) {
            ForEach(InsightRange.allCases) { range in
                Button(action: {
                    withAnimation(.spring(response: 0.48, dampingFraction: 0.86)) {
                        selectedRange = range
                    }
                }) {
                    VStack(spacing: 9) {
                        Text(range.displayTitle)
                            .font(.system(size: 14, weight: selectedRange == range ? .bold : .semibold, design: .rounded))
                            .foregroundStyle(selectedRange == range ? FinancePalette.textPrimary : FinancePalette.textSecondary)

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
                    .background(FinancePalette.paleBlue)
                    .clipShape(Capsule())
            }

            LazyVGrid(columns: categoryColumns, spacing: 16) {
                ForEach(categories) { category in
                    InsightCategoryCard(category: category)
                }
            }
        }
        .padding(.top, 6)
        .animation(.spring(response: 0.50, dampingFraction: 0.88), value: selectedRange)
    }
}

struct InsightsNotificationsScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedFilter: InsightNotificationFilter = .all
    private let sections = InsightNotificationSection.sampleData

    private var filteredSections: [InsightNotificationSection] {
        sections.compactMap { section in
            let notifications = section.notifications.filter { notification in
                selectedFilter.matches(notification)
            }

            guard !notifications.isEmpty else { return nil }
            return InsightNotificationSection(title: section.title, notifications: notifications)
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
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(FinancePalette.icyBlue, lineWidth: 1)
                    )
                    .shadow(color: FinancePalette.cardShadow.opacity(0.45), radius: 12, y: 8)
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

    private var notificationList: some View {
        VStack(alignment: .leading, spacing: 16) {
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

    static let sampleData: [InsightNotificationSection] = [
        InsightNotificationSection(
            title: "Today",
            notifications: [
                InsightNotification(
                    title: "Food spending is rising",
                    subtitle: "You spent 18% more on food than your weekly average.",
                    detail: "Dining has become your most active category today.",
                    time: "2 min ago",
                    badge: "Food",
                    kind: .spending,
                    isUnread: true
                ),
                InsightNotification(
                    title: "Monthly budget is 68% used",
                    subtitle: "Your tracked monthly spend is now moving into the final third.",
                    detail: "Bills and shopping are the largest contributors so far.",
                    time: "18 min ago",
                    badge: "Month",
                    kind: .trend,
                    isUnread: true
                )
            ]
        ),
        InsightNotificationSection(
            title: "Yesterday",
            notifications: [
                InsightNotification(
                    title: "Bills remain your top category",
                    subtitle: "Bills make up 40% of this month's total spending.",
                    detail: "Utilities continue to lead over shopping and food.",
                    time: "Yesterday",
                    badge: "Bills",
                    kind: .trend,
                    isUnread: false
                ),
                InsightNotification(
                    title: "Wallet top-up pattern noticed",
                    subtitle: "You added money more than once this week.",
                    detail: "A single larger top-up may keep your wallet flow cleaner.",
                    time: "Yesterday",
                    badge: "Wallet",
                    kind: .reminder,
                    isUnread: false
                )
            ]
        ),
        InsightNotificationSection(
            title: "Earlier",
            notifications: [
                InsightNotification(
                    title: "Travel expense cooled down",
                    subtitle: "Travel spend dropped 24% compared with the previous week.",
                    detail: "Your commute costs are looking lighter this cycle.",
                    time: "Monday",
                    badge: "Travel",
                    kind: .spending,
                    isUnread: false
                ),
                InsightNotification(
                    title: "Review your weekly insights",
                    subtitle: "A fresh summary is ready based on your latest entries.",
                    detail: "Open Insights to see category movement and changes.",
                    time: "Sunday",
                    badge: "Insights",
                    kind: .reminder,
                    isUnread: false
                )
            ]
        )
    ]
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
    let time: String
    let badge: String
    let kind: Kind
    let isUnread: Bool
}

private struct InsightNotificationCard: View {
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
                .fill(
                    LinearGradient(
                        colors: [Color.white, FinancePalette.mistBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(FinancePalette.icyBlue.opacity(0.96), lineWidth: 1)
        )
        .shadow(color: FinancePalette.cardShadow.opacity(0.36), radius: 14, y: 10)
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
                    .fill(FinancePalette.paleBlue)
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
    let label: String
    let color: Color

    var body: some View {
        Text(label)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(FinancePalette.textPrimary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.96))
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.16), lineWidth: 1)
            )
            .clipShape(Capsule())
            .shadow(color: FinancePalette.cardShadow.opacity(0.78), radius: 10, y: 8)
    }
}

private struct InsightCategoryCard: View {
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
                    .background(Color.white.opacity(0.96))
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
                    .fill(Color.white.opacity(0.98))

                Circle()
                    .fill(category.color.opacity(0.08))
                    .frame(width: 104, height: 104)
                    .blur(radius: 12)
                    .offset(x: 54, y: -46)

                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white, category.backgroundTint],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(0.92)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(FinancePalette.icyBlue.opacity(0.95), lineWidth: 1)
        )
        .shadow(color: FinancePalette.cardShadow.opacity(0.58), radius: 18, y: 12)
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
