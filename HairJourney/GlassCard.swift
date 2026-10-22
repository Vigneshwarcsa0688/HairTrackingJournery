import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = 22
    var paddingAmount: CGFloat = 18
    
    init(cornerRadius: CGFloat = 22, padding: CGFloat = 18, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.paddingAmount = padding
        self.content = content()
    }
    
    init(cornerRadius: CGFloat, paddingAmount: CGFloat, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.paddingAmount = paddingAmount
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Ultra-clean frosted glass backdrop
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
            
            // Soft translucent white highlight layer
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.70),
                            Color.white.opacity(0.40)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Specular border for crisp edge definition
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.95),
                            Color.white.opacity(0.30),
                            Color.white.opacity(0.85)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
            
            content
                .padding(paddingAmount)
        }
        // Multi-level soft shadows (ambient + directional)
        .shadow(color: Color(red: 0.10, green: 0.15, blue: 0.30).opacity(0.04), radius: 6, x: 0, y: 3)
        .shadow(color: Color(red: 0.10, green: 0.15, blue: 0.30).opacity(0.06), radius: 18, x: 0, y: 10)
        .padding(.horizontal, 2)
    }
}


