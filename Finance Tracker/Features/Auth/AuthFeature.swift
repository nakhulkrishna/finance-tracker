import SwiftUI

private enum AuthMode: String, CaseIterable, Identifiable {
    case login = "Login"
    case register = "Register"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .login:
            return "Welcome back"
        case .register:
            return "Create your account"
        }
    }

    var subtitle: String {
        switch self {
        case .login:
            return "Track salary, spending, wallet cash, and investments in one private place."
        case .register:
            return "Set up your personal finance space with a calm, private, and premium experience."
        }
    }

    var buttonTitle: String {
        switch self {
        case .login:
            return "Sign In"
        case .register:
            return "Create Account"
        }
    }
}

private enum AuthField: Hashable {
    case fullName
    case email
    case phone
    case password
    case confirmPassword
}

struct AuthenticationFlowScreen: View {
    @Binding var isAuthenticated: Bool

    @State private var mode: AuthMode = .login
    @State private var fullName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var keepSignedIn = true
    @State private var acceptsPrivacy = true
    @Namespace private var selectorNamespace
    @FocusState private var focusedField: AuthField?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 26) {
                authHero
                securityRow
                modeSelector
                formCard
                bottomSwitchPrompt
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 34)
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private var authHero: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                Image("Gemini_Generated_Image_yzd5hgyzd5hgyzd5")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(FinancePalette.icyBlue.opacity(0.85), lineWidth: 1)
                    )
                    .shadow(color: FinancePalette.royalBlue.opacity(0.18), radius: 12, y: 8)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Finance Tracker")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(FinancePalette.textPrimary)

                    Text("Private money management")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(FinancePalette.textSecondary)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text(mode.title)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)

                Text(mode.subtitle)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(FinancePalette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var securityRow: some View {
        HStack(spacing: 10) {
            AuthFeaturePill(symbol: "lock.shield.fill", title: "Private")
            AuthFeaturePill(symbol: "bolt.fill", title: "Fast")
            AuthFeaturePill(symbol: "checkmark.seal.fill", title: "Secure")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var modeSelector: some View {
        HStack(spacing: 0) {
            ForEach(AuthMode.allCases) { currentMode in
                Button {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                        mode = currentMode
                    }
                } label: {
                    ZStack {
                        if mode == currentMode {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [FinancePalette.royalBlue, FinancePalette.oceanBlue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .matchedGeometryEffect(id: "auth_mode", in: selectorNamespace)
                        }

                        Text(currentMode.rawValue)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(mode == currentMode ? .white : FinancePalette.textSecondary)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(Color.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(FinancePalette.icyBlue.opacity(0.95), lineWidth: 1)
        )
        .shadow(color: FinancePalette.cardShadow.opacity(0.28), radius: 14, y: 8)
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(mode == .login ? "Access your account" : "Start your finance journey")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(FinancePalette.textPrimary)

            Text(mode == .login ? "Use your account details to continue." : "Create a clean workspace for your salary, wallet, and investments.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(FinancePalette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if mode == .register {
                AuthInputField(
                    title: "Full Name",
                    placeholder: "Enter your full name",
                    symbol: "person.fill",
                    text: $fullName
                )
                .focused($focusedField, equals: .fullName)
            }

            AuthInputField(
                title: "Email Address",
                placeholder: "name@email.com",
                symbol: "envelope.fill",
                text: $email
            )
            .focused($focusedField, equals: .email)

            if mode == .register {
                AuthInputField(
                    title: "Mobile Number",
                    placeholder: "+91 98765 43210",
                    symbol: "phone.fill",
                    text: $phone
                )
                .focused($focusedField, equals: .phone)
            }

            AuthSecureInputField(
                title: "Password",
                placeholder: "Enter password",
                symbol: "lock.fill",
                text: $password
            )
            .focused($focusedField, equals: .password)

            if mode == .register {
                AuthSecureInputField(
                    title: "Confirm Password",
                    placeholder: "Re-enter password",
                    symbol: "checkmark.shield.fill",
                    text: $confirmPassword
                )
                .focused($focusedField, equals: .confirmPassword)
            }

            if mode == .login {
                HStack(spacing: 10) {
                    Button {
                        withAnimation(.smooth(duration: 0.25)) {
                            keepSignedIn.toggle()
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: keepSignedIn ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(keepSignedIn ? FinancePalette.royalBlue : FinancePalette.textSecondary.opacity(0.65))

                            Text("Keep me signed in")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(FinancePalette.textSecondary)
                        }
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button("Forgot password?") { }
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(FinancePalette.royalBlue)
                }
            } else {
                Button {
                    withAnimation(.smooth(duration: 0.25)) {
                        acceptsPrivacy.toggle()
                    }
                } label: {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: acceptsPrivacy ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(acceptsPrivacy ? FinancePalette.royalBlue : FinancePalette.textSecondary.opacity(0.65))
                            .padding(.top, 1)

                        Text("I agree to keep my finance data private on this device and accept the app privacy policy.")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(FinancePalette.textSecondary)
                            .multilineTextAlignment(.leading)
                    }
                }
                .buttonStyle(.plain)
            }

            Button {
                focusedField = nil
                withAnimation(.smooth(duration: 0.35)) {
                    isAuthenticated = true
                }
            } label: {
                HStack(spacing: 10) {
                    Text(mode.buttonTitle)
                        .font(.system(size: 16, weight: .bold, design: .rounded))

                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(
                    LinearGradient(
                        colors: [FinancePalette.royalBlue, FinancePalette.oceanBlue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: FinancePalette.royalBlue.opacity(0.28), radius: 16, y: 10)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)

            Text(mode == .login ? "UI is ready for real sign-in integration next." : "This account flow is ready for backend and Firebase connection next.")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(FinancePalette.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color.white.opacity(0.96))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(FinancePalette.icyBlue.opacity(0.95), lineWidth: 1)
        )
        .shadow(color: FinancePalette.cardShadow.opacity(0.32), radius: 20, y: 14)
    }

    private var bottomSwitchPrompt: some View {
        HStack(spacing: 6) {
            Text(mode == .login ? "New here?" : "Already have an account?")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(FinancePalette.textSecondary)

            Button(mode == .login ? "Create one" : "Sign in") {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                    mode = mode == .login ? .register : .login
                }
            }
            .buttonStyle(.plain)
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundStyle(FinancePalette.royalBlue)
        }
        .padding(.bottom, 8)
    }
}

private struct AuthFeaturePill: View {
    let symbol: String
    let title: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(FinancePalette.royalBlue)

            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(FinancePalette.textPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.92))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(FinancePalette.icyBlue.opacity(0.92), lineWidth: 1)
        )
        .shadow(color: FinancePalette.cardShadow.opacity(0.20), radius: 8, y: 4)
    }
}

private struct AuthInputField: View {
    let title: String
    let placeholder: String
    let symbol: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(FinancePalette.textSecondary)

            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(FinancePalette.paleBlue)
                        .frame(width: 40, height: 40)

                    Image(systemName: symbol)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(FinancePalette.royalBlue)
                }

                TextField(placeholder, text: $text)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(FinancePalette.textPrimary)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white, FinancePalette.mistBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(FinancePalette.icyBlue.opacity(0.96), lineWidth: 1)
            )
        }
    }
}

private struct AuthSecureInputField: View {
    let title: String
    let placeholder: String
    let symbol: String
    @Binding var text: String
    @State private var isRevealed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(FinancePalette.textSecondary)

            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(FinancePalette.paleBlue)
                        .frame(width: 40, height: 40)

                    Image(systemName: symbol)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(FinancePalette.royalBlue)
                }

                Group {
                    if isRevealed {
                        TextField(placeholder, text: $text)
                    } else {
                        SecureField(placeholder, text: $text)
                    }
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(FinancePalette.textPrimary)
                .autocorrectionDisabled()

                Button {
                    withAnimation(.smooth(duration: 0.22)) {
                        isRevealed.toggle()
                    }
                } label: {
                    Image(systemName: isRevealed ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(FinancePalette.textSecondary)
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white, FinancePalette.mistBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(FinancePalette.icyBlue.opacity(0.96), lineWidth: 1)
            )
        }
    }
}

struct AuthenticationFlowScreen_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppBackground()
            AuthenticationFlowScreen(isAuthenticated: .constant(false))
        }
        .preferredColorScheme(.light)
    }
}
