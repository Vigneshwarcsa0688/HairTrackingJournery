import SwiftUI

// MARK: - Identifiable URL wrapper
struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

// MARK: - Search Bar Component
struct SearchBar: View {
    @Binding var text: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundColor(AppTheme.bodyText)
            TextField("Search...", text: $text)
                .foregroundColor(AppTheme.titleText)
                .autocorrectionDisabled()
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.bodyText(0.5))
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.6))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.8), lineWidth: 1))
        .padding(.horizontal, 4)
    }
}

// MARK: - Shared Utilities
func formatProgressTag(_ tag: String) -> String {
    switch tag {
    case "Baseline": return "Baseline Phase"
    case "3 Months": return "3 Months Progress"
    case "6 Months": return "6 Months Progress"
    default: return tag
    }
}

func formatDate(_ dateString: String) -> String {
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    // Try long format first
    if let date = inputFormatter.date(from: dateString) {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d, yyyy"
        return outputFormatter.string(from: date)
    }
    
    // Try short format (capture_date)
    inputFormatter.dateFormat = "yyyy-MM-dd"
    if let date = inputFormatter.date(from: dateString) {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d, yyyy"
        return outputFormatter.string(from: date)
    }
    
    return dateString
}

// MARK: - View Angle Selector (replaces buggy Picker in compare views)
struct ViewAngleSelector: View {
    let options: [String]
    @Binding var selected: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selected = option
                        }
                    } label: {
                        Text(option)
                            .font(.caption.bold())
                            .foregroundColor(selected == option ? .white : AppTheme.titleText)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(
                                selected == option
                                    ? AnyView(AppTheme.premiumAccentGradient)
                                    : AnyView(Color.white.opacity(0.5))
                            )
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        selected == option ? Color.clear : Color.white.opacity(0.6),
                                        lineWidth: 1
                                    )
                            )
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }
}

// MARK: - Section Header Component
struct SectionHeaderView: View {
    var title: String
    var subtitle: String? = nil
    var icon: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 3) {
                if let subtitle = subtitle {
                    Text(subtitle.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.2)
                        .foregroundColor(AppTheme.primaryBrand)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                HStack(spacing: 6) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppTheme.primaryBrand)
                    }
                    Text(title)
                        .font(.title3.bold())
                        .foregroundColor(AppTheme.titleText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            Spacer()
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.caption.bold())
                        .foregroundColor(AppTheme.primaryBrand)
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 4)
    }
}

// MARK: - Status Badge Component
struct AppStatusBadge: View {
    let status: String
    
    var color: Color {
        switch status.lowercased() {
        case "approved", "completed", "active", "target met":
            return AppTheme.emeraldMint
        case "rejected", "missed", "cancelled":
            return AppTheme.coralRose
        case "pending", "awaiting review", "partial":
            return AppTheme.amberWarm
        default:
            return AppTheme.primaryBrand
        }
    }
    
    var icon: String {
        switch status.lowercased() {
        case "approved", "completed", "active", "target met":
            return "checkmark.circle.fill"
        case "rejected", "missed", "cancelled":
            return "xmark.circle.fill"
        case "pending", "awaiting review", "partial":
            return "clock.fill"
        default:
            return "info.circle.fill"
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
            Text(status)
                .font(.system(size: 11, weight: .bold))
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(color.opacity(0.14))
        .foregroundColor(color)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Symmetrical Auth Legal & Privacy Footer
struct AuthLegalFooterView: View {
    var showRegistrationAgreement: Bool = false
    var showAboutLink: Bool = true
    
    @ObservedObject private var langManager = AppLanguageManager.shared
    
    var body: some View {
        VStack(spacing: 8) {
            
            // 1. Interactive Terms & Privacy Agreement (For Registration Screen)
            if showRegistrationAgreement {
                VStack(spacing: 4) {
                    Text("By creating an account, you agree to our")
                        .font(.caption2)
                        .foregroundColor(AppTheme.bodyText(0.75))
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 6) {
                        NavigationLink(destination: TermsView()) {
                            HStack(spacing: 3) {
                                Image(systemName: "doc.plaintext.fill")
                                    .font(.system(size: 9))
                                Text(langManager.text("terms_of_service"))
                                    .font(.caption2.weight(.bold))
                                    .underline()
                            }
                            .foregroundColor(AppTheme.primaryBrand)
                        }
                        
                        Text("•")
                            .font(.caption2)
                            .foregroundColor(AppTheme.bodyText(0.35))
                        
                        NavigationLink(destination: PrivacyPolicyView()) {
                            HStack(spacing: 3) {
                                Image(systemName: "hand.raised.fill")
                                    .font(.system(size: 9))
                                Text(langManager.text("privacy_policy"))
                                    .font(.caption2.weight(.bold))
                                    .underline()
                            }
                            .foregroundColor(AppTheme.primaryBrand)
                        }
                    }
                    .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 8)
            } else {
                // 2. Primary Navigation Legal Links (For Login & Login Choice Screens)
                HStack(spacing: 12) {
                    NavigationLink(destination: PrivacyPolicyView()) {
                        HStack(spacing: 4) {
                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 9))
                            Text(langManager.text("privacy_policy"))
                                .font(.caption2.weight(.semibold))
                        }
                        .foregroundColor(AppTheme.primaryBrand)
                    }
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundColor(AppTheme.bodyText(0.35))
                    
                    NavigationLink(destination: TermsView()) {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 9))
                            Text(langManager.text("terms_of_service"))
                                .font(.caption2.weight(.semibold))
                        }
                        .foregroundColor(AppTheme.primaryBrand)
                    }
                    
                    if showAboutLink {
                        Text("•")
                            .font(.caption2)
                            .foregroundColor(AppTheme.bodyText(0.35))
                        
                        NavigationLink(destination: AboutView()) {
                            HStack(spacing: 4) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 9))
                                Text(langManager.text("about"))
                                    .font(.caption2.weight(.semibold))
                            }
                            .foregroundColor(AppTheme.primaryBrand)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.75))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.02), radius: 4, y: 1)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            // 3. Academic & Medical Disclaimer Card
            VStack(spacing: 3) {
                HStack(spacing: 5) {
                    Image(systemName: "shield.checkmark.fill")
                        .font(.system(size: 10.5, weight: .bold))
                        .foregroundColor(AppTheme.primaryBrand)
                    
                    Text("Academic Student Thesis Project")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppTheme.titleText)
                }
                
                Text("Educational hair wellness & habit tracking platform developed by students of SIMATS Institute.\nAlways seek a doctor's advice in addition to using this app and before making any medical decisions.")
                    .font(.system(size: 9.5))
                    .foregroundColor(AppTheme.bodyText(0.75))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.6))
            .cornerRadius(11)
            .overlay(
                RoundedRectangle(cornerRadius: 11)
                    .stroke(Color.black.opacity(0.04), lineWidth: 1)
            )
        }
        .padding(.horizontal, 4)
        .padding(.top, 2)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}



