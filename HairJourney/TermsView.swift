import SwiftUI

struct TermsView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Terms & Conditions")
                            .font(.largeTitle.bold())
                            .foregroundColor(AppTheme.titleText)
                        
                        Text("Last updated: February 2026")
                            .font(.caption)
                            .foregroundColor(AppTheme.bodyText(0.7))
                    }
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -15)
                    .animation(.easeOut(duration: 0.5), value: animate)
                    
                    section(
                        title: "1. Acceptance of Terms",
                        text: "By using the Hair Journey app, you agree to these Terms & Conditions. If you do not agree, please do not use the app."
                    )
                    
                    section(
                        title: "2. Academic Thesis Project & Wellness Disclaimer",
                        text: "Hair Journey is an academic student thesis project developed for educational habit adherence and wellness tracking. It connects members with hair care specialists for routine advice. It does not provide clinical medical diagnosis or prescription treatments. Always consult a qualified physician or dermatologist for serious medical concerns."
                    )
                    
                    section(
                        title: "3. Member Responsibilities",
                        text: """
You agree to:
• Provide accurate profile information  
• Upload only your own scalp & hair photos  
• Use the app respectfully  
• Follow recommended routines responsibly
"""
                    )
                    
                    section(
                        title: "4. Expert Guidance & Consultations",
                        text: "Hair care specialists provide routine guidance and recommendations based on information and photos shared. Members remain responsible for their personal hair care product choices."
                    )
                    
                    section(
                        title: "5. Appointments & Recommendations",
                        text: "Appointments are subject to expert confirmation. Recommendations are provided by designated specialists for routine hair care."
                    )
                    
                    section(
                        title: "6. Data Usage",
                        text: "Your data is handled securely according to our Privacy Policy. We do not sell personal information."
                    )
                    
                    section(
                        title: "7. Account Termination",
                        text: "We may suspend or terminate accounts that misuse the platform or violate these terms."
                    )
                    
                    section(
                        title: "8. Limitation of Liability",
                        text: "Hair Journey is not liable for personal care outcomes, indirect damages, or issues arising from misuse of the app."
                    )
                    
                    section(
                        title: "9. Changes to Terms",
                        text: "We may update these Terms at any time. Continued use of the app means you accept the updated terms."
                    )
                    
                    section(
                        title: "10. Contact",
                        text: "For questions regarding these terms, contact: support@hairjourneyapp.com"
                    )
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { animate = true }
    }
    
    func section(title: String, text: String) -> some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppTheme.titleText)
                
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.bodyText)
            }
        }
        .opacity(animate ? 1 : 0)
        .offset(y: animate ? 0 : 20)
        .animation(.easeOut(duration: 0.6), value: animate)
    }
}

