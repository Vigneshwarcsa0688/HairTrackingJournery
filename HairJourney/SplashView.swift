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
                        .fill(AppTheme.primaryBrand.opacity(glow ? 0.25 : 0.10))
                        .frame(width: 150, height: 150)
                        .blur(radius: 25)
                        .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: glow)
                    
                    HairJourneyLogoView(size: 104, showGlow: true)
                        .scaleEffect(scale)
                        .shadow(color: AppTheme.primaryBrand.opacity(0.4), radius: 20, y: 8)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                                scale = 1.08
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

