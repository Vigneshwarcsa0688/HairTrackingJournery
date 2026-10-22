//
//  DoctorQuizRemarkView.swift
//  HairJourney
//
//  Created by Mac-24 on 03/02/26.
//

import SwiftUI

struct DoctorQuizRemarkView: View {
    var reportId: String
    @State private var remark = ""
    @State private var message = ""
    
    struct RemarkRequest: Codable {
        let report_id: Int
        let doctor_remark: String
    }
    
    func submitRemark() {
        guard let url = URL(string: APIService.baseURL + "add_quiz_remark.php"),
              let id = Int(reportId) else { return }
        
        let body = RemarkRequest(report_id: id, doctor_remark: remark)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                message = "Remark added successfully"
                remark = ""
            }
        }.resume()
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            VStack(spacing: 20) {
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Specialist Notes", systemImage: "pencil.line")
                            .font(.headline)
                            .foregroundColor(AppTheme.titleText)
                        
                        TextEditor(text: $remark)
                            .frame(height: 160)
                            .padding(10)
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(12)
                            .foregroundColor(AppTheme.titleText)
                    }
                }
                
                Button {
                    submitRemark()
                } label: {
                    Text("Submit Guidance")
                }
                .buttonStyle(PrimaryButtonStyle())
                
                if !message.isEmpty {
                    Text(message)
                        .font(.subheadline.bold())
                        .foregroundColor(AppTheme.emeraldMint)
                        .padding(.top, 8)
                }
                
                Spacer()
            }
            .padding(20)
        }
        .navigationTitle("Expert Guidance")
        .navigationBarTitleDisplayMode(.inline)
    }
}
