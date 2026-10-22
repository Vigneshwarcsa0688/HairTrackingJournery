import SwiftUI

struct AboutUsView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About Hair Journey")
                            .font(.largeTitle.bold())
                            .foregroundColor(AppTheme.titleText)
                        
                        Text("Your personal hair health companion")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.bodyText)
                    }
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -15)
                    .animation(.easeOut(duration: 0.5), value: animate)
                    
                    infoSection(
                        title: "Our Mission",
                        text: "Hair Journey helps members understand, track, and improve their hair wellness routines using technology and specialist guidance."
                    )
                    
                    infoSection(
                        title: "Academic Thesis Project",
                        text: "Hair Journey is an academic student thesis project developed for educational habit adherence and wellness tracking. It does not provide medical diagnoses, clinical treatment, or prescriptions."
                    )
                    
                    infoSection(
                        title: "What We Do",
                        text: """
• Provide hair health quizzes and assessments  
• Allow members to track hair growth with photos  
• Connect members with qualified hair care experts  
• Offer personalized feedback and routine recommendations
"""
                    )
                    
                    infoSection(
                        title: "Why Hair Journey?",
                        text: "Hair concerns can affect confidence and well-being. Our goal is to make personalized hair care guidance accessible, convenient, and empowering."
                    )
                    
                    infoSection(
                        title: "Specialist Collaboration",
                        text: "We work with experienced hair care specialists who review routine reports and scalp photos to provide safe and personalized recommendations."
                    )
                    
                    infoSection(
                        title: "Your Privacy Matters",
                        text: "We prioritize data protection and never sell your personal information."
                    )
                    
                    infoSection(
                        title: "Contact Us",
                        text: "Have questions or feedback? We'd love to hear from you.\n\nsupport@hairjourneyapp.com"
                    )
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { animate = true }
    }
    
    func infoSection(title: String, text: String) -> some View {
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

