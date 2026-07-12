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
    
    var body: some View {
        ZStack {
            AppTheme.gradient.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                if let r = report {
                    VStack(spacing: 22) {
                        
                        // Result Summary
                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Assessment Result")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.secondaryText)
                                
                                Text(r.result_summary)
                                    .font(.title2.bold())
                                    .foregroundColor(AppTheme.titleText)
                            }
                        }
                        
                        // Doctor Remark
                        if let remark = r.doctor_remark, !remark.isEmpty {
                            GlassCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "stethoscope")
                                        Text("Doctor Remark")
                                            .font(.headline)
                                    }
                                    .foregroundColor(AppTheme.titleText)
                                    
                                    Text(remark)
                                        .font(.body)
                                        .foregroundColor(AppTheme.bodyText)
                                }
                            }
                        }
                        
                        // Details
                        GlassCard {
                            VStack(spacing: 14) {
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
                        
                        Spacer(minLength: 40)
                    }
                    .padding()
                } else {
                    ProgressView("Loading report...")
                        .tint(AppTheme.lightText)
                        .padding(.top, 50)
                }
            }
        }
        .navigationTitle("Quiz Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            animate = true
            fetchDetail()
        }
    }
    
    func detailRow(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2)
                .foregroundColor(AppTheme.secondaryText)
            
            Text(value)
                .font(.body)
                .foregroundColor(AppTheme.bodyText)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.15))
                .cornerRadius(10)
        }
    }
}

