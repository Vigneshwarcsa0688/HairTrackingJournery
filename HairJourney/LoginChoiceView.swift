import SwiftUI

import SwiftUI

struct LoginChoiceView: View {
    @State private var animate = false
    @State private var pulseAura = false
    @Environment(\.horizontalSizeClass) var sizeClass
    @ObservedObject private var langManager = AppLanguageManager.shared
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 32) {
                    
                    Spacer(minLength: 20)
                    
                    // MARK: - App Branding Hero
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 16) {
                            HairJourneyLogoView(size: 64, showGlow: true)
                                .scaleEffect(pulseAura ? 1.05 : 0.98)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("HairJourney")
                                    .font(.system(size: AppTheme.heroTitleSize(sizeClass), weight: .heavy, design: .rounded))
                                    .foregroundColor(AppTheme.titleText)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                
                                Text(langManager.text("tagline"))
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(AppTheme.bodyText(0.85))
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)
                            }
                        }
                        
                        // Feature Highlight Pills
                        HStack(spacing: 8) {
                            featurePill(icon: "camera.fill", title: langManager.text("photo_journey"))
                            featurePill(icon: "person.badge.shield.checkmark.fill", title: langManager.text("expert_care"))
                            featurePill(icon: "flame.fill", title: langManager.text("daily_habits"))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animate)
                    
                    // MARK: - Role Selection Cards
                    VStack(alignment: .leading, spacing: 16) {
                        Text(langManager.text("select_portal"))
                            .font(.system(size: 11, weight: .heavy))
                            .tracking(1.4)
                            .foregroundColor(AppTheme.bodyText(0.65))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                        
                        // Member Portal Card
                        NavigationLink(destination: LoginView(role: "user")) {
                            RolePortalCard(
                                title: langManager.text("member_user"),
                                subtitle: langManager.text("member_portal_desc"),
                                icon: "person.fill",
                                gradient: AppTheme.brandGradient,
                                badgeText: langManager.text("member_badge")
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Specialist Portal Card
                        NavigationLink(destination: LoginView(role: "doctor")) {
                            RolePortalCard(
                                title: langManager.text("expert_specialist"),
                                subtitle: langManager.text("expert_portal_desc"),
                                icon: "person.badge.shield.checkmark.fill",
                                gradient: LinearGradient(
                                    colors: [Color(red: 0.05, green: 0.68, blue: 0.58), Color(red: 0.18, green: 0.50, blue: 0.88)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                badgeText: langManager.text("expert_badge")
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 25)
                    .animation(.easeOut(duration: 0.7), value: animate)
                    
                    Spacer(minLength: 30)
                    
                    // MARK: - Footer & Legal Links
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            NavigationLink(langManager.text("privacy_policy"), destination: PrivacyPolicyView())
                            Text("•")
                            NavigationLink(langManager.text("terms_of_service"), destination: TermsView())
                            Text("•")
                            NavigationLink(langManager.text("about"), destination: AboutView())
                        }
                        .font(.caption.weight(.medium))
                        .foregroundColor(AppTheme.primaryBrand)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                        
                        Text("Educational hair care & wellness platform developed by SIMATS Institute")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.bodyText(0.6))
                            .minimumScaleFactor(0.85)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
                    .padding(.bottom, 20)
                    .opacity(animate ? 1 : 0)
                    .animation(.easeIn(duration: 0.8), value: animate)
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: AppTheme.maxContentWidth(sizeClass))
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        }
        .onAppear {
            animate = true
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                pulseAura = true
            }
        }
    }
    
    @ViewBuilder
    private func featurePill(icon: String, title: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(AppTheme.primaryBrand)
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(AppTheme.titleText)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.7))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.white, lineWidth: 1))
        .shadow(color: Color.black.opacity(0.03), radius: 4, y: 2)
    }
}

// MARK: - Role Portal Card Component
struct RolePortalCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: LinearGradient
    let badgeText: String
    @State private var isHovered = false
    
    var body: some View {
        GlassCard(cornerRadius: 20, paddingAmount: 16) {
            HStack(spacing: 16) {
                // Icon Avatar
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(gradient)
                        .frame(width: 52, height: 52)
                        .shadow(color: AppTheme.primaryBrand.opacity(0.25), radius: 6, y: 3)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.headline.weight(.bold))
                            .foregroundColor(AppTheme.titleText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        
                        Spacer()
                        
                        Text(badgeText)
                            .font(.system(size: 9, weight: .heavy))
                            .tracking(0.6)
                            .foregroundColor(AppTheme.primaryBrand)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(AppTheme.primaryBrand.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(AppTheme.bodyText(0.8))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Chevron
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(AppTheme.primaryBrand.opacity(0.8))
            }
        }
    }
}


