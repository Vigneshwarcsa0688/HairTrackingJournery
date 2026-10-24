import SwiftUI

struct ForgotPasswordView: View {
    @ObservedObject private var langManager = AppLanguageManager.shared
    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var email = ""
    @State private var newPassword = ""
    @State private var message = ""
    @State private var animate = false
    
    struct EmailCheckRequest: Codable { let email: String }
    struct ResetRequest: Codable { let email: String; let password: String }
    
    func verifyEmail() {
        guard let url = URL(string: APIService.baseURL + "check_email.php") else { return }
        let body = EmailCheckRequest(email: email)
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: req) { _, _, _ in
            DispatchQueue.main.async {
                message = "✅ Email verified. Now set a new password."
            }
        }.resume()
    }
    
    func resetPassword() {
        guard let url = URL(string: APIService.baseURL + "reset_password.php") else { return }
        let body = ResetRequest(email: email, password: newPassword)
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: req) { _, _, _ in
            DispatchQueue.main.async {
                message = "🎉 Password reset successful!"
            }
        }.resume()
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
                                
                                Image(systemName: "lock.rotation")
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
                                Text(langManager.text("reset_password"))
                                    .font(.system(size: AppTheme.titleFontSize(sizeClass), weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.titleText)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                
                                Text(langManager.text("reset_password_desc"))
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.bodyText)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.85)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animate)
                    
                    // Reset Form Card
                    GlassCard(cornerRadius: 24, padding: 20) {
                        VStack(spacing: 16) {
                            
                            // Step 1: Email
                            VStack(alignment: .leading, spacing: 6) {
                                Text(langManager.text("step1_verify_email"))
                                    .font(.caption.bold())
                                    .foregroundColor(AppTheme.bodyText)
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "envelope.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(AppTheme.primaryBrand)
                                        .frame(width: 24)
                                    
                                    TextField(langManager.text("email_address"), text: $email)
                                        .font(.subheadline)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .foregroundColor(AppTheme.titleText)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                                )
                                
                                Button {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    verifyEmail()
                                } label: {
                                    Text(langManager.text("verify_email_btn"))
                                }
                                .buttonStyle(SecondaryButtonStyle())
                                .disabled(email.isEmpty)
                                .padding(.top, 2)
                            }
                            
                            Divider().opacity(0.5).padding(.vertical, 4)
                            
                            // Step 2: New Password
                            VStack(alignment: .leading, spacing: 6) {
                                Text(langManager.text("step2_new_password"))
                                    .font(.caption.bold())
                                    .foregroundColor(AppTheme.bodyText)
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "key.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(AppTheme.primaryBrand)
                                        .frame(width: 24)
                                    
                                    SecureField(langManager.text("new_password_placeholder"), text: $newPassword)
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.titleText)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                                )
                                
                                Button {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    resetPassword()
                                } label: {
                                    Text(langManager.text("update_password_btn"))
                                }
                                .buttonStyle(PrimaryButtonStyle())
                                .disabled(newPassword.isEmpty)
                                .padding(.top, 2)
                            }
                            
                            if !message.isEmpty {
                                HStack(spacing: 8) {
                                    Image(systemName: message.contains("✅") || message.contains("🎉") ? "checkmark.circle.fill" : "info.circle.fill")
                                    Text(message)
                                }
                                .font(.caption.bold())
                                .foregroundColor(message.contains("✅") || message.contains("🎉") ? .green : .red)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.black.opacity(0.04))
                                .cornerRadius(10)
                                .transition(.opacity)
                            }
                        }
                    }
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 30)
                    // MARK: - Legal Footer
                    AuthLegalFooterView()
                        .padding(.top, 10)
                        .opacity(animate ? 1 : 0)
                        .animation(.easeOut(duration: 0.8), value: animate)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear { animate = true }
        .navigationTitle("Recover Account")
        .navigationBarTitleDisplayMode(.inline)
    }
}

