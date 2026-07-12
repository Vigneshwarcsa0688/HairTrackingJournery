import SwiftUI

struct TermsView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            AppTheme.gradient.ignoresSafeArea()
            
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
                        title: "2. Medical Disclaimer",
                        text: "Hair Journey provides educational insights and connects users with licensed professionals. It does not replace in-person medical diagnosis or treatment. Always consult a qualified doctor for medical concerns."
                    )
                    
                    section(
                        title: "3. User Responsibilities",
                        text: """
You agree to:
• Provide accurate information  
• Upload only your own hair images  
• Use the app respectfully  
• Not misuse medical advice
"""
                    )
                    
                    section(
                        title: "4. Doctor Interaction",
                        text: "Doctors provide feedback based on the information and images you upload. Hair Journey is not responsible for individual medical decisions made by users."
                    )
                    
                    section(
                        title: "5. Appointments & Recommendations",
                        text: "Appointments are subject to expert approval. Recommendations and advice are provided by designated professionals, not by the app itself."
                    )
                    
                    section(
                        title: "6. Data Usage",
                        text: "Your data is handled according to our Privacy Policy. We do not sell personal or medical information."
                    )
                    
                    section(
                        title: "7. Account Termination",
                        text: "We may suspend or terminate accounts that misuse the platform or violate these terms."
                    )
                    
                    section(
                        title: "8. Limitation of Liability",
                        text: "Hair Journey is not liable for medical outcomes, indirect damages, or issues arising from misuse of the app."
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

