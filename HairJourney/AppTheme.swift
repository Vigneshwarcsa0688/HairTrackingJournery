import SwiftUI

struct AppTheme {
    
    // 🌈 MAIN BACKGROUND (Soft Light Gradient for Premium Medical Feel)
    static let gradient = LinearGradient(
        colors: [
            Color(red: 0.95, green: 0.97, blue: 1.00),  // very light ice blue
            Color(red: 0.97, green: 0.94, blue: 0.99),  // subtle lavender pearl
            Color(red: 0.94, green: 0.98, blue: 0.97)   // faint seafoam mint
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - TEXT COLORS (No harsh black)
    
    /// Main headings (deep bluish instead of black)
    static let titleText = Color(red: 0.12, green: 0.18, blue: 0.35)
    
    /// Normal readable text
    static let bodyText = Color(red: 0.20, green: 0.25, blue: 0.40)
    
    /// Allows usage like AppTheme.bodyText(0.7)
    static func bodyText(_ opacity: Double) -> Color {
        Color(red: 0.20, green: 0.25, blue: 0.40).opacity(opacity)
    }
    
    /// Secondary faded text
    static let secondaryText = Color.gray.opacity(0.8)
    
    /// Text used on darker elements if needed
    static let lightText = Color.white
    
    /// Slightly darker text for cards if required
    static let darkText = Color(red: 0.18, green: 0.22, blue: 0.38)
    
    
    // MARK: - GLASS CARD STYLE (for light background)
    
    static let glassFill = Color.white.opacity(0.55)
    static let glassStroke = Color.white.opacity(0.9)
    
    
    // MARK: - ACCENTS
    
    static let accent = Color(red: 0.28, green: 0.50, blue: 0.90)   // deep soft blue
    static let success = Color(red: 0.15, green: 0.70, blue: 0.50) // medical teal-green
    static let error = Color(red: 0.90, green: 0.35, blue: 0.40)   // soft coral red
    static let warning = Color(red: 0.95, green: 0.65, blue: 0.20) // warm amber

    // 🎨 DYNAMIC VISUALIZATIONS
    
    static let premiumAccentGradient = LinearGradient(
        colors: [Color(red: 0.28, green: 0.50, blue: 0.90), Color(red: 0.50, green: 0.40, blue: 0.85)],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let complianceGradient = AngularGradient(
        gradient: Gradient(colors: [
            Color(red: 0.15, green: 0.70, blue: 0.50), // teal green
            Color(red: 0.10, green: 0.85, blue: 0.65), // bright cyan-mint
            Color(red: 0.40, green: 0.90, blue: 0.50), // lime mint
            Color(red: 0.15, green: 0.70, blue: 0.50)  // back to start
        ]), 
        center: .center
    )
    
    // MARK: - RESPONSIVE HELPERS
    
    static func maxContentWidth(_ sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        sizeClass == .regular ? 850 : .infinity
    }
    
    static func dashboardColumns(_ sizeClass: UserInterfaceSizeClass?) -> [GridItem] {
        sizeClass == .regular ? 
            [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)] : 
            [GridItem(.flexible())]
    }
    
    static func statsColumns(_ sizeClass: UserInterfaceSizeClass?) -> [GridItem] {
        sizeClass == .regular ? 
            [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())] : 
            [GridItem(.flexible()), GridItem(.flexible())]
    }
    
    // Responsive Typography Sizes for iPhones & iPads
    static func heroTitleSize(_ sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        sizeClass == .regular ? 38 : 28
    }
    
    static func titleFontSize(_ sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        sizeClass == .regular ? 32 : 24
    }
    
    static func subheadFontSize(_ sizeClass: UserInterfaceSizeClass?) -> CGFloat {
        sizeClass == .regular ? 16 : 14
    }
    // MARK: - PREMIUM PALETTE (App Store Health & Wellness Grade)
    static let primaryBrand = Color(red: 0.18, green: 0.42, blue: 0.88)       // Vibrant Sapphire
    static let primaryDark  = Color(red: 0.08, green: 0.15, blue: 0.38)       // Deep Indigo Slate
    static let primaryLight = Color(red: 0.90, green: 0.94, blue: 1.00)       // Ice Sapphire
    static let emeraldMint  = Color(red: 0.05, green: 0.68, blue: 0.48)       // Vivid Emerald Mint
    static let coralRose    = Color(red: 0.94, green: 0.28, blue: 0.38)       // Vivid Rose Coral
    static let amberWarm    = Color(red: 0.96, green: 0.58, blue: 0.12)       // Warm Amber Sun
    static let irisPurple   = Color(red: 0.48, green: 0.36, blue: 0.88)       // Royal Iris

    // MARK: - GRADIENTS
    static let brandGradient = LinearGradient(
        colors: [Color(red: 0.18, green: 0.42, blue: 0.92), Color(red: 0.42, green: 0.34, blue: 0.88)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let mintGradient = LinearGradient(
        colors: [Color(red: 0.05, green: 0.72, blue: 0.50), Color(red: 0.10, green: 0.85, blue: 0.65)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let sunsetGradient = LinearGradient(
        colors: [Color(red: 0.98, green: 0.45, blue: 0.25), Color(red: 0.96, green: 0.22, blue: 0.45)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let ambientCardFill = LinearGradient(
        colors: [Color.white.opacity(0.85), Color.white.opacity(0.65)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - CORNER RADII
    static let radiusLg: CGFloat = 22
    static let radiusMd: CGFloat = 16
    static let radiusSm: CGFloat = 10
}

// MARK: - Ambient Living App Background
struct AppBackgroundView: View {
    @State private var pulse = false
    
    var body: some View {
        ZStack {
            // Base subtle multi-stop gradient
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.97, blue: 1.00),
                    Color(red: 0.97, green: 0.95, blue: 0.99),
                    Color(red: 0.94, green: 0.98, blue: 0.97)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Luminous ambient orbs for depth
            Circle()
                .fill(Color(red: 0.35, green: 0.55, blue: 0.95).opacity(0.12))
                .frame(width: 340, height: 340)
                .blur(radius: 70)
                .offset(x: -120, y: -260)
                .scaleEffect(pulse ? 1.08 : 0.95)
            
            Circle()
                .fill(Color(red: 0.60, green: 0.40, blue: 0.90).opacity(0.10))
                .frame(width: 300, height: 300)
                .blur(radius: 65)
                .offset(x: 140, y: 180)
                .scaleEffect(pulse ? 0.95 : 1.08)
                
            Circle()
                .fill(Color(red: 0.15, green: 0.75, blue: 0.60).opacity(0.08))
                .frame(width: 260, height: 260)
                .blur(radius: 60)
                .offset(x: -100, y: 320)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

// MARK: - Premium Animation Effects & Modifiers

// 1. Shimmer / Sheen Sweep Effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1.2
    var duration: Double = 2.4
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.40),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .rotationEffect(.degrees(25))
                    .offset(x: phase * geo.size.width * 2)
                    .frame(width: geo.size.width)
                    .mask(content)
                }
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1.2
                }
            }
    }
}

// 2. Breathing Pulse Glow Effect
struct PulsingGlowModifier: ViewModifier {
    let color: Color
    var radius: CGFloat = 8
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(isPulsing ? 0.45 : 0.15), radius: isPulsing ? radius * 1.5 : radius, y: 2)
            .scaleEffect(isPulsing ? 1.02 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
    }
}

// 3. Gentle Floating Levitation Effect
struct FloatingModifier: ViewModifier {
    var offsetY: CGFloat = 4
    var duration: Double = 2.6
    @State private var isFloating = false
    
    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -offsetY : offsetY)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    isFloating = true
                }
            }
    }
}

// 4. Interactive Card Tap Button Style with Spring Scale & Tactile Haptic
struct InteractiveCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.975 : 1.0)
            .brightness(configuration.isPressed ? -0.015 : 0)
            .animation(.spring(response: 0.22, dampingFraction: 0.7), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { isPressed in
                if isPressed {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
    }
}

extension View {
    func shimmering(duration: Double = 2.4) -> some View {
        self.modifier(ShimmerModifier(duration: duration))
    }
    
    func pulseGlow(color: Color = AppTheme.primaryBrand, radius: CGFloat = 8) -> some View {
        self.modifier(PulsingGlowModifier(color: color, radius: radius))
    }
    
    func floating(offsetY: CGFloat = 4, duration: Double = 2.6) -> some View {
        self.modifier(FloatingModifier(offsetY: offsetY, duration: duration))
    }
    
    /// Unifies text alignment to single consistent reading alignment and scales cleanly for all iPhone/iPad models
    func fitText(alignment: TextAlignment = .leading, minScale: CGFloat = 0.75) -> some View {
        self
            .multilineTextAlignment(alignment)
            .minimumScaleFactor(minScale)
    }
}


