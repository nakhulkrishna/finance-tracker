import SwiftUI

struct DashboardHeader: View {
    let avatarText: String
    let title: String
    let subtitle: String
    let settingsAction: () -> Void
    let notificationAction: () -> Void

    init(
        avatarText: String = "FT",
        title: String,
        subtitle: String,
        settingsAction: @escaping () -> Void = {},
        notificationAction: @escaping () -> Void = {}
    ) {
        self.avatarText = avatarText
        self.title = title
        self.subtitle = subtitle
        self.settingsAction = settingsAction
        self.notificationAction = notificationAction
    }

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [FinancePalette.royalBlue, FinancePalette.oceanBlue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 48, height: 48)
                .overlay {
                    Text(avatarText)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)

                Text(subtitle)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(FinancePalette.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer()

            HeaderIconButton(symbol: "gearshape.fill", action: settingsAction)
            HeaderIconButton(symbol: "bell.fill", action: notificationAction)
        }
    }
}

struct HeaderIconButton: View {
    @Environment(\.colorScheme) private var colorScheme
    let symbol: String
    let action: () -> Void

    init(symbol: String, action: @escaping () -> Void = {}) {
        self.symbol = symbol
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(FinancePalette.royalBlue)
                .frame(width: 40, height: 40)
                .background(FinancePalette.cardBackground(for: colorScheme))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(FinancePalette.border(for: colorScheme), lineWidth: 1)
                )
                .shadow(color: FinancePalette.shadow(for: colorScheme), radius: 10, y: 8)
        }
        .buttonStyle(.plain)
    }
}

struct PrimaryActionButton: View {
    let title: String
    let symbol: String
    let fill: Color
    let foreground: Color
    let stroke: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Spacer(minLength: 0)

                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))

                Image(systemName: symbol)
                    .font(.system(size: 12, weight: .bold))

                Spacer(minLength: 0)
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(fill)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(stroke, lineWidth: stroke == .clear ? 0 : 1.2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(
                color: fill == .white ? FinancePalette.cardShadow.opacity(0.55) : FinancePalette.royalBlue.opacity(0.24),
                radius: 14,
                y: 10
            )
        }
        .buttonStyle(.plain)
    }
}

struct HomeSheetMiniStat: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.74))

            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
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

struct HomeSheetField: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let prefix: String?
    let placeholder: String
    @Binding var text: String

    init(
        title: String,
        prefix: String? = nil,
        placeholder: String = "",
        text: Binding<String>
    ) {
        self.title = title
        self.prefix = prefix
        self.placeholder = placeholder
        self._text = text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(FinancePalette.textSecondary)

            HStack(spacing: 8) {
                if let prefix {
                    Text(prefix)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(FinancePalette.royalBlue)
                }

                TextField(placeholder, text: $text)
                    .font(.system(size: prefix == nil ? 15 : 22, weight: .bold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)
                    .keyboardType(prefix == nil ? .default : .numberPad)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(FinancePalette.fieldBackground(for: colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(FinancePalette.border(for: colorScheme), lineWidth: 1)
            )
            .shadow(color: FinancePalette.shadow(for: colorScheme).opacity(0.34), radius: 12, y: 8)
        }
    }
}

struct HomeSheetDateField: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    @Binding var date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(FinancePalette.textSecondary)

            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(FinancePalette.softBlueBackground(for: colorScheme))
                        .frame(width: 40, height: 40)

                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(FinancePalette.royalBlue)
                }

                DatePicker(
                    "",
                    selection: $date,
                    in: ...Date(),
                    displayedComponents: [.date, .hourAndMinute]
                )
                .labelsHidden()
                .datePickerStyle(.compact)
                .tint(FinancePalette.royalBlue)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(FinancePalette.fieldBackground(for: colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(FinancePalette.border(for: colorScheme), lineWidth: 1)
            )
            .shadow(color: FinancePalette.shadow(for: colorScheme).opacity(0.34), radius: 12, y: 8)
        }
    }
}

struct HomeActionTagChip: View {
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(isSelected ? .white : accentColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    Group {
                        if isSelected {
                            LinearGradient(
                                colors: [accentColor, FinancePalette.oceanBlue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            FinancePalette.cardBackground(for: colorScheme)
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(isSelected ? Color.clear : FinancePalette.border(for: colorScheme), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct SettingsInfoRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            SettingsIconBadge(icon: icon, color: color)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(FinancePalette.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 10)

            Text(value)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
        }
        .padding(.vertical, 14)
    }
}

struct SettingsSelectionCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool
    let color: Color
    var trailingValue: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    SettingsIconBadge(icon: icon, color: color)

                    Spacer(minLength: 8)

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(color)
                    } else if let trailingValue {
                        Text(trailingValue)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(color)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(color.opacity(0.10))
                            .clipShape(Capsule())
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(FinancePalette.textPrimary)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(FinancePalette.textSecondary)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(FinancePalette.elevatedBackground(for: colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(isSelected ? color : FinancePalette.border(for: colorScheme), lineWidth: isSelected ? 1.5 : 1)
            )
            .shadow(color: FinancePalette.shadow(for: colorScheme).opacity(0.34), radius: 12, y: 8)
        }
        .buttonStyle(.plain)
    }
}

struct SettingsFeatureCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            SettingsIconBadge(icon: icon, color: color)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)

                Text(subtitle)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(FinancePalette.textSecondary)
            }

            Spacer(minLength: 0)
        }
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

struct SettingsSectionTitle: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 19, weight: .semibold, design: .rounded))
                .foregroundStyle(FinancePalette.textPrimary)

            Text(subtitle)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(FinancePalette.textSecondary)
                .lineLimit(1)
        }
    }
}

struct SettingsCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @ViewBuilder let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(FinancePalette.elevatedBackground(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(FinancePalette.border(for: colorScheme), lineWidth: 1)
        )
        .shadow(color: FinancePalette.shadow(for: colorScheme).opacity(0.42), radius: 16, y: 12)
    }
}

struct SettingsRowDivider: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Rectangle()
            .fill(FinancePalette.border(for: colorScheme))
            .frame(height: 1)
            .padding(.leading, 62)
    }
}

struct SettingsNavigationRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let value: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                SettingsIconBadge(icon: icon, color: color)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(FinancePalette.textPrimary)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(FinancePalette.textSecondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 10)

                Text(value)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                    .lineLimit(1)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(FinancePalette.textSecondary.opacity(0.7))
            }
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            SettingsIconBadge(icon: icon, color: color)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(FinancePalette.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 10)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(color)
        }
        .padding(.vertical, 14)
    }
}

struct SettingsIconBadge: View {
    let icon: String
    let color: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(color.opacity(0.12))
                .frame(width: 48, height: 48)

            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(color)
        }
    }
}

struct TransactionRow: View {
    @Environment(\.colorScheme) private var colorScheme
    let transaction: Transaction
    var onDelete: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            BrandBadge(transaction: transaction)

            VStack(alignment: .leading, spacing: 5) {
                Text(transaction.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(transaction.subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(FinancePalette.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .layoutPriority(1)

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(transaction.amount)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
                    .fixedSize(horizontal: true, vertical: false)

                Text(transaction.status)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(FinancePalette.royalBlue)
                    .lineLimit(1)
            }
            .frame(minWidth: 88, alignment: .trailing)

            if let onDelete {
                Menu {
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(FinancePalette.textSecondary)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(FinancePalette.cardBackground(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(FinancePalette.border(for: colorScheme), lineWidth: 1)
        )
        .shadow(color: FinancePalette.shadow(for: colorScheme), radius: 16, y: 10)
    }
}

struct BrandBadge: View {
    let transaction: Transaction

    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [transaction.brandColor.opacity(0.9), transaction.brandColor],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 50, height: 50)
            .overlay {
                Text(transaction.badgeText)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .shadow(color: transaction.brandColor.opacity(0.22), radius: 10, y: 7)
    }
}
