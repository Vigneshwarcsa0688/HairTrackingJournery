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
