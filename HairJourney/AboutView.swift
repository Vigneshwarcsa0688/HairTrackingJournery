import SwiftUI

struct AboutView: View {
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // MARK: - Header
                    VStack(spacing: 16) {
                        HairJourneyLogoView(size: 78, showGlow: true)
                            .padding(.top, 20)
                        
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
                            
                            Text("HairJourney is a comprehensive tracking application designed to help members monitor their hair wellness routines, while facilitating consultation with hair care experts.")
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
                            
                            featureRow(icon: "camera.viewfinder", title: "Progress Photography", desc: "Upload multi-angle photos of scalp and hair progress.")
                            featureRow(icon: "list.clipboard.fill", title: "Hair Assessments", desc: "Evaluate your hair health using structured assessment patterns.")
                            featureRow(icon: "sparkles", title: "Routine Management", desc: "Log and track the daily usage of designated hair serums.")
                            featureRow(icon: "person.badge.shield.checkmark.fill", title: "Expert Collaboration", desc: "Connect with hair care experts for routine guidance.")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // MARK: - Health Disclaimer
                    GlassCard {
                        VStack(alignment: .center, spacing: 14) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.orange)
                            
                            Text("Academic Student Thesis Project")
                                .font(.headline.bold())
                                .foregroundColor(AppTheme.titleText)
                            
                            Text("HairJourney is an academic final-year student thesis project developed for educational wellness and hair care habit tracking.\n\nAll assessments, tracking features, and care specialist guidance provided are strictly for personal cosmetic tracking and wellness education. This app does not provide clinical medical diagnosis, clinical treatment, or medical prescriptions. Always seek a doctor's advice in addition to using this app and before making any medical decisions.")
                                .font(.caption)
                                .foregroundColor(AppTheme.bodyText)
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
