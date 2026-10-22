import SwiftUI

struct RegisterView: View {
    var role: String
    
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var langManager = AppLanguageManager.shared
    
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var place = ""
    @State private var specialization = "Trichology & Scalp Health"
    @State private var dob = Calendar.current.date(byAdding: .year, value: -20, to: Date()) ?? Date()
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var hasSubmitted = false
    
    @State private var errorMessage = ""
    @State private var successMessage = ""
    @State private var animate = false
    
    @State private var showSuccessDialog = false
    @State private var showErrorAlert = false
    @State private var showLanguageSheet = false
    
    @StateObject var vm = RegisterViewModel()
    
    // MARK: - Email Validation
    func isValidEmail(_ email: String) -> Bool {
        let clean = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: clean)
    }
    
    // MARK: - Check Duplicate Email
    func isEmailAlreadyRegistered(_ email: String) -> Bool {
        let clean = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let savedEmails = UserDefaults.standard.stringArray(forKey: "registeredEmails") ?? []
        return savedEmails.contains(clean)
    }
    
    // MARK: - Save Email
    func saveEmail(_ email: String) {
        let clean = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        var savedEmails = UserDefaults.standard.stringArray(forKey: "registeredEmails") ?? []
        if !savedEmails.contains(clean) {
            savedEmails.append(clean)
            UserDefaults.standard.set(savedEmails, forKey: "registeredEmails")
        }
    }
    
    // MARK: - Password Validation
    func isValidPassword(_ pwd: String) -> Bool {
        let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*(),.?\":{}|<>]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: pwd)
    }
    
    // MARK: - Name Validation
    func isValidName(_ name: String) -> Bool {
        let clean = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard clean.count >= 3 && clean.count <= 50 else { return false }
        let regex = "^[A-Za-z ]+$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: clean)
    }
    
    // MARK: - Phone Validation (10 digits)
    func isValidPhone(_ phone: String) -> Bool {
        let digits = phone.filter { $0.isNumber }
        return digits.count == 10
    }
    
    // MARK: - Place Validation
    func isValidPlace(_ place: String) -> Bool {
        let clean = place.trimmingCharacters(in: .whitespacesAndNewlines)
        return clean.count >= 2
    }
    
    // MARK: - Age Validation (18+)
    func isAgeValid(_ dob: Date) -> Bool {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dob, to: Date())
        return (ageComponents.year ?? 0) >= 18
    }
    
    var maxDOB: Date {
        Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    }
    
    var isDoctor: Bool {
        role.lowercased() == "doctor"
    }
    
    // Computed inline errors
    var nameErrorMessage: String? {
        guard hasSubmitted else { return nil }
        let clean = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if clean.isEmpty { return "Full name is required" }
        if !isValidName(clean) { return "Name must be 3+ letters and contain only alphabets" }
        return nil
    }
    
    var emailErrorMessage: String? {
        guard hasSubmitted else { return nil }
        let clean = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if clean.isEmpty { return "Email address is required" }
        if !isValidEmail(clean) { return "Enter a valid email address (e.g. name@domain.com)" }
        if isEmailAlreadyRegistered(clean) { return "This email is already registered. Please sign in." }
        return nil
    }
    
    var phoneErrorMessage: String? {
        guard hasSubmitted else { return nil }
        let digits = phone.filter { $0.isNumber }
        if digits.isEmpty { return "Phone number is required" }
        if digits.count != 10 { return "Phone number must be exactly 10 digits" }
        return nil
    }
    
    var placeErrorMessage: String? {
        guard hasSubmitted else { return nil }
        let clean = place.trimmingCharacters(in: .whitespacesAndNewlines)
        if clean.isEmpty { return "Location is required" }
        if clean.count < 2 { return "Location must be at least 2 characters" }
        return nil
    }
    
    var specializationErrorMessage: String? {
        guard hasSubmitted && isDoctor else { return nil }
        if specialization.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Please select a specialization"
        }
        return nil
    }
    
    var dobErrorMessage: String? {
        guard hasSubmitted else { return nil }
        if !isAgeValid(dob) {
            return "You must be at least 18 years old to register"
        }
        return nil
    }
    
    var passwordErrorMessage: String? {
        guard hasSubmitted else { return nil }
        if password.isEmpty { return "Password is required" }
        if !isValidPassword(password) {
            return "Must contain uppercase, lowercase, special character, and be 8+ characters"
        }
        return nil
    }
    
    var confirmPasswordErrorMessage: String? {
        guard hasSubmitted else { return nil }
        if confirmPassword.isEmpty { return "Please confirm your password" }
        if confirmPassword != password { return "Passwords do not match" }
        return nil
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [AppTheme.primaryBrand.opacity(0.18), AppTheme.irisPurple.opacity(0.12)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 58, height: 58)
                                
                                Image(systemName: isDoctor ? "person.badge.shield.checkmark.fill" : "person.crop.circle.badge.plus")
                                    .font(.system(size: 28))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [AppTheme.primaryBrand, AppTheme.irisPurple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            .scaleEffect(animate ? 1 : 0.7)
                            .animation(.spring(response: 0.5, dampingFraction: 0.65), value: animate)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(langManager.text("create_account"))
                                    .font(.system(size: AppTheme.titleFontSize(sizeClass), weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.titleText)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                
                                HStack(spacing: 6) {
                                    Text(langManager.text("registering_as"))
                                        .foregroundColor(AppTheme.bodyText)
                                    Text(isDoctor ? "Hair Specialist / Expert" : langManager.text("member_user"))
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppTheme.primaryBrand)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(AppTheme.primaryBrand.opacity(0.12))
                                        .cornerRadius(8)
                                }
                                .font(.subheadline)
                                .minimumScaleFactor(0.85)
                                .lineLimit(1)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animate)
                    
                    // Form Glass Card
                    GlassCard(cornerRadius: 22, padding: 20) {
                        VStack(spacing: 14) {
                            
                            // 1. Full Name
                            formField(
                                icon: "person.fill",
                                placeholder: langManager.text("full_name"),
                                text: $name,
                                isError: nameErrorMessage != nil,
                                errorMessage: nameErrorMessage
                            )
                            
                            // 2. Email Address
                            formField(
                                icon: "envelope.fill",
                                placeholder: "\(langManager.text("email_address")) (gmail/yahoo/saveetha)",
                                text: $email,
                                keyboard: .emailAddress,
                                isError: emailErrorMessage != nil,
                                errorMessage: emailErrorMessage
                            )
                            
                            // 3. Phone (10 digits)
                            formField(
                                icon: "phone.fill",
                                placeholder: langManager.text("phone_placeholder"),
                                text: $phone,
                                keyboard: .numberPad,
                                isError: phoneErrorMessage != nil,
                                errorMessage: phoneErrorMessage
                            )
                            .onChange(of: phone) { newValue in
                                let digits = newValue.filter { $0.isNumber }
                                if digits.count > 10 {
                                    phone = String(digits.prefix(10))
                                } else if digits != newValue {
                                    phone = digits
                                }
                            }
                            
                            // 4. Location / Place
                            formField(
                                icon: "mappin.and.ellipse",
                                placeholder: langManager.text("location_placeholder"),
                                text: $place,
                                isError: placeErrorMessage != nil,
                                errorMessage: placeErrorMessage
                            )
                            
                            // 5. Specialization (Doctor / Expert Only)
                            if isDoctor {
                                VStack(alignment: .leading, spacing: 4) {
                                    Menu {
                                        ForEach(ExpertSpecializationManager.availableSpecializations, id: \.self) { spec in
                                            Button {
                                                specialization = spec
                                            } label: {
                                                HStack {
                                                    Text(spec)
                                                    if specialization == spec {
                                                        Image(systemName: "checkmark")
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: "cross.case.fill")
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(AppTheme.primaryBrand)
                                                .frame(width: 24)
                                            
                                            Text(specialization.isEmpty ? "Select Specialization" : specialization)
                                                .font(.subheadline)
                                                .foregroundColor(specialization.isEmpty ? AppTheme.bodyText.opacity(0.6) : AppTheme.titleText)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.85)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.up.chevron.down")
                                                .font(.caption)
                                                .foregroundColor(AppTheme.bodyText.opacity(0.6))
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 12)
                                        .background(Color.white.opacity(0.7))
                                        .cornerRadius(14)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(
                                                    specializationErrorMessage != nil ?
                                                    Color.red.opacity(0.85) : Color.black.opacity(0.06),
                                                    lineWidth: specializationErrorMessage != nil ? 1.5 : 1
                                                )
                                        )
                                    }
                                    
                                    if let specErr = specializationErrorMessage {
                                        HStack(spacing: 4) {
                                            Image(systemName: "exclamationmark.circle.fill")
                                                .font(.system(size: 11))
                                            Text(specErr)
                                                .font(.caption2)
                                        }
                                        .foregroundColor(.red)
                                        .padding(.leading, 4)
                                    }
                                }
                            }
                            
                            // 6. Date of Birth
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(AppTheme.primaryBrand)
                                        .frame(width: 24)
                                    
                                    DatePicker(
                                        langManager.text("date_of_birth"),
                                        selection: $dob,
                                        in: ...maxDOB,
                                        displayedComponents: .date
                                    )
                                    .datePickerStyle(.compact)
                                    .tint(AppTheme.primaryBrand)
                                    .foregroundColor(AppTheme.titleText)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            dobErrorMessage != nil ? Color.red.opacity(0.85) : Color.black.opacity(0.06),
                                            lineWidth: dobErrorMessage != nil ? 1.5 : 1
                                        )
                                )
                                
                                if let dobErr = dobErrorMessage {
                                    HStack(spacing: 4) {
                                        Image(systemName: "exclamationmark.circle.fill")
                                            .font(.system(size: 11))
                                        Text(dobErr)
                                            .font(.caption2)
                                    }
                                    .foregroundColor(.red)
                                    .padding(.leading, 4)
                                }
                            }
                            
                            // 7. Password
                            passwordField(
                                icon: "lock.fill",
                                placeholder: langManager.text("password_req_placeholder"),
                                text: $password,
                                isVisible: $showPassword,
                                isError: passwordErrorMessage != nil,
                                errorMessage: passwordErrorMessage
                            )
                            
                            // 8. Confirm Password
                            passwordField(
                                icon: "lock.shield.fill",
                                placeholder: langManager.text("confirm_password"),
                                text: $confirmPassword,
                                isVisible: $showConfirmPassword,
                                isError: confirmPasswordErrorMessage != nil,
                                errorMessage: confirmPasswordErrorMessage
                            )
                            
                            // Prominent Error Banner
                            if !errorMessage.isEmpty {
                                HStack(spacing: 10) {
                                    Image(systemName: "exclamationmark.octagon.fill")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.red)
                                    Text(errorMessage)
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(.red)
                                    Spacer()
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.red.opacity(0.12))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red.opacity(0.35), lineWidth: 1)
                                )
                                .transition(.opacity.combined(with: .scale(scale: 0.98)))
                            }
                            
                            // Submit Button
                            Button {
                                hasSubmitted = true
                                errorMessage = ""
                                successMessage = ""
                                
                                let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                                let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                                let cleanPhone = phone.filter { $0.isNumber }
                                let trimmedPlace = place.trimmingCharacters(in: .whitespacesAndNewlines)
                                
                                func triggerUIError(_ message: String) {
                                    errorMessage = message
                                    showErrorAlert = true
                                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                                }
                                
                                guard !trimmedName.isEmpty, !trimmedEmail.isEmpty, !cleanPhone.isEmpty, !trimmedPlace.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
                                    triggerUIError("All fields are required. Please fill in the missing information.")
                                    return
                                }
                                
                                guard isValidName(trimmedName) else {
                                    triggerUIError("Full name should contain only alphabets (minimum 3 characters).")
                                    return
                                }
                                
                                guard isValidEmail(trimmedEmail) else {
                                    triggerUIError("Please enter a valid email address (e.g. name@domain.com).")
                                    return
                                }
                                
                                guard !isEmailAlreadyRegistered(trimmedEmail) else {
                                    triggerUIError("This email is already registered. Please sign in instead.")
                                    return
                                }
                                
                                guard cleanPhone.count == 10 else {
                                    triggerUIError("Phone number must be exactly 10 digits.")
                                    return
                                }
                                
                                guard isValidPlace(trimmedPlace) else {
                                    triggerUIError("Location must be at least 2 characters.")
                                    return
                                }
                                
                                if isDoctor {
                                    guard !specialization.trimmingCharacters(in: .whitespaces).isEmpty else {
                                        triggerUIError("Please select your clinical specialization.")
                                        return
                                    }
                                }
                                
                                guard isAgeValid(dob) else {
                                    triggerUIError("You must be at least 18 years old to register.")
                                    return
                                }
                                
                                guard isValidPassword(password) else {
                                    triggerUIError("Password must contain uppercase, lowercase, special character, and be at least 8 characters.")
                                    return
                                }
                                
                                guard password == confirmPassword else {
                                    triggerUIError("Passwords do not match. Please re-enter your password.")
                                    return
                                }
                                
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd"
                                
                                // 1. API Call (Unchanged: 7 parameters expected by register.php)
                                vm.register(
                                    name: trimmedName,
                                    email: trimmedEmail,
                                    phone: cleanPhone,
                                    place: trimmedPlace,
                                    dob: formatter.string(from: dob),
                                    role: role,
                                    password: password
                                )
                                
                                // 2. Save email locally
                                saveEmail(trimmedEmail)
                                
                                // 3. Store Expert Specialization in Core Data without affecting the API
                                if isDoctor {
                                    CoreDataExpertManager.shared.saveSpecialization(email: trimmedEmail, specialization: specialization)
                                }
                                
                                // 4. First-time language onboarding sheet
                                showLanguageSheet = true
                                
                            } label: {
                                Text(langManager.text("create_account"))
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .padding(.top, 4)
                        }
                    }
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 30)
                    .animation(.easeOut(duration: 0.7), value: animate)
                    
                    // Legal footer
                    Text("By creating an account, you agree to our Terms of Service and Privacy Policy.")
                        .font(.caption2)
                        .foregroundColor(AppTheme.bodyText.opacity(0.8))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                        .padding(.bottom, 20)
                        .minimumScaleFactor(0.85)
                    
                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: sizeClass == .regular ? 560 : 440)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .onAppear { animate = true }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(langManager.text("register"))
                    .font(.headline)
                    .foregroundColor(AppTheme.titleText)
            }
        }
        .alert("Validation Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showLanguageSheet, onDismiss: {
            showSuccessDialog = true
        }) {
            LanguagePickerSheet()
        }
        .alert("Account Created", isPresented: $showSuccessDialog) {
            Button("Proceed to Sign In") {
                dismiss()
            }
        } message: {
            Text("Your account has been registered successfully. Please sign in to continue.")
        }
    }
    
    // MARK: - Form Field
    func formField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default,
        isError: Bool = false,
        errorMessage: String? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isError ? .red : AppTheme.primaryBrand)
                    .frame(width: 24)
                
                TextField(placeholder, text: text)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.titleText)
                    .keyboardType(keyboard)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                if !text.wrappedValue.isEmpty {
                    Button {
                        text.wrappedValue = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.bodyText.opacity(0.4))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.7))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isError ? Color.red.opacity(0.85) : Color.black.opacity(0.06), lineWidth: isError ? 1.5 : 1)
            )
            
            if isError, let errorMessage = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 11))
                    Text(errorMessage)
                        .font(.caption2)
                }
                .foregroundColor(.red)
                .padding(.leading, 4)
                .transition(.opacity)
            }
        }
    }
    
    // MARK: - Password Field
    func passwordField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        isVisible: Binding<Bool>,
        isError: Bool = false,
        errorMessage: String? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isError ? .red : AppTheme.primaryBrand)
                    .frame(width: 24)
                
                if isVisible.wrappedValue {
                    TextField(placeholder, text: text)
                        .font(.subheadline)
                        .foregroundColor(AppTheme.titleText)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                } else {
                    SecureField(placeholder, text: text)
                        .font(.subheadline)
                        .foregroundColor(AppTheme.titleText)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Button {
                    isVisible.wrappedValue.toggle()
                } label: {
                    Image(systemName: isVisible.wrappedValue ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(AppTheme.bodyText.opacity(0.6))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.7))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isError ? Color.red.opacity(0.85) : Color.black.opacity(0.06), lineWidth: isError ? 1.5 : 1)
            )
            
            if isError, let errorMessage = errorMessage {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 11))
                    Text(errorMessage)
                        .font(.caption2)
                }
                .foregroundColor(.red)
                .padding(.leading, 4)
                .transition(.opacity)
            }
        }
    }
}
