import SwiftUI

private enum InitialSetupStep: Int, CaseIterable, Identifiable {
    case account
    case investment
    case wallet

    var id: Int { rawValue }

    var numberTitle: String {
        "Step \(rawValue + 1)"
    }

    var shortTitle: String {
        switch self {
        case .account:
            return "Account"
        case .investment:
            return "Investments"
        case .wallet:
            return "Wallet"
        }
    }

    var buttonTitle: String {
        switch self {
        case .wallet:
            return "Finish Setup"
        default:
            return "Continue"
        }
    }
}

private enum InitialSetupField: Hashable {
    case accountAmount
    case familyHeldAmount
    case familyHeldHolder
    case sipAmount
    case goldAmount
    case fdAmount
    case walletAmount
}

struct InitialFinanceSetupFlowScreen: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var financeStore: FinanceStore

    @State private var currentStep: InitialSetupStep = .account
    @State private var openingBalanceAmount = ""
    @State private var familyHeldAmount = ""
    @State private var familyHeldHolder = ""
    @State private var sipAmount = ""
    @State private var goldAmount = ""
    @State private var fixedDepositAmount = ""
    @State private var walletAmount = ""
    @State private var errorMessage: String?
    @State private var isSubmitting = false
    @FocusState private var focusedField: InitialSetupField?

    private var investmentEntries: [InitialInvestmentSetupEntry] {
        [
            InitialInvestmentSetupEntry(
                amountText: familyHeldAmount,
                holder: familyHeldHolder,
                selectionTag: InvestmentHoldingKind.familyReserve.selectionTitle
            ),
            InitialInvestmentSetupEntry(
                amountText: sipAmount,
                holder: "",
                selectionTag: InvestmentHoldingKind.mutualFund.selectionTitle
            ),
            InitialInvestmentSetupEntry(
                amountText: goldAmount,
                holder: "",
                selectionTag: InvestmentHoldingKind.gold.selectionTitle
            ),
            InitialInvestmentSetupEntry(
                amountText: fixedDepositAmount,
                holder: "",
                selectionTag: InvestmentHoldingKind.fixedDeposit.selectionTitle
            )
        ]
    }

    private var totalOpeningInvestmentAmount: Double {
        investmentEntries.reduce(0) { partial, entry in
            partial + parsedCurrencyAmount(from: entry.amountText)
        }
    }

    private var enteredInvestmentCount: Int {
        investmentEntries.filter { parsedCurrencyAmount(from: $0.amountText) > 0 }.count
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                topHeader
                progressRow

                Group {
                    switch currentStep {
                    case .account:
                        AccountOpeningSetupPage(
                            amount: $openingBalanceAmount,
                            previewText: previewCurrencyText(from: openingBalanceAmount),
                            focusedField: _focusedField.projectedValue
                        )
                    case .investment:
                        ExistingInvestmentsSetupPage(
                            familyHeldAmount: $familyHeldAmount,
                            familyHeldHolder: $familyHeldHolder,
                            sipAmount: $sipAmount,
                            goldAmount: $goldAmount,
                            fixedDepositAmount: $fixedDepositAmount,
                            totalText: totalOpeningInvestmentAmount.currencyText,
                            selectedCount: enteredInvestmentCount,
                            focusedField: _focusedField.projectedValue
                        )
                    case .wallet:
                        WalletOpeningSetupPage(
                            amount: $walletAmount,
                            previewText: previewCurrencyText(from: walletAmount),
                            focusedField: _focusedField.projectedValue
                        )
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)))

                if let errorMessage {
                    InitialSetupStatusBanner(message: errorMessage)
                }

                privacyNote
                actionRow
            }
            .frame(maxWidth: 430)
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 40)
        }
        .scrollBounceBehavior(.basedOnSize)
        .animation(.smooth(duration: 0.24), value: currentStep)
        .onAppear(perform: seedExistingValuesIfNeeded)
        .onChange(of: currentStep) { _, _ in
            errorMessage = nil
        }
    }

    private var topHeader: some View {
        HStack(spacing: 14) {
            Image("ChatGPT Image Apr 10, 2026 at 11_08_54 AM")
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 56)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(FinancePalette.icyBlue, lineWidth: 1)
                )
                .shadow(color: FinancePalette.cardShadow.opacity(0.18), radius: 10, y: 6)

            VStack(alignment: .leading, spacing: 4) {
                Text("Complete Your Setup")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)

                Text("Hi \(authStore.currentUser?.firstName ?? "there"), add the balances you already have before entering the app.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(FinancePalette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var progressRow: some View {
        HStack(spacing: 10) {
            ForEach(InitialSetupStep.allCases) { step in
                InitialSetupProgressChip(step: step, currentStep: currentStep)
            }
        }
    }

    private var privacyNote: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(FinancePalette.royalBlue)
                .padding(.top, 1)

            Text("These opening values are saved to your Firebase account so the app starts with your real balances.")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(FinancePalette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 2)
    }

    private var actionRow: some View {
        HStack(spacing: 12) {
            if currentStep != .account {
                Button {
                    focusedField = nil
                    withAnimation(.smooth(duration: 0.24)) {
                        currentStep = InitialSetupStep(rawValue: currentStep.rawValue - 1) ?? .account
                    }
                } label: {
                    Text("Back")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(FinancePalette.royalBlue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(FinancePalette.icyBlue, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }

            Button(action: advance) {
                HStack(spacing: 10) {
                    if isSubmitting && currentStep == .wallet {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    } else {
                        Text(currentStep.buttonTitle)
                            .font(.system(size: 15, weight: .bold, design: .rounded))

                        Image(systemName: currentStep == .wallet ? "checkmark" : "arrow.right")
                            .font(.system(size: 13, weight: .bold))
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: [FinancePalette.royalBlue, FinancePalette.oceanBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: FinancePalette.royalBlue.opacity(0.18), radius: 12, y: 8)
            }
            .buttonStyle(.plain)
            .disabled(isSubmitting)
            .opacity(isSubmitting ? 0.9 : 1)
        }
    }

    private func advance() {
        focusedField = nil
        errorMessage = nil

        switch currentStep {
        case .account:
            withAnimation(.smooth(duration: 0.24)) {
                currentStep = .investment
            }
        case .investment:
            if let validationError = validateInvestmentStep() {
                errorMessage = validationError
            } else {
                withAnimation(.smooth(duration: 0.24)) {
                    currentStep = .wallet
                }
            }
        case .wallet:
            finishSetup()
        }
    }

    private func validateInvestmentStep() -> String? {
        if parsedCurrencyAmount(from: familyHeldAmount) > 0 &&
            familyHeldHolder.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Enter who is holding your family-held investment."
        }

        let allAmounts = [familyHeldAmount, sipAmount, goldAmount, fixedDepositAmount]
        for amount in allAmounts where !amount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            if parsedCurrencyAmount(from: amount) < 0 {
                return "Enter a valid opening investment amount."
            }
        }

        return nil
    }

    private func finishSetup() {
        guard !isSubmitting else { return }

        Task { @MainActor in
            isSubmitting = true

            let normalizedOpeningBalance = openingBalanceAmount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "0" : openingBalanceAmount

            if let homeError = financeStore.setOpeningBalance(amountText: normalizedOpeningBalance) {
                currentStep = .account
                errorMessage = homeError
                isSubmitting = false
                return
            }

            if let investmentError = financeStore.replaceInitialSetupInvestments(investmentEntries) {
                currentStep = .investment
                errorMessage = investmentError
                isSubmitting = false
                return
            }

            if let walletError = financeStore.seedInitialWalletBalance(amountText: walletAmount) {
                currentStep = .wallet
                errorMessage = walletError
                isSubmitting = false
                return
            }

            if let completionError = await authStore.completeInitialFinanceSetup() {
                errorMessage = completionError
                isSubmitting = false
                return
            }

            isSubmitting = false
        }
    }

    private func seedExistingValuesIfNeeded() {
        guard openingBalanceAmount.isEmpty,
              familyHeldAmount.isEmpty,
              familyHeldHolder.isEmpty,
              sipAmount.isEmpty,
              goldAmount.isEmpty,
              fixedDepositAmount.isEmpty,
              walletAmount.isEmpty else {
            return
        }

        if financeStore.openingBalance > 0 {
            openingBalanceAmount = inputAmountText(for: financeStore.openingBalance)
        }

        for record in financeStore.investmentRecords where record.isSetupSeed {
            switch record.assetKind {
            case .familyReserve:
                familyHeldAmount = inputAmountText(for: record.amount)
                familyHeldHolder = record.counterparty
            case .mutualFund:
                sipAmount = inputAmountText(for: record.amount)
            case .gold:
                goldAmount = inputAmountText(for: record.amount)
            case .fixedDeposit:
                fixedDepositAmount = inputAmountText(for: record.amount)
            }
        }

        if let setupWallet = financeStore.walletRecords.first(where: { $0.isSetupSeed }) {
            walletAmount = inputAmountText(for: setupWallet.amount)
        }
    }

    private func parsedCurrencyAmount(from value: String) -> Double {
        let cleanValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanValue.isEmpty else { return 0 }
        let normalizedValue = cleanValue.replacingOccurrences(of: ",", with: "")
        return Double(normalizedValue) ?? -1
    }

    private func previewCurrencyText(from value: String) -> String {
        let amount = parsedCurrencyAmount(from: value)
        guard amount >= 0 else { return "₹0.00" }
        return amount.currencyText
    }

    private func inputAmountText(for value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_IN")
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = value.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.0f", value)
    }
}

private struct AccountOpeningSetupPage: View {
    @Binding var amount: String
    let previewText: String
    let focusedField: FocusState<InitialSetupField?>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            InitialSetupPageHeaderCard(
                stepTitle: "Step 1",
                title: "Opening Account Balance",
                subtitle: "Set the bank or card balance you already have before starting with Finance Tracker.",
                symbol: "building.columns.fill",
                summary: "Preview balance: \(previewText)"
            )

            InitialSetupContentCard {
                VStack(alignment: .leading, spacing: 14) {
                    InitialSetupAmountField(
                        title: "Account Balance",
                        placeholder: "85,000",
                        text: $amount
                    )
                    .focused(focusedField, equals: .accountAmount)

                    Text("Leave this empty if you want to start from zero.")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(FinancePalette.textSecondary)
                }
            }
        }
    }
}

private struct ExistingInvestmentsSetupPage: View {
    @Binding var familyHeldAmount: String
    @Binding var familyHeldHolder: String
    @Binding var sipAmount: String
    @Binding var goldAmount: String
    @Binding var fixedDepositAmount: String
    let totalText: String
    let selectedCount: Int
    let focusedField: FocusState<InitialSetupField?>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            InitialSetupPageHeaderCard(
                stepTitle: "Step 2",
                title: "Existing Investments",
                subtitle: "Add each asset separately so your app starts with the right investment picture.",
                symbol: "chart.line.uptrend.xyaxis.circle.fill",
                summary: "\(selectedCount) assets selected • \(totalText)"
            )

            InitialSetupContentCard {
                VStack(alignment: .leading, spacing: 12) {
                    InitialInvestmentEntryCard(
                        title: "Family Hold",
                        subtitle: "Money held by father or family",
                        icon: "person.2.fill",
                        accentColor: FinancePalette.royalBlue,
                        amount: $familyHeldAmount,
                        holder: $familyHeldHolder,
                        focusedField: focusedField,
                        amountField: .familyHeldAmount,
                        holderField: .familyHeldHolder,
                        showsHolder: true
                    )

                    InitialInvestmentEntryCard(
                        title: "SIP",
                        subtitle: "Existing SIP amount",
                        icon: "chart.line.uptrend.xyaxis",
                        accentColor: FinancePalette.oceanBlue,
                        amount: $sipAmount,
                        holder: .constant(""),
                        focusedField: focusedField,
                        amountField: .sipAmount,
                        holderField: nil,
                        showsHolder: false
                    )

                    InitialInvestmentEntryCard(
                        title: "Gold",
                        subtitle: "Gold value",
                        icon: "seal.fill",
                        accentColor: FinancePalette.sapphireBlue,
                        amount: $goldAmount,
                        holder: .constant(""),
                        focusedField: focusedField,
                        amountField: .goldAmount,
                        holderField: nil,
                        showsHolder: false
                    )

                    InitialInvestmentEntryCard(
                        title: "FD",
                        subtitle: "Fixed deposit amount",
                        icon: "building.columns.fill",
                        accentColor: FinancePalette.iceBlue,
                        amount: $fixedDepositAmount,
                        holder: .constant(""),
                        focusedField: focusedField,
                        amountField: .fdAmount,
                        holderField: nil,
                        showsHolder: false
                    )

                    Text("These values are saved as existing assets and do not reduce your Home balance.")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(FinancePalette.textSecondary)
                }
            }
        }
    }
}

private struct WalletOpeningSetupPage: View {
    @Binding var amount: String
    let previewText: String
    let focusedField: FocusState<InitialSetupField?>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            InitialSetupPageHeaderCard(
                stepTitle: "Step 3",
                title: "Liquid Wallet Balance",
                subtitle: "Set the cash or liquid money you already keep outside your bank account.",
                symbol: "wallet.pass.fill",
                summary: "Wallet amount: \(previewText)"
            )

            InitialSetupContentCard {
                VStack(alignment: .leading, spacing: 14) {
                    InitialSetupAmountField(
                        title: "Wallet Balance",
                        placeholder: "3,500",
                        text: $amount
                    )
                    .focused(focusedField, equals: .walletAmount)

                    Text("This stays separate from your Home account balance.")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(FinancePalette.textSecondary)
                }
            }
        }
    }
}

private struct InitialSetupPageHeaderCard: View {
    let stepTitle: String
    let title: String
    let subtitle: String
    let symbol: String
    let summary: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(FinancePalette.paleBlue)
                        .frame(width: 50, height: 50)

                    Image(systemName: symbol)
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(FinancePalette.royalBlue)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(stepTitle)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(FinancePalette.royalBlue)

                    Text(title)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(FinancePalette.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(FinancePalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Text(summary)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(FinancePalette.textSecondary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.96))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(FinancePalette.icyBlue.opacity(0.95), lineWidth: 1)
        )
        .shadow(color: FinancePalette.cardShadow.opacity(0.12), radius: 10, y: 6)
    }
}

private struct InitialSetupContentCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.96))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(FinancePalette.icyBlue.opacity(0.95), lineWidth: 1)
            )
            .shadow(color: FinancePalette.cardShadow.opacity(0.10), radius: 8, y: 5)
    }
}

private struct InitialSetupAmountField: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(FinancePalette.textSecondary)

            HStack(spacing: 10) {
                Text("₹")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(FinancePalette.royalBlue)

                TextField(placeholder, text: $text)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)
                    .keyboardType(.numberPad)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(FinancePalette.mistBlue.opacity(0.82))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(FinancePalette.icyBlue.opacity(0.9), lineWidth: 1)
            )
        }
    }
}

private struct InitialSetupTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let symbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(FinancePalette.textSecondary)

            HStack(spacing: 12) {
                Image(systemName: symbol)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(FinancePalette.royalBlue)
                    .frame(width: 18)

                TextField(placeholder, text: $text)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(FinancePalette.mistBlue.opacity(0.82))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(FinancePalette.icyBlue.opacity(0.9), lineWidth: 1)
            )
        }
    }
}

private struct InitialInvestmentEntryCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    @Binding var amount: String
    @Binding var holder: String
    let focusedField: FocusState<InitialSetupField?>.Binding
    let amountField: InitialSetupField
    let holderField: InitialSetupField?
    let showsHolder: Bool

    private var previewAmount: String {
        let cleanValue = amount.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanValue.isEmpty else { return "₹0.00" }
        let normalizedValue = cleanValue.replacingOccurrences(of: ",", with: "")
        guard let value = Double(normalizedValue) else { return "₹0.00" }
        return value.currencyText
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(accentColor.opacity(0.10))
                        .frame(width: 38, height: 38)

                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(accentColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(FinancePalette.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(FinancePalette.textSecondary)
                }

                Spacer()

                Text(previewAmount)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(accentColor)
            }

            InitialSetupAmountField(title: "Amount", placeholder: "0", text: $amount)
                .focused(focusedField, equals: amountField)

            if showsHolder, let holderField {
                InitialSetupTextField(
                    title: "Held By",
                    placeholder: "Father / Family",
                    text: $holder,
                    symbol: "person.2.fill"
                )
                .focused(focusedField, equals: holderField)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(FinancePalette.icyBlue.opacity(0.88), lineWidth: 1)
        )
    }
}

private struct InitialSetupProgressChip: View {
    let step: InitialSetupStep
    let currentStep: InitialSetupStep

    private var isCurrent: Bool {
        step == currentStep
    }

    private var isCompleted: Bool {
        step.rawValue < currentStep.rawValue
    }

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(isCurrent || isCompleted ? FinancePalette.royalBlue : FinancePalette.icyBlue)
                .frame(width: 22, height: 22)
                .overlay {
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    } else {
                        Text("\(step.rawValue + 1)")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(isCurrent ? .white : FinancePalette.textSecondary)
                    }
                }

            Text(step.shortTitle)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(isCurrent ? FinancePalette.royalBlue : FinancePalette.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(isCurrent ? FinancePalette.paleBlue : Color.white.opacity(0.82))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(isCurrent ? FinancePalette.icyBlue : Color.clear, lineWidth: 1)
        )
    }
}

private struct InitialSetupStatusBanner: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color(red: 0.86, green: 0.23, blue: 0.28))

            Text(message)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(red: 0.56, green: 0.20, blue: 0.24))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 1.0, green: 0.95, blue: 0.96))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
