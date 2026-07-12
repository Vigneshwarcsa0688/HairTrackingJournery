import SwiftUI

struct LoginChoiceView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            AppTheme.gradient.ignoresSafeArea()
            
            VStack(spacing: 40) {
                
                Spacer()
                
                // MARK: App Branding
                VStack(spacing: 14) {
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 85))
                        .foregroundStyle(.white, AppTheme.premiumAccentGradient)
                        .shadow(color: AppTheme.accent.opacity(0.3), radius: 10, y: 5)
                        .scaleEffect(animate ? 1 : 0.6)
                        .animation(.spring(response: 0.7, dampingFraction: 0.6), value: animate)
                    
                    Text("HairJourney")
                        .font(.largeTitle.bold())
                        .foregroundColor(AppTheme.titleText)
                    
                    Text("Smart Hair Care & Growth Tracking")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.bodyText(0.8))
                }
                .multilineTextAlignment(.center)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : -25)
                .animation(.easeOut(duration: 0.6), value: animate)
                
                // MARK: Login Card
                GlassCard {
                    VStack(spacing: 20) {
                        
                        NavigationLink(destination: LoginView(role: "user")) {
                            Label("Login as User", systemImage: "person.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        
                        NavigationLink(destination: LoginView(role: "doctor")) {
                            Label("Login as Expert", systemImage: "stethoscope")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                }
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 30)
                .animation(.easeOut(duration: 0.7), value: animate)
                
                Spacer()
                
                // MARK: Footer
                Text("Your journey to healthier hair starts here")
                    .font(.footnote)
                    .foregroundColor(AppTheme.bodyText(0.7))
                    .padding(.bottom, 25)
                    .opacity(animate ? 1 : 0)
                    .animation(.easeIn(duration: 1), value: animate)
            }
            .padding()
        }
        .onAppear { animate = true }
    }
}

