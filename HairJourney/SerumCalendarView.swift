import SwiftUI
import UserNotifications

// MARK: - Model
struct SerumLog: Codable {
    var log_date: String
    var times_used: String
}

// MARK: - Reminder frequency preference (persisted via UserDefaults)
struct SerumReminderPrefs {
    static let key = "serum_reminder_prefs"
    
    var timesPerDay: Int       // 1, 2, or 3
    var time1: Date            // First dose time
    var time2: Date            // Second dose time (if 2 or 3)
    var time3: Date            // Third dose time (if 3)
    
    static var `default`: SerumReminderPrefs {
        var cal = Calendar.current
        func makeTime(hour: Int, minute: Int) -> Date {
            cal.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
        }
        return SerumReminderPrefs(
            timesPerDay: 1,
            time1: makeTime(hour: 9,  minute: 0),
            time2: makeTime(hour: 21, minute: 0),
            time3: makeTime(hour: 15, minute: 0)
        )
    }
    
    func save() {
        let dict: [String: Any] = [
            "timesPerDay": timesPerDay,
            "time1": time1.timeIntervalSinceReferenceDate,
            "time2": time2.timeIntervalSinceReferenceDate,
            "time3": time3.timeIntervalSinceReferenceDate
        ]
        UserDefaults.standard.set(dict, forKey: SerumReminderPrefs.key)
    }
    
    static func load() -> SerumReminderPrefs {
        guard let dict = UserDefaults.standard.dictionary(forKey: key) else { return .default }
        var p = SerumReminderPrefs.default
        p.timesPerDay = dict["timesPerDay"] as? Int ?? 1
        if let t1 = dict["time1"] as? Double { p.time1 = Date(timeIntervalSinceReferenceDate: t1) }
        if let t2 = dict["time2"] as? Double { p.time2 = Date(timeIntervalSinceReferenceDate: t2) }
        if let t3 = dict["time3"] as? Double { p.time3 = Date(timeIntervalSinceReferenceDate: t3) }
        return p
    }
}

// MARK: - Serum Calendar View
struct SerumCalendarView: View {
    var user: User
    
    @State private var currentDate = Date()
    @State private var logs: [String: Int] = [:]
    @State private var selectedDate: String? = nil
    @State private var showLogSheet = false
    @State private var selectedTimes = 1
    @State private var isLoading = false
    
    // Reminder state
    @State private var reminderPrefs = SerumReminderPrefs.load()
    @State private var showReminderSheet = false
    @State private var reminderActive = false
    @State private var showPermissionAlert = false
    @State private var reminderSaveMsg = ""
    
    // Animation states
    @State private var animateGlow = false
    @State private var tappedDate: String? = nil
    
    private let calendar = Calendar.current
    private let dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    // MARK: Compliance relies on reminderPrefs.timesPerDay now matching Prescription
    var weeklyCompliance: (days: Int, percent: Double) {
        let today = Date()
        var daysLogged = 0
        let targetSpeed = reminderPrefs.timesPerDay
        for offset in 0..<7 {
            if let d = calendar.date(byAdding: .day, value: -offset, to: today) {
                let key = dateKey(d)
                if let v = logs[key], v >= targetSpeed { daysLogged += 1 }
            }
        }
        return (daysLogged, Double(daysLogged) / 7.0 * 100)
    }
    
    var complianceColor: Color {
        let p = weeklyCompliance.percent
        if p >= 80 { return .green }
        if p >= 50 { return .orange }
        return .red
    }
    
    // MARK: Helpers
    func dateKey(_ d: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return f.string(from: d)
    }
    
    func displayMonth() -> String {
        let f = DateFormatter(); f.dateFormat = "MMMM yyyy"
        return f.string(from: currentDate)
    }
    
    func daysInMonth() -> [Date?] {
        let comps = calendar.dateComponents([.year, .month], from: currentDate)
        guard let firstDay = calendar.date(from: comps),
              let range = calendar.range(of: .day, in: .month, for: firstDay) else { return [] }
        let weekday = calendar.component(.weekday, from: firstDay) - 1
        var items: [Date?] = Array(repeating: nil, count: weekday)
        for day in range {
            if let d = calendar.date(byAdding: .day, value: day - 1, to: firstDay) { items.append(d) }
        }
        return items
    }
    
    func colorFor(_ d: Date) -> Color {
        let key = dateKey(d)
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: d)
        
        if target > today { return Color.gray.opacity(0.25) }
        
        let targetSpeed = reminderPrefs.timesPerDay
        
        if let v = logs[key] {
            if v >= targetSpeed { return .green }
            if v > 0 { return .orange } // Partially compliant
            return .red.opacity(0.7)
        }
        return target < today ? .red.opacity(0.5) : Color.blue.opacity(0.2)
    }
    
    func timeLabel(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "hh:mm a"
        return f.string(from: date)
    }
    
    // MARK: Fetch Logs
    func fetchLogs() {
        let month = calendar.component(.month, from: currentDate)
        let year  = calendar.component(.year,  from: currentDate)
        guard let url = URL(string: APIService.baseURL + "get_serum_logs.php?user_id=\(user.id)&month=\(month)&year=\(year)") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                guard let data = data,
                      let decoded = try? JSONDecoder().decode([SerumLog].self, from: data) else { return }
                var map: [String: Int] = [:]
                for log in decoded { map[log.log_date] = Int(log.times_used) ?? 0 }
                logs = map
            }
        }.resume()
    }
    
    // MARK: Save Log
    func saveLog() {
        guard let dateStr = selectedDate else { return }
        isLoading = true
        let body: [String: Any] = ["user_id": Int(user.id) ?? 0, "date": dateStr, "times_used": selectedTimes]
        guard let url = URL(string: APIService.baseURL + "log_serum_usage.php"),
              let jsonData = try? JSONSerialization.data(withJSONObject: body) else { isLoading = false; return }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = jsonData
        URLSession.shared.dataTask(with: req) { _, _, _ in
            DispatchQueue.main.async {
                logs[dateStr] = selectedTimes
                isLoading = false
                showLogSheet = false
            }
        }.resume()
    }
    
    // MARK: Schedule Reminders (1 / 2 / 3 per day)
    func scheduleReminders(silently: Bool? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                guard granted else { showPermissionAlert = true; return }
                
                let ids = ["serum_dose_1", "serum_dose_2", "serum_dose_3"]
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
                
                let times = [reminderPrefs.time1, reminderPrefs.time2, reminderPrefs.time3]
                let labels = ["Morning", "Afternoon/Evening", "Night"]
                let doseNums = ["1st", "2nd", "3rd"]
                
                for i in 0..<reminderPrefs.timesPerDay {
                    let content = UNMutableNotificationContent()
                    content.title = "💊 Serum Reminder – \(doseNums[i]) dose"
                    content.body  = "\(labels[i]) reminder: Apply your hair serum now! Keep your streak going 🔥"
                    content.sound = .defaultCritical
                    content.badge = 1
                    
                    var comps = calendar.dateComponents([.hour, .minute], from: times[i])
                    comps.second = 0
                    let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
                    let request = UNNotificationRequest(identifier: ids[i], content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error { print("Notification error (\(ids[i])):", error) }
                    }
                }
                
                reminderPrefs.save()
                pushBackendReminders()
                reminderActive = true
                showReminderSheet = false
                if let silent = silently, silent { return }
                reminderSaveMsg = "✅ \(reminderPrefs.timesPerDay) reminder\(reminderPrefs.timesPerDay > 1 ? "s" : "") synced!"
            }
        }
    }
    
    func cancelReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["serum_dose_1", "serum_dose_2", "serum_dose_3"]
        )
        reminderActive = false
        reminderSaveMsg = ""
    }
    
    func checkExistingReminders() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                reminderActive = requests.contains { $0.identifier.hasPrefix("serum_dose") }
            }
        }
    }
    
    // MARK: Refresh State Helper
    func reloadReminderPrefs() {
        reminderPrefs = SerumReminderPrefs.load()
        fetchBackendReminders()
    }
    
    func fetchBackendReminders() {
        // String fallback for Any type user id
        var uIdStr = ""
        if let str = user.id as? String { uIdStr = str }
        else if let i = user.id as? Int { uIdStr = "\(i)" }
        
        guard let url = URL(string: APIService.baseURL + "get_reminders.php?user_id=\(uIdStr)") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async {
                if let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let rems = dict["reminders"] as? [String: Any] {
                   
                    if let f = rems["frequency"] as? String, let fInt = Int(f) {
                        reminderPrefs.timesPerDay = fInt
                    } else if let f = rems["frequency"] as? Int {
                        reminderPrefs.timesPerDay = f
                    }
                    
                    let fmt = DateFormatter()
                    fmt.dateFormat = "HH:mm"
                    if let t1 = rems["time_1"] as? String, let d1 = fmt.date(from: t1) {
                        reminderPrefs.time1 = combineTime(date: Date(), time: d1)
                    }
                    if let t2 = rems["time_2"] as? String, let d2 = fmt.date(from: t2) {
                        reminderPrefs.time2 = combineTime(date: Date(), time: d2)
                    }
                    if let t3 = rems["time_3"] as? String, let d3 = fmt.date(from: t3) {
                        reminderPrefs.time3 = combineTime(date: Date(), time: d3)
                    }
                    reminderPrefs.save()
                    
                    // Auto-sync local push notifications if not active but backend says so
                    if !reminderActive { scheduleReminders(silently: true) }
                }
            }
        }.resume()
    }
    
    func combineTime(date: Date, time: Date) -> Date {
        let cal = Calendar.current
        let tComps = cal.dateComponents([.hour, .minute], from: time)
        return cal.date(bySettingHour: tComps.hour ?? 0, minute: tComps.minute ?? 0, second: 0, of: date) ?? date
    }
    
    func pushBackendReminders() {
        guard let url = URL(string: APIService.baseURL + "update_reminders.php") else { return }
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        
        var uIdStr = ""
        if let s = user.id as? String { uIdStr = s }
        else if let i = user.id as? Int { uIdStr = "\(i)" }
        
        let body: [String: Any] = [
            "user_id": uIdStr,
            "frequency": reminderPrefs.timesPerDay,
            "time_1": fmt.string(from: reminderPrefs.time1),
            "time_2": fmt.string(from: reminderPrefs.time2),
            "time_3": fmt.string(from: reminderPrefs.time3)
        ]
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: req).resume()
    }

    // MARK: Body
    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // ── Header ──
                    VStack(spacing: 6) {
                        Text("Serum & Habit Tracker")
                            .font(.title2.bold()).foregroundColor(AppTheme.titleText)
                        HStack(spacing: 6) {
                            Image(systemName: "pills.fill")
                                .font(.caption)
                            Text("Active Target: \(reminderPrefs.timesPerDay)× daily")
                                .font(.subheadline.bold())
                        }
                        .foregroundColor(AppTheme.primaryBrand)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(AppTheme.primaryBrand.opacity(0.1))
                        .clipShape(Capsule())
                    }.padding(.top, 16)
                    
                    // ── Weekly Compliance Ring ──
                    GlassCard {
                        VStack(spacing: 16) {
                            Text("Weekly Compliance").font(.headline).foregroundColor(AppTheme.titleText)
                            HStack(spacing: 24) {
                                ZStack {
                                    if weeklyCompliance.percent >= 80 {
                                        Circle()
                                            .fill(AppTheme.complianceGradient)
                                            .frame(width: 110, height: 110)
                                            .blur(radius: 14)
                                            .opacity(animateGlow ? 0.5 : 0.1)
                                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animateGlow)
                                            .onAppear { animateGlow = true }
                                    }
                                    
                                    Circle().stroke(Color.gray.opacity(0.15), lineWidth: 14).frame(width: 110, height: 110)
                                    Circle()
                                        .trim(from: 0, to: CGFloat(weeklyCompliance.percent / 100))
                                        .stroke(weeklyCompliance.percent >= 80 ? AnyShapeStyle(AppTheme.complianceGradient) : AnyShapeStyle(complianceColor), style: StrokeStyle(lineWidth: 14, lineCap: .round))
                                        .frame(width: 110, height: 110)
                                        .rotationEffect(.degrees(-90))
                                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: weeklyCompliance.percent)
                                    VStack(spacing: 2) {
                                        Text(String(format: "%.1f%%", weeklyCompliance.percent))
                                            .font(.title3.bold()).foregroundColor(complianceColor)
                                        Text("Weekly").font(.caption2).foregroundColor(AppTheme.bodyText)
                                    }
                                }
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                        Text("\(weeklyCompliance.days) / 7 Days Met")
                                            .font(.subheadline.bold()).foregroundColor(AppTheme.titleText)
                                    }
                                    weekDayDots()
                                    Text(complianceLabel).font(.caption).foregroundColor(complianceColor).bold()
                                }
                            }
                        }
                    }
                    
                    // ── Calendar ──
                    GlassCard {
                        VStack(spacing: 14) {
                            HStack {
                                Button { changeMonth(-1) } label: { Image(systemName: "chevron.left").foregroundColor(AppTheme.accent).font(.title3) }
                                Spacer()
                                Text(displayMonth()).font(.title3.bold()).foregroundColor(AppTheme.titleText)
                                Spacer()
                                Button { changeMonth(1) } label: { Image(systemName: "chevron.right").foregroundColor(AppTheme.accent).font(.title3) }
                            }
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 6) {
                                ForEach(dayNames, id: \.self) { d in
                                    Text(d).font(.caption2.bold()).foregroundColor(AppTheme.bodyText)
                                }
                            }
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                                ForEach(daysInMonth().indices, id: \.self) { i in
                                    if let date = daysInMonth()[i] {
                                        let key = dateKey(date)
                                        let dayNum = calendar.component(.day, from: date)
                                        let isToday = calendar.isDateInToday(date)
                                        let count = logs[key] ?? 0
                                        let isFuture = calendar.startOfDay(for: date) > calendar.startOfDay(for: Date())
                                        Button {
                                            if !isFuture {
                                                let impact = UIImpactFeedbackGenerator(style: .medium)
                                                impact.impactOccurred()
                                                
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                                    tappedDate = key
                                                }
                                                
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                    withAnimation(.spring()) { tappedDate = nil }
                                                    selectedDate = key
                                                    selectedTimes = count > 0 ? count : reminderPrefs.timesPerDay
                                                    showLogSheet = true
                                                }
                                            }
                                        } label: {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 10).fill(colorFor(date)).frame(height: 38)
                                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(isToday ? AppTheme.accent : Color.clear, lineWidth: 2))
                                                VStack(spacing: 1) {
                                                    Text("\(dayNum)").font(.caption.bold())
                                                        .foregroundColor(isFuture ? AppTheme.bodyText(0.4) : .white)
                                                    if count > 0 {
                                                        Text(doseIcon(count)).font(.system(size: 8))
                                                    }
                                                }
                                            }
                                        }
                                        .scaleEffect(tappedDate == key ? 0.85 : 1.0)
                                        .disabled(isFuture)
                                    } else {
                                        Color.clear.frame(height: 38)
                                    }
                                }
                            }
                            HStack(spacing: 10) {
                                legendDot(.green, "Target Met")
                                legendDot(.orange, "Partial")
                                legendDot(.red.opacity(0.7), "Missed")
                            }.padding(.top, 4).frame(maxWidth: .infinity)
                        }
                    }
                    
                    // ── Smart Reminder Card ──
                    GlassCard {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                HStack(spacing: 6) {
                                    Image(systemName: "bell.fill").foregroundColor(.orange)
                                    Text("Serum Reminders").font(.headline).foregroundColor(AppTheme.titleText)
                                }
                                Spacer()
                                if reminderActive {
                                    Label("Active", systemImage: "checkmark.circle.fill")
                                        .font(.caption.bold()).foregroundColor(.green)
                                }
                            }
                            
                            if reminderActive {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Current Schedule (\(reminderPrefs.timesPerDay)× daily)")
                                        .font(.caption).foregroundColor(AppTheme.bodyText)
                                    
                                    HStack(spacing: 10) {
                                        reminderTimePill("1st Dose", timeLabel(reminderPrefs.time1), .orange)
                                        if reminderPrefs.timesPerDay >= 2 {
                                            reminderTimePill("2nd Dose", timeLabel(reminderPrefs.time2), .blue)
                                        }
                                    }
                                    if !reminderSaveMsg.isEmpty {
                                        Text(reminderSaveMsg).font(.caption).foregroundColor(.green)
                                    }
                                }
                                HStack(spacing: 10) {
                                    Button { showReminderSheet = true } label: {
                                        Label("Edit", systemImage: "pencil")
                                            .font(.caption.bold()).foregroundColor(AppTheme.accent)
                                            .padding(.horizontal, 14).padding(.vertical, 8)
                                            .background(Color.blue.opacity(0.1)).cornerRadius(10)
                                    }
                                    Button { cancelReminders() } label: {
                                        Label("Cancel All", systemImage: "bell.slash")
                                            .font(.caption.bold()).foregroundColor(.red)
                                            .padding(.horizontal, 14).padding(.vertical, 8)
                                            .background(Color.red.opacity(0.1)).cornerRadius(10)
                                    }
                                }
                            } else {
                                Text("Set daily reminders to stay on track with your serum application.")
                                    .font(.caption).foregroundColor(AppTheme.bodyText)
                                
                                Button { showReminderSheet = true } label: {
                                    HStack {
                                        Image(systemName: "alarm.fill")
                                        Text("Set Up Reminders")
                                    }
                                    .foregroundColor(.white).frame(maxWidth: .infinity).padding(12)
                                    .background(LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing))
                                    .cornerRadius(12).shadow(color: .orange.opacity(0.3), radius: 6, y: 3)
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Serum Calendar")
                    .font(.headline.bold())
                    .foregroundColor(AppTheme.titleText)
            }
        }
        .onAppear { fetchLogs(); checkExistingReminders(); reloadReminderPrefs() }
        .sheet(isPresented: $showLogSheet) { logBottomSheet() }
        .sheet(isPresented: $showReminderSheet) { reminderSetupSheet() }
        .alert("Notifications Disabled", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable notifications in iPhone Settings > HairJourney to receive serum reminders.")
        }
    }
    
    // MARK: - SubViews & UI Builders
    
    // BREAK DOWN Swift Type-checker complex block into small functions
    @ViewBuilder
    func frequencySelector() -> some View {
        HStack(spacing: 12) {
            ForEach([1, 2], id: \.self) { n in
                frequencyButton(n: n)
            }
        }.padding(.horizontal)
    }
    
    @ViewBuilder
    func frequencyButton(n: Int) -> some View {
        let isSelected = reminderPrefs.timesPerDay == n
        Button { reminderPrefs.timesPerDay = n } label: {
            VStack(spacing: 4) {
                Text("\(n)×").font(.title2.bold())
                Text(n == 1 ? "Once" : "Twice").font(.caption)
            }
            .foregroundColor(isSelected ? .white : AppTheme.titleText)
            .frame(maxWidth: .infinity).padding(.vertical, 14)
            .background(
                Group {
                    if isSelected {
                        AppTheme.premiumAccentGradient
                    } else {
                        Color.white.opacity(0.4)
                    }
                }
            )
            .cornerRadius(14)
            .shadow(color: isSelected ? .orange.opacity(0.3) : .clear, radius: 6)
        }
    }
    
    @ViewBuilder
    func timePickersList() -> some View {
        ScrollView {
            VStack(spacing: 16) {
                timePicker("🌅 1st Dose (Morning)", $reminderPrefs.time1)
                if reminderPrefs.timesPerDay >= 2 {
                    timePicker("🌇 2nd Dose (Evening)", $reminderPrefs.time2)
                }
            }.padding(.horizontal)
        }
        .frame(maxHeight: 260)
    }
    
    @ViewBuilder
    func reminderSetupSheet() -> some View {
        ZStack {
            AppTheme.gradient.ignoresSafeArea()
            VStack(spacing: 24) {
                RoundedRectangle(cornerRadius: 3).fill(.gray.opacity(0.4))
                    .frame(width: 40, height: 5).padding(.top, 14)
                
                Text("Set Up Reminders").font(.title3.bold()).foregroundColor(AppTheme.titleText)
                Text("How many times a day do you apply serum?")
                    .font(.subheadline).foregroundColor(AppTheme.bodyText).multilineTextAlignment(.center)
                
                frequencySelector()
                
                timePickersList()
                
                Button { scheduleReminders() } label: {
                    HStack {
                        Image(systemName: "bell.fill")
                        Text("Confirm & Set \(reminderPrefs.timesPerDay) Reminder\(reminderPrefs.timesPerDay > 1 ? "s" : "")")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white).frame(maxWidth: .infinity).padding(14)
                    .background(LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(14).shadow(color: .green.opacity(0.35), radius: 8, y: 3)
                }.padding(.horizontal)
                
                Button("Cancel") { showReminderSheet = false }
                    .foregroundColor(.red).padding(.bottom, 10)
            }
        }
        .presentationDetents([.fraction(0.82)])
        .presentationDragIndicator(.hidden)
    }
    
    @ViewBuilder
    func timePicker(_ label: String, _ binding: Binding<Date>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.subheadline.bold()).foregroundColor(AppTheme.titleText)
            DatePicker("", selection: binding, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .datePickerStyle(.wheel)
                .frame(height: 80)
                .clipped()
        }
        .padding(12).background(Color.white.opacity(0.45)).cornerRadius(14)
    }
    
    @ViewBuilder
    func logBottomSheet() -> some View {
        ZStack {
            AppTheme.gradient.ignoresSafeArea()
            VStack(spacing: 24) {
                RoundedRectangle(cornerRadius: 3).fill(.gray.opacity(0.4))
                    .frame(width: 40, height: 5).padding(.top, 12)
                Text("Log Serum Usage").font(.title3.bold()).foregroundColor(AppTheme.titleText)
                if let ds = selectedDate { Text(ds).font(.subheadline).foregroundColor(AppTheme.bodyText) }
                
                HStack(spacing: 16) {
                    ForEach([0, 1, 2], id: \.self) { val in
                        Button { selectedTimes = val } label: {
                            VStack(spacing: 6) {
                                Text(val == 0 ? "✗" : "\(val)×").font(.title2.bold())
                                Text(val == 0 ? "Missed" : val == 1 ? "Once" : "Twice").font(.caption)
                            }
                            .foregroundColor(selectedTimes == val ? .white : AppTheme.titleText)
                            .frame(width: 74, height: 74)
                            .background(selectedTimes == val ? (val == 0 ? Color.red : Color.green) : Color.white.opacity(0.3))
                            .cornerRadius(16)
                            .shadow(color: selectedTimes == val ? .black.opacity(0.15) : .clear, radius: 6)
                        }
                    }
                }
                Button {
                    if selectedTimes == 0 {
                        if let key = selectedDate { logs[key] = 0 }
                        showLogSheet = false
                    } else { saveLog() }
                } label: {
                    HStack {
                        if isLoading { ProgressView().tint(.white) }
                        Text(isLoading ? "Saving..." : "Save Log").fontWeight(.semibold)
                    }
                    .foregroundColor(.white).frame(maxWidth: .infinity).padding(14)
                    .background(AppTheme.premiumAccentGradient)
                    .cornerRadius(14).shadow(color: AppTheme.accent.opacity(0.35), radius: 8, y: 3)
                }
                .disabled(isLoading).padding(.horizontal)
                Spacer()
            }.padding(.horizontal)
        }
        .presentationDetents([.fraction(0.55)])
        .presentationDragIndicator(.hidden)
    }
    
    @ViewBuilder func reminderTimePill(_ label: String, _ time: String, _ color: Color) -> some View {
        VStack(spacing: 2) {
            Text(label).font(.system(size: 9)).foregroundColor(AppTheme.bodyText)
            Text(time).font(.caption.bold()).foregroundColor(color)
        }
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(color.opacity(0.1)).cornerRadius(8)
    }
    
    var complianceLabel: String {
        let p = weeklyCompliance.percent
        if p >= 80 { return "🌟 Target met!" }
        if p >= 50 { return "⚡ Partial adherence" }
        return "⚠️ Target missed"
    }
    
    @ViewBuilder func weekDayDots() -> some View {
        HStack(spacing: 4) {
            let targetSpeed = reminderPrefs.timesPerDay
            ForEach(0..<7, id: \.self) { offset in
                if let d = calendar.date(byAdding: .day, value: -(6 - offset), to: Date()) {
                    let v = logs[dateKey(d)] ?? 0
                    Circle().fill(v >= targetSpeed ? Color.green : (v > 0 ? Color.orange : Color.red.opacity(0.6)))
                        .frame(width: 10, height: 10)
                }
            }
        }
    }
    
    @ViewBuilder func legendDot(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3).fill(color).frame(width: 12, height: 12)
            Text(label).font(.caption2).foregroundColor(AppTheme.bodyText)
        }
    }
    
    func doseIcon(_ count: Int) -> String {
        switch count { case 1: return "1×"; case 2: return "2×"; case 3: return "3×"; default: return "" }
    }
    
    func changeMonth(_ dir: Int) {
        if let d = calendar.date(byAdding: .month, value: dir, to: currentDate) {
            currentDate = d; fetchLogs()
        }
    }
}
