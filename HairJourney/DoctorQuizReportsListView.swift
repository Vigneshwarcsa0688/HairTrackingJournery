//
//  DoctorQuizReportsListView.swift
//  HairJourney
//
//  Created by Mac-24 on 03/02/26.
//

import SwiftUI
struct DoctorQuizReportItem: Codable, Identifiable {
    var id: String
    var user_id: String
    var patient_name: String
    var result_summary: String
    var created_at: String
}

struct DoctorQuizReportsListView: View {
    @State private var reports: [DoctorQuizReportItem] = []
    
    func fetchReports() {
        guard let url = URL(string: APIService.baseURL + "get_all_quiz_reports.php") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                if let data = data {
                    reports = (try? JSONDecoder().decode([DoctorQuizReportItem].self, from: data)) ?? []
                }
            }
        }.resume()
    }
    
    var body: some View {
        List(reports) { report in
            NavigationLink(destination: DoctorQuizDetailView(reportId: report.id)) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(report.patient_name)
                        .font(.headline)
                    
                    Text(report.result_summary)
                        .font(.subheadline)
                    
                    Text(report.created_at)
                        .font(.caption)
                        .foregroundColor(AppTheme.secondaryText)                }
                .padding(.vertical, 4)
            }
        }

        .navigationTitle("Quiz Reports")
        .onAppear { fetchReports() }
    }
}
