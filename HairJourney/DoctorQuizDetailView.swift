import SwiftUI

struct DoctorQuizDetail: Codable {
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
    var doctor_remark: String?
}

struct DoctorQuizDetailView: View {
    var reportId: String
    @State private var report: DoctorQuizDetail?
    @State private var remark = ""
    @State private var message = ""
    
    struct RemarkRequest: Codable {
        let report_id: Int
        let doctor_remark: String
    }
    
    // ✅ FIXED HERE
    func fetchDetail() {
        guard let url = URL(string: APIService.baseURL + "get_quiz_report_detail.php?report_id=\(reportId)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Fetch error:", error.localizedDescription)
                    return
                }
                
                guard let safeData = data else {
                    print("No data received")
                    return
                }
                
                do {
                    let decoded = try JSONDecoder().decode(DoctorQuizDetail.self, from: safeData)
                    report = decoded
                    remark = decoded.doctor_remark ?? ""
                } catch {
                    print("Decode error:", error)
                }
            }
        }.resume()
    }
    
    func submitRemark() {
        guard let url = URL(string: APIService.baseURL + "add_quiz_remark.php"),
              let id = Int(reportId) else { return }
        
        let body = RemarkRequest(report_id: id, doctor_remark: remark)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    message = "Error: \(error.localizedDescription)"
                } else {
                    message = "Remark saved successfully"
                }
            }
        }.resume()
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            ScrollView(showsIndicators: false) {
                if let r = report {
                    VStack(spacing: 20) {
                        
                        // Summary Card
                        GlassCard(cornerRadius: 20, padding: 18) {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.primaryBrand.opacity(0.12))
                                        .frame(width: 48, height: 48)
                                    Image(systemName: "doc.text.magnifyingglass")
                                        .font(.system(size: 22))
                                        .foregroundColor(AppTheme.primaryBrand)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Assessment Result")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.bodyText)
                                    Text(r.result_summary)
                                        .font(.title3.bold())
                                        .foregroundColor(AppTheme.titleText)
                                }
                                
                                Spacer()
                            }
                        }
                        
                        // Responses Grid / Group
                        GlassCard(cornerRadius: 22, padding: 18) {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(spacing: 8) {
                                    Image(systemName: "list.bullet.rectangle.portrait.fill")
                                        .foregroundColor(AppTheme.primaryBrand)
                                    Text("Member Responses")
                                        .font(.headline)
                                        .foregroundColor(AppTheme.titleText)
                                }
                                
                                Divider().opacity(0.5)
                                
                                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                                    detailCard("Scalp Type", r.scalp_type, icon: "drop.fill")
                                    detailCard("Sleep Hours", r.sleep_hours, icon: "bed.double.fill")
                                    detailCard("Hair Fall", r.hair_fall_frequency, icon: "arrow.down.right.circle.fill")
                                    detailCard("Family History", r.family_history, icon: "person.2.fill")
                                    detailCard("Stress Level", r.stress_level, icon: "bolt.heart.fill")
                                    detailCard("Diet", r.diet, icon: "fork.knife")
                                    detailCard("Deficiencies", r.deficiencies, icon: "cross.fill")
                                    detailCard("Texture", r.hair_texture, icon: "sparkles")
                                    detailCard("Thinning", r.sudden_thinning, icon: "chart.line.downtrend.xyaxis")
                                    detailCard("Dandruff", r.dandruff, icon: "snowflake")
                                    detailCard("Styling Tools", r.styling_tools, icon: "comb.fill")
                                    detailCard("Scalp Pain", r.scalp_pain, icon: "exclamationmark.circle.fill")
                                }
                            }
                        }
                        
                        // Expert Evaluation Section
                        GlassCard(cornerRadius: 22, padding: 18) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 8) {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(AppTheme.primaryBrand)
                                    Text("Expert Assessment & Guidance")
                                        .font(.headline)
                                        .foregroundColor(AppTheme.titleText)
                                }
                                
                                TextEditor(text: $remark)
                                    .frame(minHeight: 110)
                                    .padding(10)
                                    .background(Color.white.opacity(0.7))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                                    )
                                    .foregroundColor(AppTheme.titleText)
                                
                                if !message.isEmpty {
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text(message)
                                    }
                                    .font(.caption.bold())
                                    .foregroundColor(.green)
                                    .transition(.opacity)
                                }
                                
                                Button {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    submitRemark()
                                } label: {
                                    Text("Save Remark")
                                }
                                .buttonStyle(PrimaryButtonStyle())
                                .padding(.top, 4)
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                } else {
                    VStack(spacing: 12) {
                        ProgressView().tint(AppTheme.primaryBrand)
                        Text("Loading report...")
                            .font(.caption)
                            .foregroundColor(AppTheme.bodyText)
                    }
                    .padding(.top, 80)
                }
            }
        }
        .navigationTitle("Quiz Review")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { fetchDetail() }
    }
    
    func detailCard(_ title: String, _ value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.primaryBrand)
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.bodyText)
                    .lineLimit(1)
            }
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppTheme.titleText)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.white.opacity(0.6))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
    }
}

