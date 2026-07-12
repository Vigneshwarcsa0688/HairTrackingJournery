import SwiftUI

struct UserDashboardView: View {
    var user: User
    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var animate = false
    @State private var weeklyCompliance: (days: Int, percent: Double) = (0, 0)
    @State private var streakDays = 0

    func fetchCompliancePreview() {
        let calendar = Calendar.current
        let today = Date()
        let month = calendar.component(.month, from: today)
        let year  = calendar.component(.year,  from: today)
        guard let url = URL(string: APIService.baseURL + "get_serum_logs.php?user_id=\(user.id)&month=\(month)&year=\(year)") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                guard let data = data,
                      let logs = try? JSONDecoder().decode([SerumLog].self, from: data) else { return }
                let formatter = DateFormatter(); formatter.dateFormat = "yyyy-MM-dd"
                let targetFrequency = SerumReminderPrefs.load().timesPerDay
                var logDates = Set<String>()
                for log in logs {
                    if let used = Int(log.times_used), used >= targetFrequency {
                        logDates.insert(log.log_date)
                    }
                }
                var logged = 0
                for offset in 0..<7 {
                    if let d = calendar.date(byAdding: .day, value: -offset, to: today) {
                        if logDates.contains(formatter.string(from: d)) { logged += 1 }
                    }
                }
                weeklyCompliance = (logged, Double(logged) / 7.0 * 100)

                // Streak: consecutive days from today back
                var streak = 0
                var d = today
                while logDates.contains(formatter.string(from: d)) {
                    streak += 1
                    d = calendar.date(byAdding: .day, value: -1, to: d) ?? d
                }
                streakDays = streak
            }
        }.resume()
    }

    var body: some View {
        TabView {
            ZStack {
                AppTheme.gradient.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // ── Greeting ──
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Hello,")
                                .foregroundColor(AppTheme.bodyText)
                            Text(user.name)
                                .font(.largeTitle.bold())
                                .foregroundColor(AppTheme.titleText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .opacity(animate ? 1 : 0).offset(y: animate ? 0 : -20)
                        .animation(.easeOut(duration: 0.6), value: animate)

                        // ── Compliance + Streak Banner ──
                        GlassCard {
                            HStack(spacing: 0) {
                                // Compliance ring
                                VStack(spacing: 4) {
                                    ZStack {
                                        Circle().stroke(Color.gray.opacity(0.15), lineWidth: 10).frame(width: 72, height: 72)
                                        Circle()
                                            .trim(from: 0, to: CGFloat(weeklyCompliance.percent / 100))
                                            .stroke(
                                                weeklyCompliance.percent >= 80 ? AnyShapeStyle(AppTheme.complianceGradient) :
                                                AnyShapeStyle(weeklyCompliance.percent >= 50 ? Color.orange : AppTheme.error),
                                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                                            )
                                            .frame(width: 72, height: 72).rotationEffect(.degrees(-90))
                                            .animation(.spring(response: 0.8, dampingFraction: 0.7), value: weeklyCompliance.percent)
                                        VStack(spacing: 0) {
                                            Text(String(format: "%.0f%%", weeklyCompliance.percent))
                                                .font(.subheadline.bold()).foregroundColor(AppTheme.titleText)
                                        }
                                    }
                                    Text("Weekly\nCompliance").font(.caption2).foregroundColor(AppTheme.bodyText)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)

                                Divider().frame(height: 60)

                                // Streak
                                VStack(spacing: 4) {
                                    Text("🔥 \(streakDays)").font(.title2.bold()).foregroundColor(AppTheme.titleText)
                                    Text("Day Streak").font(.caption2).foregroundColor(AppTheme.bodyText)
                                }
                                .frame(maxWidth: .infinity)

                                Divider().frame(height: 60)

                                // Days logged
                                VStack(spacing: 4) {
                                    Text("\(weeklyCompliance.days)/7").font(.title2.bold()).foregroundColor(AppTheme.titleText)
                                    Text("Days\nLogged").font(.caption2).foregroundColor(AppTheme.bodyText)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .opacity(animate ? 1 : 0).animation(.easeOut(duration: 0.7), value: animate)

                        // ── Dashboard Cards ──
                        LazyVGrid(columns: AppTheme.dashboardColumns(sizeClass), spacing: 20) {
                            dashCard("doc.text.fill",          "Hair Growth Quiz",          "Assess your hair health",             AnyView(HairAnalysis13QuizView(user: user)))
                            dashCard("chart.bar.fill",         "Quiz Reports",               "View your past assessments",         AnyView(QuizReportsView(user: user)))
                            dashCard("calendar",               "Book \nConsultation",              "Schedule an upcoming visit",          AnyView(BookAppointmentView(user: user)))
                            dashCard("calendar",               "My Consultations",            "Track booking status",               AnyView(UserAppointmentsView(user: user)))
                            dashCard("camera.fill",            "Upload Hair Images",         "Track progress with photos",         AnyView(UploadHairImageView(user: user)))
                            dashCard("photo.on.rectangle",     "My Hair Images",             "View uploads & expert feedback",     AnyView(UserHairImagesView(user: user)))
                            dashCard("chart.xyaxis.line",      "Hair Progress Tracker",      "Compare before & after growth",      AnyView(HairProgressCompareView(user: user)))
                            dashCard("pills.fill",             "My Routines",             "View your product recommendations",            AnyView(PrescriptionsView(user: user)))
                            dashCard("calendar.badge.clock",   "Serum Calendar",             "Track usage & compliance score",     AnyView(SerumCalendarView(user: user)))
                        }

                        Spacer(minLength: 40)
                    }
                    .padding()
                    .frame(maxWidth: AppTheme.maxContentWidth(sizeClass))
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .tabItem { Label("Home", systemImage: "house.fill") }

            ProfileView(user: user)
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .onAppear {
            animate = true
            fetchCompliancePreview()
        }
    }

    @ViewBuilder
    func dashCard(_ icon: String, _ title: String, _ subtitle: String, _ destination: AnyView) -> some View {
        GlassCard {
            NavigationLink(destination: destination) {
                DashboardRow(icon: icon, title: title, subtitle: subtitle)
            }
        }
        .opacity(animate ? 1 : 0).offset(y: animate ? 0 : 20)
        .animation(.easeOut(duration: 0.7), value: animate)
    }
}
