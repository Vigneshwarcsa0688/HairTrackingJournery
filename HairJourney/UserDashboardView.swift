import SwiftUI

import SwiftUI

struct UserDashboardView: View {
    var user: User
    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var animate = false
    @State private var weeklyCompliance: (days: Int, percent: Double) = (0, 0)
    @State private var animatedProgress: CGFloat = 0.0
    @State private var streakDays = 0
    @State private var recentLogs: Set<String> = []
    @State private var showAIChat = false
    @ObservedObject private var langManager = AppLanguageManager.shared

    var timeOfDayGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "\(langManager.text("good_morning"))," }
        else if hour < 17 { return "\(langManager.text("good_afternoon"))," }
        else { return "\(langManager.text("good_evening"))," }
    }

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
                recentLogs = logDates
                var logged = 0
                for offset in 0..<7 {
                    if let d = calendar.date(byAdding: .day, value: -offset, to: today) {
                        if logDates.contains(formatter.string(from: d)) { logged += 1 }
                    }
                }
                weeklyCompliance = (logged, Double(logged) / 7.0 * 100)
                withAnimation(.spring(response: 1.0, dampingFraction: 0.72).delay(0.2)) {
                    animatedProgress = CGFloat(Double(logged) / 7.0)
                }

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
                AppBackgroundView()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {

                        // ── Header Bar ──
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(timeOfDayGreeting)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(AppTheme.bodyText(0.75))
                                Text(user.name)
                                    .font(.system(size: AppTheme.heroTitleSize(sizeClass), weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.titleText)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            Spacer()
                            
                            // User Avatar
                            NavigationLink(destination: ProfileView(user: user)) {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.brandGradient)
                                        .frame(width: 48, height: 48)
                                        .shadow(color: AppTheme.primaryBrand.opacity(0.3), radius: 6, y: 3)
                                    
                                    Text(user.name.prefix(1).uppercased())
                                        .font(.headline.bold())
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.top, 8)
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : -15)
                        .animation(.easeOut(duration: 0.6), value: animate)

                        // ── Momentum & Compliance Hero Card ──
                        GlassCard(cornerRadius: 24, paddingAmount: 20) {
                            VStack(spacing: 16) {
                                HStack(spacing: 16) {
                                    // Circular Ring
                                    ZStack {
                                        Circle()
                                            .stroke(Color.black.opacity(0.06), lineWidth: 9)
                                            .frame(width: 76, height: 76)
                                        
                                        Circle()
                                            .trim(from: 0, to: max(0.001, animatedProgress))
                                            .stroke(
                                                weeklyCompliance.percent >= 80 ? AnyShapeStyle(AppTheme.mintGradient) :
                                                AnyShapeStyle(weeklyCompliance.percent >= 50 ? AppTheme.brandGradient : LinearGradient(colors: [AppTheme.coralRose, .orange], startPoint: .leading, endPoint: .trailing)),
                                                style: StrokeStyle(lineWidth: 9, lineCap: .round)
                                            )
                                            .frame(width: 76, height: 76)
                                            .rotationEffect(.degrees(-90))
                                            .shadow(color: (weeklyCompliance.percent >= 80 ? AppTheme.emeraldMint : AppTheme.primaryBrand).opacity(0.35), radius: 6)
                                        
                                        VStack(spacing: 0) {
                                            Text(String(format: "%.0f%%", weeklyCompliance.percent))
                                                .font(.headline.weight(.heavy))
                                                .foregroundColor(AppTheme.titleText)
                                            Text(langManager.text("goal"))
                                                .font(.system(size: 8, weight: .bold))
                                                .foregroundColor(AppTheme.bodyText(0.6))
                                        }
                                    }
                                    
                                    // Stats Details
                                    VStack(alignment: .leading, spacing: 6) {
                                        HStack(spacing: 6) {
                                            Text(langManager.text("weekly_momentum"))
                                                .font(.headline.weight(.bold))
                                                .foregroundColor(AppTheme.titleText)
                                            Spacer()
                                            Text("🔥 \(streakDays)d \(langManager.text("streak"))")
                                                .font(.system(size: 11, weight: .heavy))
                                                .foregroundColor(.orange)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 3)
                                                .background(Color.orange.opacity(0.12))
                                                .clipShape(Capsule())
                                                .pulseGlow(color: .orange, radius: 4)
                                        }
                                        
                                        Text("\(weeklyCompliance.days) \(langManager.text("logged_target"))")
                                            .font(.caption)
                                            .foregroundColor(AppTheme.bodyText(0.75))
                                        
                                        // Mini 7-day indicator
                                        HStack(spacing: 6) {
                                            ForEach(0..<7, id: \.self) { offset in
                                                dayDot(offset: offset)
                                            }
                                        }
                                        .padding(.top, 2)
                                    }
                                }
                                
                                Divider().opacity(0.6)
                                
                                // Quick Jump Link
                                NavigationLink(destination: SerumCalendarView(user: user)) {
                                    HStack {
                                        Image(systemName: "calendar.badge.clock")
                                            .foregroundColor(AppTheme.primaryBrand)
                                        Text(langManager.text("open_serum_calendar"))
                                            .font(.caption.weight(.bold))
                                            .foregroundColor(AppTheme.primaryBrand)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(AppTheme.primaryBrand)
                                    }
                                }
                            }
                        }
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : 15)
                        .animation(.easeOut(duration: 0.65), value: animate)

                        // ── AI Hair Health Assistant Card ──
                        GlassCard(cornerRadius: 22, paddingAmount: 16) {
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                showAIChat = true
                            } label: {
                                HStack(spacing: 15) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color(red: 0.18, green: 0.42, blue: 0.95), Color(red: 0.50, green: 0.35, blue: 0.90)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 50, height: 50)
                                            .shadow(color: AppTheme.primaryBrand.opacity(0.35), radius: 6, y: 3)
                                        
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 3) {
                                        HStack(spacing: 6) {
                                            Text("Hair AI Assistant")
                                                .font(.headline.weight(.bold))
                                                .foregroundColor(AppTheme.titleText)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.85)
                                            
                                            Text("24/7 ONLINE")
                                                .font(.system(size: 8, weight: .heavy))
                                                .tracking(0.5)
                                                .foregroundColor(AppTheme.emeraldMint)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(AppTheme.emeraldMint.opacity(0.12))
                                                .clipShape(Capsule())
                                        }
                                        
                                        Text("Ask random questions on serum routines, shedding & follicle care")
                                            .font(.caption)
                                            .foregroundColor(AppTheme.bodyText(0.75))
                                            .lineLimit(2)
                                            .minimumScaleFactor(0.85)
                                            .multilineTextAlignment(.leading)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(AppTheme.primaryBrand.opacity(0.85))
                                }
                            }
                            .buttonStyle(InteractiveCardButtonStyle())
                        }
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : 15)
                        .animation(.easeOut(duration: 0.7), value: animate)

                        // ── SECTION 1: Daily Routine & Regimen ──
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeaderView(
                                title: langManager.text("daily_treatment_section"),
                                subtitle: langManager.text("compliance"),
                                icon: "clock.badge.checkmark"
                            )
                            
                            LazyVGrid(columns: AppTheme.dashboardColumns(sizeClass), spacing: 14) {
                                GlassCard(cornerRadius: 18, paddingAmount: 16) {
                                    NavigationLink(destination: SerumCalendarView(user: user)) {
                                        DashboardRow(
                                            icon: "calendar.badge.clock",
                                            title: langManager.text("serum_calendar"),
                                            subtitle: langManager.text("serum_calendar_desc"),
                                            iconGradient: AppTheme.sunsetGradient,
                                            badgeText: "DAILY",
                                            badgeColor: .orange
                                        )
                                    }
                                    .buttonStyle(InteractiveCardButtonStyle())
                                }
                                
                                GlassCard(cornerRadius: 18, paddingAmount: 16) {
                                    NavigationLink(destination: PrescriptionsView(user: user)) {
                                        DashboardRow(
                                            icon: "pills.fill",
                                            title: langManager.text("my_routines"),
                                            subtitle: langManager.text("my_routines_desc"),
                                            iconGradient: LinearGradient(colors: [AppTheme.irisPurple, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing),
                                            badgeText: "REGIMEN",
                                            badgeColor: AppTheme.irisPurple
                                        )
                                    }
                                    .buttonStyle(InteractiveCardButtonStyle())
                                }
                            }
                        }

                        // ── SECTION 2: Progress & Photos ──
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeaderView(
                                title: langManager.text("visual_progress_section"),
                                subtitle: langManager.text("tracking"),
                                icon: "camera.viewfinder"
                            )
                            
                            // Spotlight Compare Card
                            GlassCard(cornerRadius: 20, paddingAmount: 16) {
                                NavigationLink(destination: HairProgressCompareView(user: user)) {
                                    HStack(spacing: 16) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .fill(AppTheme.mintGradient)
                                                .frame(width: 52, height: 52)
                                                .shadow(color: AppTheme.emeraldMint.opacity(0.3), radius: 6, y: 3)
                                            
                                            Image(systemName: "chart.xyaxis.line")
                                                .font(.system(size: 22, weight: .semibold))
                                                .foregroundColor(.white)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(langManager.text("hair_progress_tracker"))
                                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                                .foregroundColor(AppTheme.titleText)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.85)
                                                .truncationMode(.tail)
                                            
                                            HStack(spacing: 6) {
                                                Text(langManager.text("before_and_after"))
                                                    .font(.system(size: 8.5, weight: .heavy))
                                                    .foregroundColor(AppTheme.emeraldMint)
                                                    .padding(.horizontal, 7)
                                                    .padding(.vertical, 2.5)
                                                    .background(AppTheme.emeraldMint.opacity(0.12))
                                                    .clipShape(Capsule())
                                                
                                                Text(langManager.text("growth_comparison"))
                                                    .font(.caption)
                                                    .foregroundColor(AppTheme.bodyText(0.75))
                                                    .lineLimit(1)
                                            }
                                        }
                                        
                                        Spacer(minLength: 4)
                                        
                                        Image(systemName: "chevron.right.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(AppTheme.emeraldMint)
                                    }
                                }
                            }
                            .buttonStyle(InteractiveCardButtonStyle())

                            LazyVGrid(columns: AppTheme.dashboardColumns(sizeClass), spacing: 14) {
                                GlassCard(cornerRadius: 18, paddingAmount: 16) {
                                    NavigationLink(destination: UploadHairImageView(user: user)) {
                                        DashboardRow(
                                            icon: "camera.fill",
                                            title: langManager.text("upload_photos"),
                                            subtitle: langManager.text("upload_photos_desc"),
                                            iconGradient: AppTheme.brandGradient,
                                            badgeText: "CAPTURE"
                                        )
                                    }
                                    .buttonStyle(InteractiveCardButtonStyle())
                                }
                                
                                GlassCard(cornerRadius: 18, paddingAmount: 16) {
                                    NavigationLink(destination: UserHairImagesView(user: user)) {
                                        DashboardRow(
                                            icon: "photo.stack.fill",
                                            title: langManager.text("my_hair_photos"),
                                            subtitle: langManager.text("my_hair_photos_desc"),
                                            iconGradient: LinearGradient(colors: [Color.teal, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                            badgeText: "GALLERY",
                                            badgeColor: .teal
                                        )
                                    }
                                    .buttonStyle(InteractiveCardButtonStyle())
                                }
                            }
                        }

                        // ── SECTION 3: Hair Assessments & Care ──
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeaderView(
                                title: langManager.text("assessments_and_experts"),
                                subtitle: langManager.text("specialist_care"),
                                icon: "sparkles"
                            )
                            
                            // Quiz Hero Card
                            GlassCard(cornerRadius: 20, paddingAmount: 16) {
                                NavigationLink(destination: HairAnalysis13QuizView(user: user)) {
                                    HStack(spacing: 16) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .fill(AppTheme.brandGradient)
                                                .frame(width: 52, height: 52)
                                                .shadow(color: AppTheme.primaryBrand.opacity(0.3), radius: 6, y: 3)
                                            
                                            Image(systemName: "doc.text.fill")
                                                .font(.system(size: 22, weight: .semibold))
                                                .foregroundColor(.white)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 3) {
                                            HStack {
                                                Text(langManager.text("hair_growth_quiz"))
                                                    .font(.headline.weight(.bold))
                                                    .foregroundColor(AppTheme.titleText)
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.85)
                                                Spacer()
                                                Text("12 QUESTIONS")
                                                    .font(.system(size: 9, weight: .heavy))
                                                    .foregroundColor(AppTheme.primaryBrand)
                                                    .padding(.horizontal, 7)
                                                    .padding(.vertical, 3)
                                                    .background(AppTheme.primaryBrand.opacity(0.12))
                                                    .clipShape(Capsule())
                                            }
                                            Text(langManager.text("hair_growth_quiz_desc"))
                                                .font(.caption)
                                                .foregroundColor(AppTheme.bodyText(0.75))
                                                .lineLimit(2)
                                        }
                                        
                                        Image(systemName: "chevron.right.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(AppTheme.primaryBrand.opacity(0.8))
                                    }
                                }
                            }
                            .buttonStyle(InteractiveCardButtonStyle())

                            LazyVGrid(columns: AppTheme.dashboardColumns(sizeClass), spacing: 14) {
                                GlassCard(cornerRadius: 18, paddingAmount: 16) {
                                    NavigationLink(destination: QuizReportsView(user: user)) {
                                        DashboardRow(
                                            icon: "chart.bar.fill",
                                            title: langManager.text("quiz_reports"),
                                            subtitle: langManager.text("quiz_reports_desc"),
                                            iconGradient: LinearGradient(colors: [Color.indigo, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                    }
                                    .buttonStyle(InteractiveCardButtonStyle())
                                }
                                
                                GlassCard(cornerRadius: 18, paddingAmount: 16) {
                                    NavigationLink(destination: BookAppointmentView(user: user)) {
                                        DashboardRow(
                                            icon: "calendar.badge.plus",
                                            title: langManager.text("book_consultation"),
                                            subtitle: langManager.text("select_slot_subtitle"),
                                            iconGradient: LinearGradient(colors: [Color.blue, Color.cyan], startPoint: .topLeading, endPoint: .bottomTrailing),
                                            badgeText: "BOOK",
                                            badgeColor: .blue
                                        )
                                    }
                                    .buttonStyle(InteractiveCardButtonStyle())
                                }
                                
                                GlassCard(cornerRadius: 18, paddingAmount: 16) {
                                    NavigationLink(destination: UserAppointmentsView(user: user)) {
                                        DashboardRow(
                                            icon: "calendar",
                                            title: langManager.text("my_consultations"),
                                            subtitle: langManager.text("my_consultations_desc"),
                                            iconGradient: LinearGradient(colors: [Color.teal, Color.indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        )
                                    }
                                    .buttonStyle(InteractiveCardButtonStyle())
                                }
                            }
                        }

                        // ── SECTION 4: AI Hair Assistant at the Bottom of Home View ──
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeaderView(
                                title: "AI Assistant",
                                subtitle: "ASK & LEARN",
                                icon: "bubble.left.and.bubble.right.fill"
                            )
                            
                            GlassCard(cornerRadius: 22, paddingAmount: 18) {
                                VStack(alignment: .leading, spacing: 14) {
                                    HStack(spacing: 14) {
                                        ZStack {
                                            Circle()
                                                .fill(AppTheme.brandGradient)
                                                .frame(width: 52, height: 52)
                                                .shadow(color: AppTheme.primaryBrand.opacity(0.35), radius: 8, y: 4)
                                            
                                            Image(systemName: "sparkles")
                                                .font(.system(size: 24, weight: .bold))
                                                .foregroundColor(.white)
                                            
                                            Circle()
                                                .fill(AppTheme.emeraldMint)
                                                .frame(width: 12, height: 12)
                                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                                .offset(x: 18, y: -18)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 6) {
                                                Text("Hair Journey AI Assistant")
                                                    .font(.headline.weight(.bold))
                                                    .foregroundColor(AppTheme.titleText)
                                                
                                                Text("CHAT")
                                                    .font(.system(size: 8, weight: .heavy))
                                                    .tracking(0.5)
                                                    .foregroundColor(AppTheme.primaryBrand)
                                                    .padding(.horizontal, 6)
                                                    .padding(.vertical, 2)
                                                    .background(AppTheme.primaryBrand.opacity(0.12))
                                                    .clipShape(Capsule())
                                            }
                                            
                                            Text("Chat with our AI guide anytime. Get answers on serum application, photo tracking, shedding, and routine analysis.")
                                                .font(.caption)
                                                .foregroundColor(AppTheme.bodyText(0.78))
                                                .lineLimit(3)
                                        }
                                    }
                                    
                                    Button {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        showAIChat = true
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                                .font(.system(size: 14, weight: .bold))
                                            Text("Chat with AI Assistant")
                                                .font(.subheadline.weight(.bold))
                                        }
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 13)
                                        .background(AppTheme.brandGradient)
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                        .shadow(color: AppTheme.primaryBrand.opacity(0.3), radius: 6, y: 3)
                                    }
                                }
                            }
                        }

                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal, 16)
                    .frame(maxWidth: AppTheme.maxContentWidth(sizeClass))
                    .frame(maxWidth: .infinity, alignment: .top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .bottomTrailing) {
                    HairAIFloatingButton {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        showAIChat = true
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
            .sheet(isPresented: $showAIChat) {
                HairAIChatView()
                    .presentationDragIndicator(.visible)
            }
            .tabItem { Label(langManager.text("home"), systemImage: "house.fill") }

            ProfileView(user: user)
                .tabItem { Label(langManager.text("profile"), systemImage: "person.crop.circle.fill") }
        }
        .onAppear {
            animate = true
            fetchCompliancePreview()
        }
    }
    
    @ViewBuilder
    func dayDot(offset: Int) -> some View {
        let targetDate = Calendar.current.date(byAdding: .day, value: -(6 - offset), to: Date()) ?? Date()
        let df = DateFormatter()
        let _ = df.dateFormat = "yyyy-MM-dd"
        let isDone = recentLogs.contains(df.string(from: targetDate))
        
        Circle()
            .fill(isDone ? AppTheme.emeraldMint : Color.black.opacity(0.12))
            .frame(width: 10, height: 10)
            .scaleEffect(isDone ? 1.15 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.6).delay(Double(offset) * 0.04), value: isDone)
            .overlay(
                Circle()
                    .stroke(isDone ? AppTheme.emeraldMint.opacity(0.6) : Color.clear, lineWidth: 1)
            )
    }
}

