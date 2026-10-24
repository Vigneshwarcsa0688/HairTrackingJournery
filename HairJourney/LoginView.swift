import SwiftUI

import SwiftUI

struct LoginView: View {
    var role: String
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var authVM: AuthViewModel
    @ObservedObject private var langManager = AppLanguageManager.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var animate = false
    @State private var isPasswordVisible = false
    
    var isDoctor: Bool {
        role.lowercased() == "doctor"
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    
                    // MARK: - Header & Brand
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 14) {
                            if isDoctor {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.emeraldMint.opacity(0.18))
                                        .frame(width: 58, height: 58)
                                    Image(systemName: "person.badge.shield.checkmark.fill")
                                        .font(.system(size: 30, weight: .semibold))
                                        .foregroundStyle(
                                            .white,
                                            LinearGradient(colors: [AppTheme.emeraldMint, AppTheme.primaryBrand], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                        .shadow(color: AppTheme.emeraldMint.opacity(0.35), radius: 6, y: 3)
                                }
                                .scaleEffect(animate ? 1 : 0.7)
                                .animation(.spring(response: 0.6, dampingFraction: 0.65), value: animate)
                            } else {
                                HairJourneyLogoView(size: 58, showGlow: false)
                                    .scaleEffect(animate ? 1 : 0.7)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.65), value: animate)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(isDoctor ? langManager.text("expert_portal") : langManager.text("welcome_back"))
                                    .font(.system(size: AppTheme.titleFontSize(sizeClass), weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.titleText)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                
                                Text(isDoctor ? langManager.text("doctor_login_subtitle") : langManager.text("user_login_subtitle"))
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.bodyText(0.8))
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.85)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animate)
                    
                    // MARK: - Login Form Card
                    GlassCard(cornerRadius: 24, paddingAmount: 22) {
                        VStack(spacing: 20) {
                            
                            VStack(spacing: 14) {
                                // Email Field
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(AppTheme.primaryBrand.opacity(0.12))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: "envelope.fill")
                                            .font(.system(size: 15))
                                            .foregroundColor(AppTheme.primaryBrand)
                                    }
                                    
                                    TextField(langManager.text("email_address"), text: $email)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .foregroundColor(AppTheme.titleText)
                                    
                                    if !email.isEmpty {
                                        Button { email = "" } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(AppTheme.bodyText(0.4))
                                        }
                                    }
                                }
                                .padding(10)
                                .background(Color.white.opacity(0.85))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color.white, lineWidth: 1)
                                 )
                                
                                // Password Field
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(AppTheme.irisPurple.opacity(0.12))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 15))
                                            .foregroundColor(AppTheme.irisPurple)
                                    }
                                    
                                    if isPasswordVisible {
                                        TextField(langManager.text("password"), text: $password)
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                            .foregroundColor(AppTheme.titleText)
                                    } else {
                                        SecureField(langManager.text("password"), text: $password)
                                            .autocapitalization(.none)
                                            .disableAutocorrection(true)
                                            .foregroundColor(AppTheme.titleText)
                                    }
                                    
                                    Button {
                                        isPasswordVisible.toggle()
                                    } label: {
                                        Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                            .foregroundColor(AppTheme.bodyText(0.6))
                                    }
                                }
                                .padding(10)
                                .background(Color.white.opacity(0.85))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                            }
                            
                            // Forgot Password Link
                            HStack {
                                Spacer()
                                NavigationLink(destination: ForgotPasswordView()) {
                                    Text(langManager.text("forgot_password"))
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(AppTheme.primaryBrand)
                                }
                            }
                            .padding(.top, -4)
                            
                            // Error Banner
                            if !authVM.errorMessage.isEmpty {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(AppTheme.coralRose)
                                    Text(authVM.errorMessage)
                                        .font(.caption.weight(.medium))
                                        .foregroundColor(AppTheme.coralRose)
                                }
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppTheme.coralRose.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                            
                            // Submit Button
                            Button {
                                guard !email.isEmpty, !password.isEmpty else {
                                    authVM.errorMessage = langManager.text("enter_email_password")
                                    return
                                }
                                authVM.login(email: email, password: password)
                            } label: {
                                HStack(spacing: 8) {
                                    Text(langManager.text("log_in"))
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                    }
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 25)
                    .animation(.easeOut(duration: 0.7), value: animate)
                    
                    // MARK: - Registration Link
                    NavigationLink(destination: RegisterView(role: role)) {
                        HStack(spacing: 4) {
                            Text(langManager.text("dont_have_account"))
                                .foregroundColor(AppTheme.bodyText(0.8))
                            Text(langManager.text("register"))
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.primaryBrand)
                        }
                        .font(.subheadline)
                        .minimumScaleFactor(0.85)
                        .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 2)
                    .opacity(animate ? 1 : 0)
                    .animation(.easeOut(duration: 0.8), value: animate)
                    
                    // MARK: - Legal & Disclaimer Footer
                    AuthLegalFooterView()
                        .padding(.top, 4)
                        .opacity(animate ? 1 : 0)
                        .animation(.easeOut(duration: 0.9), value: animate)
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: sizeClass == .regular ? 480 : 420)
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear { animate = true }
        .navigationBarBackButtonHidden(false)
        .navigationBarTitleDisplayMode(.inline)
    }
}


