import SwiftUI

struct HairAnalysisReportView: View {
    var score: Int
    var onFinish: () -> Void   // ✅ ADDED
    
    @Environment(\.dismiss) var dismiss
    @State private var animate = false
    
    var risk: String {
        if score < 15 { return "Low Risk" }
        if score < 30 { return "Moderate Risk" }
        return "High Risk"
    }
    
    var riskColor: Color {
        switch risk {
        case "Low Risk": return .green
        case "Moderate Risk": return .orange
        default: return .red
        }
    }
    
    var maxScore: Int { 36 } // 12 questions * max 3 points
    var scorePercentage: Double {
        let clamped = max(0, min(score, maxScore))
        return Double(clamped) / Double(maxScore)
    }
    
    var shareReportText: String {
        """
        🌿 HairJourney — Hair Health Assessment Report
        Score: \(score) / \(maxScore)
        Classification: \(risk)
        
        Recommended Next Steps:
        • Daily serum and care regimen tracking in the Serum Calendar
        • Monthly milestone hair photo comparisons
        • Routine review with a certified hair care specialist
        
        *Educational hair health thesis project report generated via HairJourney.
        """
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppTheme.emeraldMint, AppTheme.primaryBrand],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(animate ? 1 : 0.6)
                            .animation(.spring(response: 0.5, dampingFraction: 0.65), value: animate)
                        
                        Text("Hair Health Assessment")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.titleText)
                        
                        Text("Your personalized assessment has been calculated")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.bodyText)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animate)
                    
                    // Score & Risk Card
                    GlassCard(cornerRadius: 24, padding: 24) {
                        VStack(spacing: 18) {
                            
                            // Radial Gauge
                            ZStack {
                                Circle()
                                    .stroke(Color.black.opacity(0.08), lineWidth: 14)
                                    .frame(width: 140, height: 140)
                                
                                Circle()
                                    .trim(from: 0, to: animate ? CGFloat(max(0.08, scorePercentage)) : 0)
                                    .stroke(
                                        LinearGradient(
                                            colors: [riskColor.opacity(0.8), riskColor],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                                    )
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 140, height: 140)
                                    .animation(.easeOut(duration: 1.0).delay(0.2), value: animate)
                                
                                VStack(spacing: 2) {
                                    Text("\(score)")
                                        .font(.system(size: 38, weight: .bold, design: .rounded))
                                        .foregroundColor(AppTheme.titleText)
                                    Text("Index Score")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(AppTheme.bodyText)
                                }
                            }
                            
                            // Status Capsule
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(riskColor)
                                    .frame(width: 8, height: 8)
                                Text(risk)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(riskColor)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(riskColor.opacity(0.12))
                            .cornerRadius(20)
                        }
                    }
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 20)
                    .animation(.easeOut(duration: 0.7), value: animate)
                    
                    // Recommended Next Steps
                    GlassCard(cornerRadius: 20, padding: 18) {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 8) {
                                Image(systemName: "list.clipboard.fill")
                                    .foregroundColor(AppTheme.primaryBrand)
                                Text("Suggested Routine Next Steps")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.titleText)
                            }
                            
                            VStack(spacing: 10) {
                                recommendationRow(icon: "calendar.badge.clock", text: "Log your daily serum and care routine in the Serum Calendar.")
                                recommendationRow(icon: "camera.fill", text: "Capture milestone hair photos monthly to monitor growth changes.")
                                recommendationRow(icon: "person.crop.circle.badge.checkmark", text: "Consult our hair specialists for routine care reviews.")
                            }
                        }
                    }
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 25)
                    .animation(.easeOut(duration: 0.7).delay(0.1), value: animate)
                    
                    // App Store Academic / Wellness Disclaimer
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 15))
                            .foregroundColor(AppTheme.primaryBrand)
                            .padding(.top, 1)
                        
                        Text("This student thesis project assessment provides educational wellness insights and habit tracking. It does not provide clinical medical diagnosis or treatment. Always seek a doctor's advice in addition to using this app and before making any medical decisions.")
                            .font(.caption2)
                            .foregroundColor(AppTheme.bodyText(0.85))
                            .lineSpacing(2)
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.65))
                    .cornerRadius(14)
                    .padding(.horizontal, 4)
                    
                    // Action Buttons (Share & Dashboard)
                    VStack(spacing: 12) {
                        ShareLink(
                            item: shareReportText,
                            subject: Text("HairJourney — Hair Health Assessment Report"),
                            message: Text("Here is my hair health assessment report summary.")
                        ) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 15, weight: .bold))
                                Text("Share Assessment Report")
                                    .font(.subheadline.weight(.bold))
                            }
                            .foregroundColor(AppTheme.primaryBrand)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white.opacity(0.85))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(AppTheme.primaryBrand.opacity(0.3), lineWidth: 1.2)
                            )
                        }
                        
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            dismiss()
                            onFinish()
                        } label: {
                            Text("Back to Dashboard")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding(.top, 4)
                    
                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 20)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareLink(
                    item: shareReportText,
                    subject: Text("HairJourney Assessment Report"),
                    message: Text("Check out my hair health report")
                ) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.primaryBrand)
                }
            }
        }
        .onAppear {
            animate = true
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func recommendationRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.primaryBrand.opacity(0.12))
                    .frame(width: 28, height: 28)
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.primaryBrand)
            }
            Text(text)
                .font(.subheadline)
                .foregroundColor(AppTheme.bodyText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
