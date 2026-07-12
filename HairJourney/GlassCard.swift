import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Base blur for medical cleanliness
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(Color.white.opacity(0.2))
                )
            
            // Bright white overlay top layer
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(0.6))
                .background(.ultraThinMaterial)

            // Dynamic border for reflective premium look
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.9),
                            Color.white.opacity(0.2),
                            Color.white.opacity(0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
            
            content
                .padding(18)
        }
        .shadow(color: Color(red: 0.12, green: 0.18, blue: 0.35).opacity(0.06), radius: 15, x: 0, y: 8)
        .shadow(color: Color(red: 0.12, green: 0.18, blue: 0.35).opacity(0.04), radius: 30, x: 0, y: 15)
        .padding(.horizontal, 4)
    }
}

