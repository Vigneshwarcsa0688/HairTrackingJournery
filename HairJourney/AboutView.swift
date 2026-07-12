import SwiftUI

struct AboutView: View {
    var body: some View {
        ZStack {
            AppTheme.gradient.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // MARK: - Header
                    VStack(spacing: 16) {
                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 70))
                            .foregroundStyle(.white, AppTheme.premiumAccentGradient)
                            .padding(.top, 20)
                            .shadow(color: AppTheme.accent.opacity(0.3), radius: 10, y: 5)
                        
                        Text("HairJourney")
                            .font(.largeTitle.bold())
                            .foregroundColor(AppTheme.titleText)
                        
                        Text("Version 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.bodyText)
                    }
                    
                    // MARK: - App Description
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("About This App")
                                .font(.title3.bold())
                                .foregroundColor(AppTheme.titleText)
                            
                            Text("HairJourney is a comprehensive tracking application designed to help users monitor their hair health and routines, while facilitating communication with clinical advisors.")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.bodyText)
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // MARK: - Key Features
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Key Features")
                                .font(.title3.bold())
                                .foregroundColor(AppTheme.titleText)
                            
                            featureRow(icon: "camera.viewfinder", title: "Clinical Photography", desc: "Upload multi-angle photos of scalp progress.")
                            featureRow(icon: "list.clipboard.fill", title: "Hair Quizzes", desc: "Evaluate your hair health using clinical scaling patterns.")
                            featureRow(icon: "pills.fill", title: "Routine Management", desc: "Log and track the daily usage of designated hair serums.")
                            featureRow(icon: "stethoscope", title: "Clinical Collaboration", desc: "Connect with medical professionals for feedback.")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // MARK: - Medical Disclaimer
                    GlassCard {
                        VStack(alignment: .center, spacing: 14) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.orange)
                            
                            Text("Medical Disclaimer")
                                .font(.headline.bold())
                                .foregroundColor(AppTheme.titleText)
                            
                            Text("This application is not a medical app.\n\nIt is strictly an educational application developed by students of SIMATS Institute.\n\nThe content, features, and functionality provided are not intended to be a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition.")
                                .font(.caption)
                                .foregroundColor(AppTheme.error)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("About")
                    .font(.headline.bold())
                    .foregroundColor(AppTheme.titleText)
            }
        }
    }
    
    @ViewBuilder
    private func featureRow(icon: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppTheme.accent)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(AppTheme.titleText)
                Text(desc)
                    .font(.caption)
                    .foregroundColor(AppTheme.bodyText)
                    .lineSpacing(2)
            }
        }
    }
}

#Preview {
    NavigationView {
        AboutView()
    }
}
