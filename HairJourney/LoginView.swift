import SwiftUI

struct LoginView: View {
    var role: String
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var animate = false
    @State private var isPasswordVisible = false
    
    var body: some View {
        ZStack {
            AppTheme.gradient
                .ignoresSafeArea()
            
            VStack {
                Spacer(minLength: 40)
                
                // MARK: - Title Section
                VStack(spacing: 8) {
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(.white, AppTheme.premiumAccentGradient)
                        .shadow(color: AppTheme.accent.opacity(0.3), radius: 8, y: 4)
                        .scaleEffect(animate ? 1 : 0.7)
                        .animation(.easeOut(duration: 0.6), value: animate)
                    
                    Text("Welcome Back")
                        .font(.largeTitle.bold())
                        .foregroundColor(AppTheme.titleText)

                    
                    Text("Login to continue your hair journey")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.bodyText)
                }
                .multilineTextAlignment(.center)
                .padding(.bottom, 30)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : -20)
                .animation(.easeOut(duration: 0.6), value: animate)
                
                // MARK: - Form Card
                GlassCard {
                    VStack(spacing: 18) {
                        
                        VStack(spacing: 14) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.purple)
                                TextField("Email", text: $email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .foregroundColor(AppTheme.titleText)
                            }
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.purple)
                                
                                if isPasswordVisible {
                                    TextField("Password", text: $password)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .foregroundColor(AppTheme.titleText)
                                } else {
                                    SecureField("Password", text: $password)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .foregroundColor(AppTheme.titleText)
                                }
                                
                                Button(action: {
                                    isPasswordVisible.toggle()
                                }) {
                                    Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                        .foregroundColor(AppTheme.bodyText)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                        }
                        
                        if !authVM.errorMessage.isEmpty {
                            Text(authVM.errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button {
                            guard !email.isEmpty, !password.isEmpty else {
                                authVM.errorMessage = "Please enter email and password"
                                return
                            }
                            authVM.login(email: email, password: password)
                        } label: {
                            Text("Login")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 30)
                .animation(.easeOut(duration: 0.7), value: animate)
                
                // MARK: - Links
                VStack(spacing: 10) {
                    
                    NavigationLink("Don't have an account? Register") {
                        RegisterView(role: role)
                    }
                }
                .font(.footnote)
                .foregroundColor(AppTheme.bodyText)
                .padding(.top, 20)
                .opacity(animate ? 1 : 0)
                .animation(.easeOut(duration: 0.9), value: animate)
                
                Spacer()
                
                // MARK: - Disclaimer
                Text("Disclaimer: This application is not a medical app. It is strictly an educational application developed by students of SIMATS Institute.")
                    .font(.caption2)
                    .foregroundColor(AppTheme.bodyText.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    .opacity(animate ? 1 : 0)
                    .animation(.easeOut(duration: 1.0), value: animate)
            }
            .padding()
            .frame(maxWidth: sizeClass == .regular ? 480 : 400)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .onAppear { animate = true }
        .navigationBarBackButtonHidden(false)
        .navigationBarTitleDisplayMode(.inline)
    }
}

