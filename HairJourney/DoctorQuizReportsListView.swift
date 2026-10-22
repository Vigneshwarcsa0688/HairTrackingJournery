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
    @State private var searchText = ""
    @State private var animate = false
    @State private var isLoading = true
    
    @Environment(\.horizontalSizeClass) var sizeClass
    
    // MARK: - Data Fetching
    func fetchReports(showLoading: Bool = true, completion: (() -> Void)? = nil) {
        if showLoading {
            isLoading = true
        }
        guard let url = URL(string: APIService.baseURL + "get_all_quiz_reports.php") else {
            isLoading = false
            completion?()
            return
        }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                defer {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.isLoading = false
                    }
                    completion?()
                }
                
                if let error = error {
                    print("Quiz reports fetch error:", error.localizedDescription)
                    return
                }
                
                if let data = data {
                    self.reports = (try? JSONDecoder().decode([DoctorQuizReportItem].self, from: data)) ?? []
                }
            }
        }.resume()
    }
    
    // MARK: - Filtered Reports
    var filteredReports: [DoctorQuizReportItem] {
        let sorted = reports.sorted { r1, r2 in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            guard let d1 = formatter.date(from: r1.created_at),
                  let d2 = formatter.date(from: r2.created_at) else { return false }
            return d1 > d2
        }
        
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return sorted
        }
        return sorted.filter {
            $0.patient_name.localizedCaseInsensitiveContains(searchText) ||
            $0.result_summary.localizedCaseInsensitiveContains(searchText) ||
            $0.id.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - Date Formatter
    func formatReportDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = formatter.date(from: dateString) {
            let out = DateFormatter()
            out.dateStyle = .medium
            out.timeStyle = .short
            return out.string(from: date)
        }
        return dateString
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // ── Hero Header ──
                    VStack(spacing: 6) {
                        HStack(spacing: 6) {
                            Text("DIAGNOSTIC INTAKE FEED")
                                .font(.system(size: 11, weight: .heavy))
                                .tracking(1.2)
                                .foregroundColor(AppTheme.irisPurple)
                            Image(systemName: "sparkles")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.irisPurple)
                        }
                        
                        Text("Quiz Reports Feed")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.titleText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                        
                        Text("Comprehensive 13-point member scalp scaling & lifestyle assessments")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.bodyText(0.75))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 12)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animate)
                    
                    // ── Metrics Stat Banner ──
                    HStack(spacing: 12) {
                        metricStatCard(
                            title: "Total Quizzes",
                            value: "\(reports.count)",
                            icon: "doc.text.magnifyingglass",
                            color: AppTheme.irisPurple
                        )
                        
                        metricStatCard(
                            title: "Analysis Points",
                            value: "13 Factors",
                            icon: "checklist.checked",
                            color: AppTheme.emeraldMint
                        )
                        
                        metricStatCard(
                            title: "Diagnostic Type",
                            value: "Intake",
                            icon: "chart.bar.doc.horizontal.fill",
                            color: AppTheme.primaryBrand
                        )
                    }
                    .opacity(animate ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.1), value: animate)
                    
                    // ── Search & Filter Bar ──
                    GlassCard(cornerRadius: 16, paddingAmount: 8) {
                        HStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(AppTheme.primaryBrand)
                                .padding(.leading, 6)
                            
                            TextField("Search member name, assessment notes...", text: $searchText)
                                .font(.subheadline)
                                .foregroundColor(AppTheme.titleText)
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(AppTheme.bodyText(0.5))
                                        .font(.system(size: 14))
                                }
                                .padding(.trailing, 6)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .opacity(animate ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.15), value: animate)
                    
                    // ── Feed List ──
                    if isLoading && reports.isEmpty {
                        // Shimmering Skeleton Cards
                        VStack(spacing: 14) {
                            ForEach(0..<4, id: \.self) { _ in
                                GlassCard(cornerRadius: 20, paddingAmount: 18) {
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack(spacing: 12) {
                                            Circle()
                                                .fill(Color.black.opacity(0.06))
                                                .frame(width: 44, height: 44)
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
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.black.opacity(0.04))
                                            .frame(height: 38)
                                    }
                                }
                                .shimmering(duration: 1.8)
                            }
                        }
                        .padding(.top, 4)
                    } else if reports.isEmpty {
                        // Empty State: No reports
                        GlassCard(cornerRadius: 22, paddingAmount: 26) {
                            VStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.irisPurple.opacity(0.12))
                                        .frame(width: 68, height: 68)
                                    Image(systemName: "doc.text.magnifyingglass")
                                        .font(.system(size: 32))
                                        .foregroundColor(AppTheme.irisPurple)
                                }
                                
                                Text("No Assessments Submitted Yet")
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(AppTheme.titleText)
                                
                                Text("When members complete their 13-point clinical hair quizzes, their comprehensive response profiles will stream here.")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.bodyText(0.75))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                        }
                        .padding(.top, 16)
                    } else if filteredReports.isEmpty {
                        // Search Empty State
                        GlassCard(cornerRadius: 20, paddingAmount: 22) {
                            VStack(spacing: 10) {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 36))
                                    .foregroundColor(AppTheme.bodyText(0.4))
                                
                                Text("No Matching Assessments")
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(AppTheme.titleText)
                                
                                Text("No quiz submissions match \"\(searchText)\".")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.bodyText(0.75))
                                
                                Button("Clear Search") {
                                    searchText = ""
                                }
                                .font(.caption.bold())
                                .foregroundColor(AppTheme.irisPurple)
                                .padding(.top, 4)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                        .padding(.top, 10)
                    } else {
                        // Rendered Reports List
                        VStack(spacing: 14) {
                            ForEach(Array(filteredReports.enumerated()), id: \.element.id) { index, report in
                                GlassCard(cornerRadius: 22, paddingAmount: 18) {
                                    NavigationLink(destination: DoctorQuizDetailView(reportId: report.id)) {
                                        VStack(alignment: .leading, spacing: 14) {
                                            
                                            // Top Row: Member Avatar, Name & Date
                                            HStack(spacing: 12) {
                                                ZStack {
                                                    Circle()
                                                        .fill(
                                                            LinearGradient(
                                                                colors: [AppTheme.irisPurple, Color.purple],
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            )
                                                        )
                                                        .frame(width: 46, height: 46)
                                                        .shadow(color: AppTheme.irisPurple.opacity(0.3), radius: 6, y: 3)
                                                    
                                                    Text(report.patient_name.prefix(1).uppercased())
                                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                                        .foregroundColor(.white)
                                                }
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    HStack(spacing: 6) {
                                                        Text(report.patient_name)
                                                            .font(.system(size: 17, weight: .bold, design: .rounded))
                                                            .foregroundColor(AppTheme.titleText)
                                                            .lineLimit(1)
                                                        
                                                        Text("•")
                                                            .font(.caption)
                                                            .foregroundColor(AppTheme.bodyText(0.4))
                                                        
                                                        Text("Report #\(report.id)")
                                                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                                                            .foregroundColor(AppTheme.bodyText(0.55))
                                                    }
                                                    
                                                    HStack(spacing: 4) {
                                                        Image(systemName: "calendar")
                                                            .font(.system(size: 10))
                                                        Text(formatReportDate(report.created_at))
                                                            .font(.caption2)
                                                    }
                                                    .foregroundColor(AppTheme.bodyText(0.7))
                                                }
                                                
                                                Spacer()
                                                
                                                // 13-Quiz Badge
                                                HStack(spacing: 4) {
                                                    Image(systemName: "checkmark.seal.fill")
                                                        .font(.system(size: 10))
                                                    Text("13 Points")
                                                        .font(.system(size: 10, weight: .heavy))
                                                }
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(AppTheme.irisPurple.opacity(0.12))
                                                .foregroundColor(AppTheme.irisPurple)
                                                .clipShape(Capsule())
                                            }
                                            
                                            // Diagnostic Insight Capsule
                                            HStack(alignment: .top, spacing: 10) {
                                                Image(systemName: "text.quote")
                                                    .font(.system(size: 13, weight: .bold))
                                                    .foregroundColor(AppTheme.irisPurple)
                                                    .padding(.top, 2)
                                                
                                                Text(report.result_summary.isEmpty ? "Standard Scaling Intake Assessment Completed" : report.result_summary)
                                                    .font(.subheadline)
                                                    .foregroundColor(AppTheme.titleText)
                                                    .lineLimit(3)
                                                    .multilineTextAlignment(.leading)
                                            }
                                            .padding(12)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.white.opacity(0.5))
                                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                    .stroke(Color.white, lineWidth: 1)
                                            )
                                            
                                            // Bottom Action Footer
                                            HStack {
                                                HStack(spacing: 5) {
                                                    Image(systemName: "doc.badge.magnifyingglass")
                                                        .font(.system(size: 11))
                                                    Text("Examine Member Responses")
                                                        .font(.system(size: 12, weight: .semibold))
                                                }
                                                .foregroundColor(AppTheme.primaryBrand)
                                                
                                                Spacer()
                                                
                                                HStack(spacing: 4) {
                                                    Text("Review")
                                                        .font(.system(size: 12, weight: .bold))
                                                    Image(systemName: "chevron.right.circle.fill")
                                                        .font(.system(size: 15))
                                                }
                                                .foregroundColor(AppTheme.primaryBrand)
                                            }
                                            .padding(.top, 2)
                                        }
                                    }
                                    .buttonStyle(InteractiveCardButtonStyle())
                                }
                                .opacity(animate ? 1 : 0)
                                .offset(y: animate ? 0 : 20)
                                .animation(
                                    .spring(response: 0.45, dampingFraction: 0.8)
                                    .delay(Double(min(index, 8)) * 0.05),
                                    value: animate
                                )
                            }
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
            }
            .refreshable {
                fetchReports(showLoading: false)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Quiz Reports")
                    .font(.headline.weight(.bold))
                    .foregroundColor(AppTheme.titleText)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    fetchReports()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.primaryBrand)
                }
            }
        }
        .onAppear {
            animate = true
            fetchReports()
        }
    }
    
    // MARK: - Metric Stat Card Subview
    @ViewBuilder
    private func metricStatCard(
        title: String,
        value: String,
        icon: String,
        color: Color
    ) -> some View {
        GlassCard(cornerRadius: 16, paddingAmount: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.14))
                            .frame(width: 28, height: 28)
                        Image(systemName: icon)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(color)
                    }
                    Spacer()
                }
                
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.titleText)
                    .lineLimit(1)
                
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(AppTheme.bodyText(0.7))
                    .lineLimit(1)
            }
        }
    }
}
