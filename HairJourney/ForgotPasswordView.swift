import SwiftUI

struct ForgotPasswordView: View {
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
            AppTheme.gradient.ignoresSafeArea()
            
            VStack {
                Spacer(minLength: 40)
                
                // MARK: Header
                VStack(spacing: 8) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 65))
                        .foregroundColor(AppTheme.bodyText)
                        .scaleEffect(animate ? 1 : 0.7)
                        .animation(.easeOut(duration: 0.6), value: animate)
                    
                    Text("Forgot Password?")
                        .font(.largeTitle.bold())
                        .foregroundColor(AppTheme.titleText)

                    
                    Text("Recover your account securely")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.bodyText)
                }
                .multilineTextAlignment(.center)
                .padding(.bottom, 30)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : -20)
                .animation(.easeOut(duration: 0.6), value: animate)
                
                // MARK: Card
                GlassCard {
                    VStack(spacing: 18) {
                        
                        // Email Field
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.purple)
                            TextField("Enter Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .foregroundColor(AppTheme.titleText)
                        }
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        
                        Button("Verify Email") {
                            verifyEmail()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        
                        Divider().padding(.vertical, 4)
                        
                        // New Password
                        HStack {
                            Image(systemName: "key.fill")
                                .foregroundColor(.purple)
                                SecureField("New Password", text: $newPassword)
                                    .foregroundColor(AppTheme.titleText)
                        }
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        
                        Button("Reset Password") {
                            resetPassword()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        
                        if !message.isEmpty {
                            Text(message)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.green)
                                .padding(.top, 6)
                        }
                    }
                }
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 30)
                .animation(.easeOut(duration: 0.7), value: animate)
                
                Spacer()
            }
            .padding()
        }
        .onAppear { animate = true }
        .navigationTitle("Recover Account")
        .navigationBarTitleDisplayMode(.inline)
    }
}

