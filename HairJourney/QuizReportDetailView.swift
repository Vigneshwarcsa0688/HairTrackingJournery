import SwiftUI

struct QuizReportDetail: Codable {
    var result_summary: String
    var scalp_type: String
    var sleep_hours: String
    var hair_fall_frequency: String
    var family_history: String
    var stress_level: String
    var diet: String
    var deficiencies: String
    var hair_texture: String
    var hair_loss_stage: String
    var sudden_thinning: String
    var dandruff: String
    var styling_tools: String
    var scalp_pain: String
    var created_at: String
    var doctor_remark: String?
}

struct QuizReportDetailView: View {
    var reportId: String
    @State private var report: QuizReportDetail?
    @State private var animate = false
    
    func fetchDetail() {
        guard let url = URL(string: APIService.baseURL + "get_quiz_report_detail.php?report_id=\(reportId)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                if let data = data {
                    report = try? JSONDecoder().decode(QuizReportDetail.self, from: data)
                }
            }
        }.resume()
    }
    
    func generateShareText(for r: QuizReportDetail) -> String {
        var text = """
        🌿 HairJourney — Hair Health Assessment Report
        Assessment: \(r.result_summary)
        Date: \(r.created_at)
        
        Assessment Indicators:
        • Scalp Type: \(r.scalp_type)
        • Sleep Hours: \(r.sleep_hours)
        • Hair Fall Frequency: \(r.hair_fall_frequency)
        • Family History: \(r.family_history)
        • Stress Level: \(r.stress_level)
        • Diet: \(r.diet)
        • Deficiencies: \(r.deficiencies)
        • Hair Texture: \(r.hair_texture)
        • Sudden Thinning: \(r.sudden_thinning)
        • Dandruff: \(r.dandruff)
        • Styling Tools Usage: \(r.styling_tools)
        • Scalp Sensitivity: \(r.scalp_pain)
        """
        
        if let remark = r.doctor_remark, !remark.isEmpty {
            text += "\n\nSpecialist Guidance:\n\(remark)"
        }
        
        text += "\n\n*Student thesis project report developed for educational hair health and wellness habit tracking."
        return text
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            ScrollView(showsIndicators: false) {
                if let r = report {
                    VStack(spacing: 20) {
                        
                        // Result Summary
                        GlassCard(cornerRadius: 22, paddingAmount: 20) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("ASSESSMENT SUMMARY")
                                        .font(.system(size: 11, weight: .heavy))
                                        .tracking(1.2)
                                        .foregroundColor(AppTheme.primaryBrand)
                                    Spacer()
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(AppTheme.emeraldMint)
                                }
                                
                                Text(r.result_summary)
                                    .font(.title2.bold())
                                    .foregroundColor(AppTheme.titleText)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 11))
                                    Text("Logged: \(r.created_at)")
                                        .font(.caption)
                                }
                                .foregroundColor(AppTheme.bodyText(0.7))
                            }
                        }
                        
                        // Expert Guidance
                        if let remark = r.doctor_remark, !remark.isEmpty {
                            GlassCard(cornerRadius: 20, paddingAmount: 18) {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "sparkles")
                                            .foregroundColor(AppTheme.primaryBrand)
                                        Text("Specialist Guidance")
                                            .font(.headline.weight(.bold))
                                            .foregroundColor(AppTheme.titleText)
                                    }
                                    
                                    Text(remark)
                                        .font(.subheadline)
                                        .foregroundColor(AppTheme.bodyText(0.9))
                                        .lineSpacing(3)
                                }
                            }
                        }
                        
                        // Details Breakdown Card
                        GlassCard(cornerRadius: 22, paddingAmount: 20) {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Hair & Lifestyle Metrics")
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(AppTheme.titleText)
                                
                                VStack(spacing: 12) {
                                    detailRow("Scalp Type", r.scalp_type)
                                    detailRow("Sleep Hours", r.sleep_hours)
                                    detailRow("Hair Fall Frequency", r.hair_fall_frequency)
                                    detailRow("Family History", r.family_history)
                                    detailRow("Stress Level", r.stress_level)
                                    detailRow("Diet", r.diet)
                                    detailRow("Deficiencies", r.deficiencies)
                                    detailRow("Hair Texture", r.hair_texture)
                                    detailRow("Sudden Thinning", r.sudden_thinning)
                                    detailRow("Dandruff", r.dandruff)
                                    detailRow("Styling Tools Usage", r.styling_tools)
                                    detailRow("Scalp Pain", r.scalp_pain)
                                }
                            }
                        }
                        
                        // App Store Thesis Disclaimer
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.primaryBrand)
                                .padding(.top, 1)
                            
                            Text("HairJourney is an academic thesis project developed for educational and wellness habit tracking. It does not provide medical diagnosis, treatment, or clinical prescriptions. Always seek a doctor's advice in addition to using this app and before making any medical decisions.")
                                .font(.caption2)
                                .foregroundColor(AppTheme.bodyText(0.8))
                                .lineSpacing(2)
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.65))
                        .cornerRadius(14)
                        
                        // Bottom Share Button
                        ShareLink(
                            item: generateShareText(for: r),
                            subject: Text("HairJourney Assessment Report"),
                            message: Text("Here is my hair health assessment report.")
                        ) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 15, weight: .bold))
                                Text("Share Assessment Report")
                                    .font(.subheadline.weight(.bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppTheme.brandGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .shadow(color: AppTheme.primaryBrand.opacity(0.3), radius: 6, y: 3)
                        }
                        .padding(.top, 4)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(16)
                } else {
                    VStack(spacing: 12) {
                        ProgressView("Loading report...")
                            .tint(AppTheme.primaryBrand)
                        Text("Retrieving your assessment details...")
                            .font(.caption)
                            .foregroundColor(AppTheme.bodyText(0.7))
                    }
                    .padding(.top, 50)
                }
            }
        }
        .navigationTitle("Assessment Report")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let r = report {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ShareLink(
                        item: generateShareText(for: r),
                        subject: Text("HairJourney Assessment Report"),
                        message: Text("Here is my hair health assessment report.")
                    ) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.primaryBrand)
                    }
                }
            }
        }
        .onAppear {
            animate = true
            fetchDetail()
        }
    }
    
    func detailRow(_ title: String, _ value: String) -> some View {
        HStack(alignment: .center) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(AppTheme.bodyText(0.8))
            
            Spacer()
            
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundColor(AppTheme.titleText)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .padding(.vertical, 4)
    }
}
