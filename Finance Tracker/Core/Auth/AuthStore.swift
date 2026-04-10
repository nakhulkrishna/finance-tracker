import Combine
import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

enum FinanceAccountType: String, Codable, CaseIterable {
    case standard
    case premium

    var badgeTitle: String {
        switch self {
        case .standard:
            return "Standard"
        case .premium:
            return "Premium"
        }
    }
}

struct AuthSessionUser: Equatable {
    let id: String
    let fullName: String
    let email: String
    let phoneNumber: String
    let initials: String
    let memberSinceText: String
    let accountType: FinanceAccountType

    var firstName: String {
        fullName
            .split(separator: " ")
            .first
            .map(String.init) ?? fullName
    }

    var profileSubtitle: String {
        phoneNumber.isEmpty ? email : phoneNumber
    }
}

struct ProfilePreferences: Equatable, Codable {
    var selectedCurrency: ProfileCurrency
    var preferredWalletSource: WalletPreferenceSource
    var showWalletSyncStatus: Bool
    var showWalletActivityPreview: Bool
    var prefersDarkMode: Bool
    var spendingAlerts: Bool
    var weeklyInsights: Bool
    var biometricLock: Bool
    var lockOnLaunch: Bool
    var hideRecentActivity: Bool
    var paymentCategories: [String]
    var depositCategories: [String]
    var walletAddCategories: [String]
    var walletWithdrawCategories: [String]

    init(
        selectedCurrency: ProfileCurrency = .inr,
        preferredWalletSource: WalletPreferenceSource = .bankTransfer,
        showWalletSyncStatus: Bool = true,
        showWalletActivityPreview: Bool = true,
        prefersDarkMode: Bool = false,
        spendingAlerts: Bool = true,
        weeklyInsights: Bool = true,
        biometricLock: Bool = false,
        lockOnLaunch: Bool = false,
        hideRecentActivity: Bool = false,
        paymentCategories: [String] = [],
        depositCategories: [String] = [],
        walletAddCategories: [String] = [],
        walletWithdrawCategories: [String] = []
    ) {
        self.selectedCurrency = selectedCurrency
        self.preferredWalletSource = preferredWalletSource
        self.showWalletSyncStatus = showWalletSyncStatus
        self.showWalletActivityPreview = showWalletActivityPreview
        self.prefersDarkMode = prefersDarkMode
        self.spendingAlerts = spendingAlerts
        self.weeklyInsights = weeklyInsights
        self.biometricLock = biometricLock
        self.lockOnLaunch = lockOnLaunch
        self.hideRecentActivity = hideRecentActivity
        self.paymentCategories = paymentCategories
        self.depositCategories = depositCategories
        self.walletAddCategories = walletAddCategories
        self.walletWithdrawCategories = walletWithdrawCategories
    }

    static let `default` = ProfilePreferences()

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        selectedCurrency = try container.decodeIfPresent(ProfileCurrency.self, forKey: .selectedCurrency) ?? .inr
        preferredWalletSource = try container.decodeIfPresent(WalletPreferenceSource.self, forKey: .preferredWalletSource) ?? .bankTransfer
        showWalletSyncStatus = try container.decodeIfPresent(Bool.self, forKey: .showWalletSyncStatus) ?? true
        showWalletActivityPreview = try container.decodeIfPresent(Bool.self, forKey: .showWalletActivityPreview) ?? true
        prefersDarkMode = try container.decodeIfPresent(Bool.self, forKey: .prefersDarkMode) ?? false
        spendingAlerts = try container.decodeIfPresent(Bool.self, forKey: .spendingAlerts) ?? true
        weeklyInsights = try container.decodeIfPresent(Bool.self, forKey: .weeklyInsights) ?? true
        biometricLock = try container.decodeIfPresent(Bool.self, forKey: .biometricLock) ?? false
        lockOnLaunch = try container.decodeIfPresent(Bool.self, forKey: .lockOnLaunch) ?? false
        hideRecentActivity = try container.decodeIfPresent(Bool.self, forKey: .hideRecentActivity) ?? false
        paymentCategories = try container.decodeIfPresent([String].self, forKey: .paymentCategories) ?? []
        depositCategories = try container.decodeIfPresent([String].self, forKey: .depositCategories) ?? []
        walletAddCategories = try container.decodeIfPresent([String].self, forKey: .walletAddCategories) ?? []
        walletWithdrawCategories = try container.decodeIfPresent([String].self, forKey: .walletWithdrawCategories) ?? []
    }
}

enum FirebaseBootstrap {
    static func configureIfNeeded() {
        guard FirebaseApp.app() == nil else { return }
        FirebaseApp.configure()
    }
}

@MainActor
final class AuthStore: ObservableObject {
    @Published private(set) var currentUser: AuthSessionUser?
    @Published private(set) var profilePreferences = ProfilePreferences.default
    @Published private(set) var isLoading = false
    @Published private(set) var isRestoringSession = true
    @Published var errorMessage: String?
    @Published var infoMessage: String?

    var isAuthenticated: Bool {
        currentUser != nil
    }

    var requiresInitialFinanceSetup: Bool {
        isAuthenticated && !(currentProfile?.hasCompletedInitialFinanceSetup ?? true)
    }

    private let auth: Auth
    private let firestore: Firestore
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var profileListener: ListenerRegistration?
    private var profileSyncTask: Task<Void, Never>?
    private var currentProfile: StoredProfile?

    init(
        auth: Auth = Auth.auth(),
        firestore: Firestore = Firestore.firestore()
    ) {
        self.auth = auth
        self.firestore = firestore
        observeAuthState()
    }

    deinit {
        if let authStateHandle {
            auth.removeStateDidChangeListener(authStateHandle)
        }

        profileListener?.remove()
        profileSyncTask?.cancel()
    }

    func signIn(email: String, password: String) {
        let normalizedEmail = email.normalizedInput
        let normalizedPassword = password.normalizedInput

        guard !normalizedEmail.isEmpty else {
            errorMessage = "Enter your email address to sign in."
            return
        }

        guard !normalizedPassword.isEmpty else {
            errorMessage = "Enter your password to continue."
            return
        }

        isLoading = true
        errorMessage = nil
        infoMessage = nil

        auth.signIn(withEmail: normalizedEmail, password: normalizedPassword) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }
                self.isLoading = false

                if let error {
                    self.errorMessage = Self.userFriendlyMessage(for: error)
                    return
                }

                if let user = result?.user {
                    self.currentUser = self.makeSessionUser(from: user)
                }
            }
        }
    }

    func register(
        fullName: String,
        email: String,
        phoneNumber: String,
        password: String,
        confirmPassword: String,
        acceptedPrivacy: Bool
    ) {
        let normalizedName = fullName.normalizedInput
        let normalizedEmail = email.normalizedInput
        let normalizedPhone = phoneNumber.normalizedInput
        let normalizedPassword = password.normalizedInput
        let normalizedConfirmation = confirmPassword.normalizedInput

        guard !normalizedName.isEmpty else {
            errorMessage = "Enter your full name to create the account."
            return
        }

        guard !normalizedEmail.isEmpty else {
            errorMessage = "Enter your email address to register."
            return
        }

        guard !normalizedPhone.isEmpty else {
            errorMessage = "Enter your mobile number so it shows in your finance profile."
            return
        }

        guard normalizedPassword.count >= 6 else {
            errorMessage = "Password must be at least 6 characters long."
            return
        }

        guard normalizedPassword == normalizedConfirmation else {
            errorMessage = "Password and confirm password do not match."
            return
        }

        guard acceptedPrivacy else {
            errorMessage = "Accept the privacy policy to continue."
            return
        }

        isLoading = true
        errorMessage = nil
        infoMessage = nil

        auth.createUser(withEmail: normalizedEmail, password: normalizedPassword) { [weak self] result, error in
            Task { @MainActor in
                guard let self else { return }

                if let error {
                    self.isLoading = false
                    self.errorMessage = Self.userFriendlyMessage(for: error)
                    return
                }

                guard let user = result?.user else {
                    self.isLoading = false
                    self.errorMessage = "The account was created, but the user session could not be loaded."
                    return
                }

                let initialProfile = StoredProfile(
                    fullName: normalizedName,
                    phoneNumber: normalizedPhone,
                    email: normalizedEmail,
                    accountType: .standard,
                    preferences: .default,
                    hasCompletedInitialFinanceSetup: false
                )

                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = normalizedName
                changeRequest.commitChanges { [weak self] commitError in
                    Task { @MainActor in
                        guard let self else { return }
                        self.isLoading = false

                        if let commitError {
                            self.errorMessage = Self.userFriendlyMessage(for: commitError)
                        }

                        do {
                            try await self.saveProfileToCloud(initialProfile, for: user.uid)
                        } catch {
                            self.isLoading = false
                            self.applySessionState(for: user, storedProfile: initialProfile)
                            self.errorMessage = "Your account was created, but the profile could not be saved to Firebase: \(error.localizedDescription)"
                            return
                        }

                        user.reload { _ in
                            Task { @MainActor in
                                let refreshedUser = self.auth.currentUser ?? user
                                self.applySessionState(for: refreshedUser, storedProfile: initialProfile)
                                self.isLoading = false
                            }
                        }
                    }
                }
            }
        }
    }

    func sendPasswordReset(email: String) {
        let normalizedEmail = email.normalizedInput

        guard !normalizedEmail.isEmpty else {
            errorMessage = "Enter your email first, then tap forgot password."
            return
        }

        isLoading = true
        errorMessage = nil
        infoMessage = nil

        auth.sendPasswordReset(withEmail: normalizedEmail) { [weak self] error in
            Task { @MainActor in
                guard let self else { return }
                self.isLoading = false

                if let error {
                    self.errorMessage = Self.userFriendlyMessage(for: error)
                    return
                }

                self.infoMessage = "Password reset email sent to \(normalizedEmail)."
            }
        }
    }

    func signOut() {
        do {
            try auth.signOut()
            profileListener?.remove()
            profileListener = nil
            profileSyncTask?.cancel()
            profileSyncTask = nil
            currentProfile = nil
            currentUser = nil
            profilePreferences = .default
            errorMessage = nil
            infoMessage = nil
        } catch {
            errorMessage = Self.userFriendlyMessage(for: error)
        }
    }

    func clearMessages() {
        errorMessage = nil
        infoMessage = nil
    }

    func updateProfile(
        fullName: String,
        phoneNumber: String,
        completion: @escaping (String?) -> Void
    ) {
        guard let user = auth.currentUser else {
            completion("Your account session is not ready yet.")
            return
        }

        let normalizedName = fullName.normalizedInput
        let normalizedPhone = phoneNumber.normalizedInput

        guard !normalizedName.isEmpty else {
            completion("Enter your full name before saving.")
            return
        }

        guard !normalizedPhone.isEmpty else {
            completion("Enter your phone number before saving.")
            return
        }

        let storedProfile = currentStoredProfile(for: user)
        let updatedProfile = StoredProfile(
            fullName: normalizedName,
            phoneNumber: normalizedPhone,
            email: user.email?.normalizedInput.nonEmpty ?? storedProfile.email,
            accountType: storedProfile.accountType,
            preferences: storedProfile.preferences
        )

        applySessionState(for: user, storedProfile: updatedProfile)
        isLoading = true
        Task { @MainActor [weak self] in
            guard let self else { return }

            var completionMessage: String?

            do {
                try await self.saveProfileToCloud(updatedProfile, for: user.uid)
            } catch {
                completionMessage = "Saved in the app, but could not sync the profile to Firebase: \(error.localizedDescription)"
            }

            if user.displayName != normalizedName {
                do {
                    try await self.updateDisplayName(for: user, to: normalizedName)
                    let refreshedUser = self.auth.currentUser ?? user
                    self.applySessionState(for: refreshedUser, storedProfile: updatedProfile)
                } catch {
                    let message = "Saved to Firebase, but could not sync the profile name: \(Self.userFriendlyMessage(for: error))"
                    completionMessage = completionMessage.map { $0 + " " + message } ?? message
                }
            }

            self.isLoading = false
            completion(completionMessage)
        }
    }

    func updateProfilePreferences(_ update: (inout ProfilePreferences) -> Void) {
        guard let user = auth.currentUser else { return }
        var storedProfile = currentStoredProfile(for: user)
        update(&storedProfile.preferences)
        applySessionState(for: user, storedProfile: storedProfile)

        Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                try await self.saveProfileToCloud(storedProfile, for: user.uid)
            } catch {
                self.errorMessage = "Your settings changed here, but could not sync to Firebase: \(error.localizedDescription)"
            }
        }
    }

    func completeInitialFinanceSetup() async -> String? {
        guard let user = auth.currentUser else {
            return "Your account session is not ready yet."
        }

        var storedProfile = currentStoredProfile(for: user)
        guard !storedProfile.hasCompletedInitialFinanceSetup else {
            return nil
        }

        storedProfile.hasCompletedInitialFinanceSetup = true

        do {
            try await saveProfileToCloud(storedProfile, for: user.uid)
            applySessionState(for: user, storedProfile: storedProfile)
            return nil
        } catch {
            return "Your opening setup could not be saved to Firebase yet: \(error.localizedDescription)"
        }
    }

    func syncPremiumStatus(
        plan: PremiumPlan,
        productID: String?,
        expiresAt: Date?,
        purchaseSource: String = "appStore"
    ) {
        guard let user = auth.currentUser else { return }

        let resolvedAccountType: FinanceAccountType = plan == .free ? .standard : .premium
        var storedProfile = currentStoredProfile(for: user)
        let shouldUpdateProfile = storedProfile.accountType != resolvedAccountType

        if shouldUpdateProfile {
            storedProfile.accountType = resolvedAccountType
            applySessionState(for: user, storedProfile: storedProfile)
        }

        let billingStatus = StoredBillingStatus(
            plan: plan,
            productID: productID,
            isPremium: resolvedAccountType == .premium,
            purchaseSource: purchaseSource,
            expiresAt: expiresAt,
            lastVerifiedAt: Date()
        )

        Task { @MainActor [weak self] in
            guard let self else { return }

            do {
                if shouldUpdateProfile {
                    try await self.saveProfileToCloud(storedProfile, for: user.uid)
                }

                try await self.saveBillingStatusToCloud(billingStatus, for: user.uid)
            } catch {
                self.errorMessage = "Premium status could not sync to Firebase: \(error.localizedDescription)"
            }
        }
    }

    private func observeAuthState() {
        authStateHandle = auth.addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                guard let self else { return }
                self.profileListener?.remove()
                self.profileListener = nil
                self.profileSyncTask?.cancel()
                self.profileSyncTask = nil

                if let user {
                    let placeholderProfile = self.currentStoredProfile(for: user)
                    self.applySessionState(for: user, storedProfile: placeholderProfile)
                    self.attachProfileListener(for: user)
                    self.profileSyncTask = Task { [weak self] in
                        await self?.ensureCloudProfile(for: user, placeholderProfile: placeholderProfile)
                    }
                } else {
                    self.currentUser = nil
                    self.profilePreferences = .default
                    self.currentProfile = nil
                }
                self.isRestoringSession = false
            }
        }
    }

    private func applySessionState(for user: User, storedProfile: StoredProfile? = nil) {
        let resolvedProfile = storedProfile ?? currentProfile ?? placeholderProfile(for: user)
        currentProfile = resolvedProfile
        currentUser = makeSessionUser(from: user, storedProfile: resolvedProfile)
        profilePreferences = resolvedProfile.preferences
    }

    private func currentStoredProfile(for user: User) -> StoredProfile {
        currentProfile ?? placeholderProfile(for: user)
    }

    private func makeSessionUser(from user: User, storedProfile: StoredProfile? = nil) -> AuthSessionUser {
        let storedProfile = storedProfile ?? currentProfile ?? placeholderProfile(for: user)
        let fullName = user.displayName?.normalizedInput.nonEmpty ?? storedProfile.fullName.nonEmpty ?? Self.fallbackName(from: user.email)
        let email = user.email?.normalizedInput.nonEmpty ?? storedProfile.email.nonEmpty ?? "No email added"
        let phoneNumber = storedProfile.phoneNumber.normalizedInput

        return AuthSessionUser(
            id: user.uid,
            fullName: fullName,
            email: email,
            phoneNumber: phoneNumber,
            initials: Self.initials(from: fullName),
            memberSinceText: Self.memberSinceText(from: user.metadata.creationDate),
            accountType: storedProfile.accountType
        )
    }

    private func attachProfileListener(for user: User) {
        let userID = user.uid
        let reference = FirestorePaths.profileDocument(for: userID, in: firestore)

        profileListener = reference.addSnapshotListener { [weak self] snapshot, error in
            Task { @MainActor in
                guard let self else { return }
                guard self.auth.currentUser?.uid == userID else { return }

                if let error {
                    print("Profile listener error: \(error.localizedDescription)")
                    return
                }

                guard let snapshot, snapshot.exists, let data = snapshot.data() else { return }

                do {
                    let profile = try FirestoreDocumentCodec.decode(
                        StoredProfile.self,
                        from: data
                    )
                    self.applySessionState(for: user, storedProfile: profile)
                } catch {
                    print("Profile decode error: \(error.localizedDescription)")
                }
            }
        }
    }

    private func ensureCloudProfile(for user: User, placeholderProfile: StoredProfile) async {
        let userID = user.uid
        let reference = FirestorePaths.profileDocument(for: userID, in: firestore)

        do {
            let snapshot = try await reference.getDocumentAsync()

            if let data = snapshot.data(), snapshot.exists {
                let remoteProfile = try FirestoreDocumentCodec.decode(
                    StoredProfile.self,
                    from: data
                )
                guard auth.currentUser?.uid == userID else { return }
                applySessionState(for: user, storedProfile: remoteProfile)
                return
            }

            try await saveProfileToCloud(placeholderProfile, for: userID)
            guard auth.currentUser?.uid == userID else { return }
            applySessionState(for: user, storedProfile: placeholderProfile)
        } catch {
            print("Profile sync bootstrap failed: \(error.localizedDescription)")
        }
    }

    private func saveProfileToCloud(_ profile: StoredProfile, for userID: String) async throws {
        let reference = FirestorePaths.profileDocument(for: userID, in: firestore)
        let documentData = try FirestoreDocumentCodec.dictionary(from: profile)
        try await reference.setDataAsync(documentData, merge: false)
    }

    private func saveBillingStatusToCloud(_ billingStatus: StoredBillingStatus, for userID: String) async throws {
        let reference = FirestorePaths.billingDocument(for: userID, in: firestore)
        let documentData = try FirestoreDocumentCodec.dictionary(from: billingStatus)
        try await reference.setDataAsync(documentData, merge: false)
    }

    private func placeholderProfile(for user: User) -> StoredProfile {
        StoredProfile(
            fullName: user.displayName?.normalizedInput.nonEmpty ?? Self.fallbackName(from: user.email),
            phoneNumber: currentProfile?.phoneNumber ?? "",
            email: user.email?.normalizedInput.nonEmpty ?? currentProfile?.email.nonEmpty ?? "No email added",
            accountType: currentProfile?.accountType ?? .standard,
            preferences: currentProfile?.preferences ?? profilePreferences
        )
    }

    private func updateDisplayName(for user: User, to name: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name
            changeRequest.commitChanges { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    user.reload { reloadError in
                        if let reloadError {
                            continuation.resume(throwing: reloadError)
                        } else {
                            continuation.resume(returning: ())
                        }
                    }
                }
            }
        }
    }

    private static func fallbackName(from email: String?) -> String {
        guard let email, let namePart = email.split(separator: "@").first else {
            return "Finance User"
        }

        return namePart
            .replacingOccurrences(of: ".", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }

    private static func initials(from name: String) -> String {
        let pieces = name
            .split(separator: " ")
            .prefix(2)
            .compactMap(\.first)

        let value = pieces.map(String.init).joined()
        return value.isEmpty ? "FT" : value.uppercased()
    }

    private static func memberSinceText(from date: Date?) -> String {
        guard let date else { return "This month" }
        return memberSinceFormatter.string(from: date)
    }

    private static func userFriendlyMessage(for error: Error) -> String {
        guard let authError = error as NSError? else {
            return error.localizedDescription
        }

        guard let code = AuthErrorCode(rawValue: authError.code) else {
            return authError.localizedDescription
        }

        switch code {
        case .invalidEmail:
            return "That email address format looks invalid."
        case .emailAlreadyInUse:
            return "An account already exists with this email."
        case .wrongPassword:
            return "The password is incorrect."
        case .userNotFound:
            return "No account was found for this email."
        case .weakPassword:
            return "Choose a stronger password with at least 6 characters."
        case .networkError:
            return "Network error. Check your internet connection and try again."
        default:
            return authError.localizedDescription
        }
    }
}

private struct StoredProfile: Codable {
    let fullName: String
    let phoneNumber: String
    let email: String
    var accountType: FinanceAccountType
    var preferences: ProfilePreferences
    var hasCompletedInitialFinanceSetup: Bool

    init(
        fullName: String,
        phoneNumber: String,
        email: String,
        accountType: FinanceAccountType = .standard,
        preferences: ProfilePreferences = .default,
        hasCompletedInitialFinanceSetup: Bool = true
    ) {
        self.fullName = fullName
        self.phoneNumber = phoneNumber
        self.email = email
        self.accountType = accountType
        self.preferences = preferences
        self.hasCompletedInitialFinanceSetup = hasCompletedInitialFinanceSetup
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        fullName = try container.decode(String.self, forKey: .fullName)
        phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        email = try container.decode(String.self, forKey: .email)
        accountType = try container.decodeIfPresent(FinanceAccountType.self, forKey: .accountType) ?? .standard
        preferences = try container.decodeIfPresent(ProfilePreferences.self, forKey: .preferences) ?? .default
        hasCompletedInitialFinanceSetup = try container.decodeIfPresent(Bool.self, forKey: .hasCompletedInitialFinanceSetup) ?? true
    }
}

private struct StoredBillingStatus: Codable {
    let plan: PremiumPlan
    let productID: String?
    let isPremium: Bool
    let purchaseSource: String
    let expiresAt: Date?
    let lastVerifiedAt: Date
}

private let memberSinceFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM yyyy"
    return formatter
}()

private extension String {
    var normalizedInput: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var nonEmpty: String? {
        let value = normalizedInput
        return value.isEmpty ? nil : value
    }
}
