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
        sizeClass == .regular ? 950 : 600
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
}

