import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.75
    @State private var glow = false
    @State private var fadeIn = false
    
    var body: some View {
        ZStack {
            AppTheme.gradient.ignoresSafeArea()
            
            // Soft floating background circles
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 260)
                .blur(radius: 50)
                .offset(x: -120, y: -220)
            
            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 300)
                .blur(radius: 60)
                .offset(x: 140, y: 260)
            
            VStack(spacing: 24) {
                
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(glow ? 0.25 : 0.12))
                        .frame(width: 140, height: 140)
                        .blur(radius: 20)
                        .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: glow)
                    
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 95))
                        .foregroundStyle(.white, AppTheme.premiumAccentGradient)
                        .scaleEffect(scale)
                        .shadow(color: AppTheme.accent.opacity(0.4), radius: 18, y: 8)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                                scale = 1.1
                                glow = true
                            }
                        }
                }
                
                Text("HairJourneyTracker")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(AppTheme.titleText)
                    .opacity(fadeIn ? 1 : 0)
                    .offset(y: fadeIn ? 0 : 15)
                    .animation(.easeOut(duration: 1).delay(0.3), value: fadeIn)
                
                Text("Your Smart Hair Care Companion")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.bodyText(0.85))
                    .opacity(fadeIn ? 1 : 0)
                    .offset(y: fadeIn ? 0 : 10)
                    .animation(.easeOut(duration: 1).delay(0.6), value: fadeIn)
            }
            .multilineTextAlignment(.center)
            .padding()
        }
        .onAppear {
            fadeIn = true
        }
    }
}

