import SwiftUI

struct QuizReport: Codable, Identifiable {
    var id: String
    var result_summary: String
    var created_at: String
}

struct QuizReportsView: View {
    var user: User
    @State private var reports: [QuizReport] = []
    @State private var animate = false
    
    func fetchReports() {
        guard let url = URL(string: APIService.baseURL + "get_quiz_reports.php?user_id=\(user.id)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                if let data = data {
                    reports = (try? JSONDecoder().decode([QuizReport].self, from: data)) ?? []
                }
            }
        }.resume()
    }
    
    func formatDate(_ dateStr: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = formatter.date(from: dateStr) {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return dateStr
    }
    
    var body: some View {
        ZStack {
            AppTheme.gradient.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    VStack(spacing: 6) {
                        Image(systemName: "waveform.path.ecg.rectangle")
                            .font(.system(size: 40))
                            .foregroundColor(AppTheme.secondaryText)
                        
                        Text("Hair Health Reports")
                            .font(.title.bold())
                            .foregroundColor(AppTheme.titleText)
                        
                        Text("Your previous hair assessments")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.bodyText)
                    }
                    .padding(.top)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animate)
                    
                    ForEach(reports) { report in
                        ReportRowView(
                            report: report,
                            formattedDate: formatDate(report.created_at),
                            animate: animate
                        )
                    }
                    
                    if reports.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "tray")
                                .font(.largeTitle)
                                .foregroundColor(AppTheme.secondaryText)
                            
                            Text("No reports available yet")
                                .foregroundColor(AppTheme.bodyText)
                                .font(.subheadline)
                        }
                        .padding(.top, 50)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Reports")
                    .font(.headline.bold())
                    .foregroundColor(AppTheme.titleText)
            }
        }
        .onAppear {
            animate = true
            fetchReports()
        }
    }
}

struct ReportRowView: View {
    var report: QuizReport
    var formattedDate: String
    var animate: Bool
    
    var body: some View {
        NavigationLink(destination: QuizReportDetailView(reportId: report.id)) {
            GlassCard {
                HStack(spacing: 16) {
                    
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.18))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(AppTheme.titleText)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(report.result_summary)
                            .font(.headline)
                            .foregroundColor(AppTheme.titleText)
                        
                        Text(formattedDate)
                            .font(.caption)
                            .foregroundColor(AppTheme.bodyText)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(animate ? 1 : 0)
        .offset(y: animate ? 0 : 25)
        .animation(.easeOut(duration: 0.7), value: animate)
    }
}

