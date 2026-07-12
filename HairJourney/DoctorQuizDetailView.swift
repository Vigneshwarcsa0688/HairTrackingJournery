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
        ScrollView {
            if let r = report {
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("Result: \(r.result_summary)")
                        .font(.title3.bold())
                    
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
                    detailRow("Styling Tools", r.styling_tools)
                    detailRow("Scalp Pain", r.scalp_pain)
                    
                    Divider().padding(.vertical)
                    
                    Text("Doctor Remark")
                        .font(.headline)
                    
                    TextEditor(text: $remark)
                        .frame(height: 120)
                        .border(Color.gray)
                    
                    Button("Save Remark") {
                        submitRemark()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Text(message)
                        .foregroundColor(.green)
                }
                .padding()
            } else {
                ProgressView("Loading report...")
            }
        }
        .navigationTitle("Quiz Review")
        .onAppear { fetchDetail() }
    }
    
    func detailRow(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(AppTheme.secondaryText)            
            Text(value)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
        }
    }
}

