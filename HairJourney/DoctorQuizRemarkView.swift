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
        VStack(spacing: 15) {
            TextEditor(text: $remark)
                .frame(height: 150)
                .border(Color.gray)
            
            Button("Submit Remark") {
                submitRemark()
            }
            .buttonStyle(.borderedProminent)
            
            Text(message).foregroundColor(.green)
        }
        .padding()
        .navigationTitle("Doctor Remark")
    }
}
