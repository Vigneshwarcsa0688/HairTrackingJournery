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
    @State private var isLoading = true
    
    func fetchReports(completion: (() -> Void)? = nil) {
        isLoading = true
        guard let url = URL(string: APIService.baseURL + "get_quiz_reports.php?user_id=\(user.id)") else {
            isLoading = false
            completion?()
            return
        }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.isLoading = false
                }
                if let data = data {
                    self.reports = (try? JSONDecoder().decode([QuizReport].self, from: data)) ?? []
                }
                completion?()
            }
        }.resume()
    }
    
    func formatDate(_ dateStr: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = formatter.date(from: dateStr) {
            let out = DateFormatter()
            out.dateStyle = .medium
            out.timeStyle = .short
            return out.string(from: date)
        }
        return dateStr
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // Header
                    VStack(spacing: 6) {
                        HStack(spacing: 6) {
                            Text("HAIR HEALTH RECORDS")
                                .font(.system(size: 11, weight: .heavy))
                                .tracking(1.2)
                                .foregroundColor(AppTheme.primaryBrand)
                            Image(systemName: "sparkles")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.primaryBrand)
                        }
                        
                        Text("My Assessment Reports")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.titleText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                        
                        Text("Historical scaling quizzes and personalized hair care analysis")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.bodyText(0.75))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 12)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animate)
                    
                    if isLoading && reports.isEmpty {
                        // Skeleton Loader
                        VStack(spacing: 12) {
                            ForEach(0..<3, id: \.self) { _ in
                                GlassCard(cornerRadius: 20, paddingAmount: 16) {
                                    HStack(spacing: 14) {
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.black.opacity(0.06))
                                            .frame(width: 48, height: 48)
                                        VStack(alignment: .leading, spacing: 6) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.black.opacity(0.08))
                                                .frame(width: 140, height: 16)
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.black.opacity(0.05))
                                                .frame(width: 90, height: 12)
                                        }
                                        Spacer()
                                    }
                                }
                                .shimmering(duration: 1.8)
                            }
                        }
                        .padding(.top, 10)
                    } else if reports.isEmpty {
                        // Empty State
                        GlassCard(cornerRadius: 22, paddingAmount: 26) {
                            VStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.primaryBrand.opacity(0.12))
                                        .frame(width: 68, height: 68)
                                    Image(systemName: "doc.text.magnifyingglass")
                                        .font(.system(size: 32))
                                        .foregroundColor(AppTheme.primaryBrand)
                                }
                                
                                Text("No Quiz Reports Yet")
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(AppTheme.titleText)
                                
                                Text("Take the 13-point diagnostic quiz to receive personalized hair health insights and product recommendations.")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.bodyText(0.75))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                        }
                        .padding(.top, 20)
                    } else {
                        // Reports List
                        ForEach(Array(reports.enumerated()), id: \.element.id) { index, report in
                            ReportRowView(
                                report: report,
                                formattedDate: formatDate(report.created_at),
                                animate: animate,
                                index: index
                            )
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
            }
            .refreshable {
                fetchReports()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Reports")
                    .font(.headline.weight(.bold))
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
    var index: Int = 0
    
    var body: some View {
        NavigationLink(destination: QuizReportDetailView(reportId: report.id)) {
            GlassCard(cornerRadius: 20, paddingAmount: 16) {
                HStack(spacing: 14) {
                    
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [AppTheme.irisPurple, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 48, height: 48)
                            .shadow(color: AppTheme.irisPurple.opacity(0.3), radius: 6, y: 3)
                        
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(report.result_summary)
                            .font(.headline.weight(.bold))
                            .foregroundColor(AppTheme.titleText)
                            .lineLimit(1)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                            Text(formattedDate)
                                .font(.caption)
                        }
                        .foregroundColor(AppTheme.bodyText(0.7))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.primaryBrand.opacity(0.7))
                }
            }
        }
        .buttonStyle(InteractiveCardButtonStyle())
        .contextMenu {
            ShareLink(
                item: "🌿 HairJourney Assessment Summary\nResult: \(report.result_summary)\nDate: \(formattedDate)\n\n*Student thesis project report.",
                subject: Text("HairJourney Assessment Report"),
                message: Text("Check out my hair health assessment report.")
            ) {
                Label("Share Report", systemImage: "square.and.arrow.up")
            }
        }
        .opacity(animate ? 1 : 0)
        .offset(y: animate ? 0 : 20)
        .animation(.spring(response: 0.45, dampingFraction: 0.8).delay(Double(min(index, 8)) * 0.05), value: animate)
    }
}
