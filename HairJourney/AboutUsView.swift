import SwiftUI

struct AboutUsView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            AppTheme.gradient.ignoresSafeArea()
            
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
                        text: "Hair Journey helps people understand, track, and improve their hair health using technology and expert medical guidance."
                    )
                    
                    infoSection(
                        title: "What We Do",
                        text: """
• Provide hair health quizzes and assessments  
• Allow users to track hair growth with photos  
• Connect users with qualified doctors  
• Offer professional feedback and recommendations
"""
                    )
                    
                    infoSection(
                        title: "Why Hair Journey?",
                        text: "Hair concerns can affect confidence and well-being. Our goal is to make professional hair care guidance accessible, convenient, and personalized."
                    )
                    
                    infoSection(
                        title: "Medical Collaboration",
                        text: "We work with licensed doctors who review reports and hair images to provide safe and professional recommendations."
                    )
                    
                    infoSection(
                        title: "Your Privacy Matters",
                        text: "We prioritize data protection and never sell your personal or medical information."
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

