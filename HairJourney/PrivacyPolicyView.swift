import SwiftUI

struct PrivacyPolicyView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            AppTheme.gradient.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    
                    // MARK: Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Privacy Policy")
                            .font(.largeTitle.bold())
                            .foregroundColor(AppTheme.titleText)
                        
                        Text("Last updated: February 2026")
                            .font(.caption)
                            .foregroundColor(AppTheme.bodyText(0.7))
                    }
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -15)
                    .animation(.easeOut(duration: 0.5), value: animate)
                    
                    policySection(
                        title: "1. Information We Collect",
                        text: """
We collect necessary account information such as your name, email address, and date of birth when you create an account. Phone number and location are entirely optional and not required to use the app.  
We also collect wellness-related inputs like optional quiz responses, progress hair images, and appointment history to support your personal hair care tracking.
"""
                    )
                    
                    policySection(
                        title: "2. How We Use Your Information",
                        text: """
Your information is used to:
• Provide hair health assessments  
• Allow experts to review your reports and images  
• Manage appointments and routines  
• Improve app performance and user experience
"""
                    )
                    
                    policySection(
                        title: "3. Hair Images & Care Data",
                        text: """
Images and quiz results you upload are shared only with registered specialists within the app for routine review.  
We do not sell or publicly share your wellness or personal data.
"""
                    )
                    
                    policySection(
                        title: "4. Data Security",
                        text: """
We implement appropriate technical and organizational measures to protect your data against unauthorized access, alteration, disclosure, or destruction.
"""
                    )
                    
                    policySection(
                        title: "5. Data Sharing",
                        text: """
We do not share your personal information with third parties except:
• When required by law  
• To provide essential services (such as secure hosting)
"""
                    )
                    
                    policySection(
                        title: "6. Your Rights",
                        text: """
You may update or delete your account information at any time from the Profile section of the app.  
Deleting your account permanently removes your personal data from our system.
"""
                    )
                    
                    policySection(
                        title: "7. Children's Privacy",
                        text: """
This app is not intended for children under 13. We do not knowingly collect data from minors.
"""
                    )
                    
                    policySection(
                        title: "8. Changes to This Policy",
                        text: """
We may update this Privacy Policy occasionally. Any changes will be reflected on this screen with a revised update date.
"""
                    )
                    
                    policySection(
                        title: "9. Contact Us",
                        text: """
If you have any questions about this Privacy Policy, please contact us at:

support@hairjourneyapp.com
"""
                    )
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { animate = true }
    }
    
    // MARK: Reusable Section
    
    func policySection(title: String, text: String) -> some View {
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

