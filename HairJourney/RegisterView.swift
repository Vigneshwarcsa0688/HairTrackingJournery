import SwiftUI

struct RegisterView: View {
    var role: String
    
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var place = ""
    @State private var dob = Date()
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    @State private var errorMessage = ""
    @State private var successMessage = ""
    @State private var animate = false
    
    @State private var showSuccessDialog = false
    
    @StateObject var vm = RegisterViewModel()
    
    
    // MARK: Email Validation
    func isValidEmail(_ email: String) -> Bool {
        let regex = "^[A-Z0-9a-z._%+-]+@(gmail\\.com|yahoo\\.com|saveetha\\.com)$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
    
    
    // MARK: ✅ Check Duplicate Email
    func isEmailAlreadyRegistered(_ email: String) -> Bool {
        let savedEmails = UserDefaults.standard.stringArray(forKey: "registeredEmails") ?? []
        return savedEmails.contains(email.lowercased())
    }
    
    
    // MARK: ✅ Save Email
    func saveEmail(_ email: String) {
        var savedEmails = UserDefaults.standard.stringArray(forKey: "registeredEmails") ?? []
        savedEmails.append(email.lowercased())
        UserDefaults.standard.set(savedEmails, forKey: "registeredEmails")
    }
    
    
    // MARK: Password Validation
    func isValidPassword(_ pwd: String) -> Bool {
        let regex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*(),.?\":{}|<>]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: pwd)
    }
    
    
    // MARK: Name Validation
    func isValidName(_ name: String) -> Bool {
        let regex = "^[A-Za-z ]+$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: name)
    }
    
    
    // MARK: Age Validation (18+)
    func isAgeValid(_ dob: Date) -> Bool {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dob, to: Date())
        return (ageComponents.year ?? 0) >= 18
    }
    
    
    var maxDOB: Date {
        Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    }
    
    
    var body: some View {
        ZStack {
            AppTheme.gradient
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 70))
                            .foregroundColor(AppTheme.bodyText)
                            .scaleEffect(animate ? 1 : 0.7)
                            .animation(.easeOut(duration: 0.6), value: animate)
                        
                        Text("Create Account")
                            .font(.largeTitle.bold())
                            .foregroundColor(AppTheme.titleText)
                        
                        Text("Start your personalized hair care journey")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.bodyText)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.top, 30)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animate)
                    
                    
                    GlassCard {
                        VStack(spacing: 16) {
                            
                            formField(icon: "person.fill", placeholder: "Full Name", text: $name)
                            formField(icon: "envelope.fill", placeholder: "Email", text: $email, keyboard: .emailAddress)
                            formField(icon: "phone.fill", placeholder: "Phone (10 digits)", text: $phone, keyboard: .numberPad)
                            formField(icon: "location.fill", placeholder: "Place", text: $place)
                            
                            
                            DatePicker(
                                "Date of Birth",
                                selection: $dob,
                                in: ...maxDOB,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            
                            
                            passwordField(
                                icon: "lock.fill",
                                placeholder: "Password",
                                text: $password,
                                isVisible: $showPassword
                            )
                            
                            
                            passwordField(
                                icon: "lock.rotation",
                                placeholder: "Confirm Password",
                                text: $confirmPassword,
                                isVisible: $showConfirmPassword
                            )
                            
                            
                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                            }
                            
                            
                            Button {
                                
                                errorMessage = ""
                                successMessage = ""
                                
                                guard !name.isEmpty, !email.isEmpty, !phone.isEmpty, !place.isEmpty else {
                                    errorMessage = "All fields are required"
                                    return
                                }
                                
                                guard isValidName(name) else {
                                    errorMessage = "Name should contain only alphabets"
                                    return
                                }
                                
                                guard isValidEmail(email) else {
                                    errorMessage = "Email must be gmail.com / yahoo.com / saveetha.com"
                                    return
                                }
                                
                                // ✅ NEW CHECK
                                guard !isEmailAlreadyRegistered(email) else {
                                    errorMessage = "This email is already registered"
                                    return
                                }
                                
                                guard isAgeValid(dob) else {
                                    errorMessage = "You must be at least 18 years old"
                                    return
                                }
                                
                                guard phone.count == 10 else {
                                    errorMessage = "Phone number must be 10 digits"
                                    return
                                }
                                
                                guard isValidPassword(password) else {
                                    errorMessage = "Password must contain uppercase, lowercase, special character and be 8+ characters"
                                    return
                                }
                                
                                guard password == confirmPassword else {
                                    errorMessage = "Passwords do not match"
                                    return
                                }
                                
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd"
                                
                                vm.register(
                                    name: name,
                                    email: email,
                                    phone: phone,
                                    place: place,
                                    dob: formatter.string(from: dob),
                                    role: role,
                                    password: password
                                )
                                
                                // ✅ SAVE EMAIL AFTER SUCCESS
                                saveEmail(email)
                                
                                showSuccessDialog = true
                                
                            } label: {
                                Text("Create Account")
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                    }
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 30)
                    .animation(.easeOut(duration: 0.7), value: animate)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal)
                .frame(maxWidth: sizeClass == .regular ? 600 : 500)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .onAppear { animate = true }
        .navigationBarTitleDisplayMode(.inline)
        
        
        .alert("Success", isPresented: $showSuccessDialog) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("✅ Registration successful! Please login.")
        }
    }
    
    
    // MARK: Fields
    
    func formField(icon: String, placeholder: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.purple)
            
            TextField(placeholder, text: text)
                .foregroundColor(AppTheme.titleText)
                .keyboardType(keyboard)
                .autocapitalization(.none)
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
    }
    
    
    func passwordField(icon: String, placeholder: String, text: Binding<String>, isVisible: Binding<Bool>) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.purple)
            
            if isVisible.wrappedValue {
                TextField(placeholder, text: text)
                    .foregroundColor(AppTheme.titleText)
            } else {
                SecureField(placeholder, text: text)
                    .foregroundColor(AppTheme.titleText)
            }
            
            Button {
                isVisible.wrappedValue.toggle()
            } label: {
                Image(systemName: isVisible.wrappedValue ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
    }
}
