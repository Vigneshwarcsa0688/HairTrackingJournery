import SwiftUI

// MARK: - Proprietary HairJourney Brand Emblem & Logo
struct HairJourneyLogoView: View {
    var size: CGFloat = 64
    var showGlow: Bool = true
    @State private var pulseGlow = false
    
    var body: some View {
        ZStack {
            // Ambient Aura Halo
            if showGlow {
                RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                    .fill(AppTheme.brandGradient.opacity(0.35))
                    .frame(width: size * 1.18, height: size * 1.18)
                    .blur(radius: size * 0.16)
                    .scaleEffect(pulseGlow ? 1.08 : 0.96)
            }
            
            // Unique Trichology Regrowth Brand Emblem
            Image("HairJourneyLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.24, style: .continuous))
                .shadow(color: AppTheme.primaryBrand.opacity(0.38), radius: size * 0.12, y: size * 0.06)
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.85), Color.white.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: max(1, size * 0.022)
                        )
                )
        }
        .onAppear {
            if showGlow {
                withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                    pulseGlow = true
                }
            }
        }
    }
}
