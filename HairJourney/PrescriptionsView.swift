import SwiftUI

// MARK: - Model
struct PrescriptionItem: Codable, Identifiable {
    var id: String
    var doctor_name: String
    var medicines: String
    var notes: String
    var created_at: String
}

struct PrescriptionsView: View {
    var user: User
    @State private var prescriptions: [PrescriptionItem] = []
    @State private var animate = false
    @State private var isLoading = true
    @State private var selectedTab: TrackerTab = .today
    
    enum TrackerTab: String, CaseIterable, Identifiable {
        case today = "Today's Schedule"
        case all = "Active Regimens"
        var id: String { rawValue }
    }
    
    // Add Routine state
    @State private var showAddSheet = false
    @State private var newMedicine = ""
    @State private var newFrequency = 1
    @State private var newCategory = "Topical Serum"
    @State private var newNotes = ""
    @State private var isSubmitting = false
    
    // Daily Dose Tracking
    @State private var takenDoses: Set<String> = []
    
    let categories = ["Topical Serum", "Drops", "Capsule / Tablet", "Care Shampoo", "Scalp Tonic"]
    
    var todayKey: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
    
    var todayDisplayString: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: Date())
    }
    
    func doseKey(rxId: String, medName: String, doseIndex: Int) -> String {
        "\(todayKey)_\(rxId)_\(medName)_\(doseIndex)"
    }
    
    func isDoseTaken(rxId: String, medName: String, doseIndex: Int) -> Bool {
        takenDoses.contains(doseKey(rxId: rxId, medName: medName, doseIndex: Int(doseIndex)))
    }
    
    func toggleDose(rxId: String, medName: String, doseIndex: Int) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let key = doseKey(rxId: rxId, medName: medName, doseIndex: doseIndex)
        if takenDoses.contains(key) {
            takenDoses.remove(key)
        } else {
            takenDoses.insert(key)
        }
        saveTakenDoses()
        syncSerumLogIfApplicable()
    }
    
    func loadTakenDoses() {
        let saved = UserDefaults.standard.stringArray(forKey: "medicine_tracker_doses_\(user.id)_\(todayKey)") ?? []
        takenDoses = Set(saved)
    }
    
    func saveTakenDoses() {
        UserDefaults.standard.set(Array(takenDoses), forKey: "medicine_tracker_doses_\(user.id)_\(todayKey)")
    }
    
    func syncSerumLogIfApplicable() {
        // Automatically sync today's completed doses to backend log_serum so calendar shows compliance
        let count = takenDoses.count
        guard let url = URL(string: APIService.baseURL + "log_serum.php") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "user_id": user.id,
            "log_date": todayKey,
            "times_used": count
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request).resume()
    }
    
    // Total scheduled doses across all prescriptions for today
    var totalDailyDoses: Int {
        var total = 0
        for rx in prescriptions {
            let meds = rx.medicines.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            let freq = extractFrequency(from: rx.notes)
            total += meds.count * freq
        }
        return max(1, total)
    }
    
    var completedDosesCount: Int {
        var count = 0
        for rx in prescriptions {
            let meds = rx.medicines.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            let freq = extractFrequency(from: rx.notes)
            for med in meds {
                for i in 0..<freq {
                    if isDoseTaken(rxId: rx.id, medName: med, doseIndex: i) {
                        count += 1
                    }
                }
            }
        }
        return count
    }
    
    var todayCompliancePercent: Double {
        let total = totalDailyDoses
        return min(1.0, Double(completedDosesCount) / Double(total))
    }
    
    func extractFrequency(from notes: String) -> Int {
        if notes.contains("3x") { return 3 }
        if notes.contains("2x") { return 2 }
        return 1
    }
    
    func doseLabel(for index: Int, total: Int) -> (time: String, period: String) {
        if total == 1 {
            return ("09:00 AM", "Morning Dose")
        } else if total == 2 {
            return index == 0 ? ("09:00 AM", "Morning Dose") : ("09:00 PM", "Night Dose")
        } else {
            switch index {
            case 0: return ("08:00 AM", "Morning Dose")
            case 1: return ("02:00 PM", "Afternoon Dose")
            default: return ("09:00 PM", "Night Dose")
            }
        }
    }

    func fetchPrescriptions() {
        guard let url = URL(string: APIService.baseURL + "get_prescriptions.php?user_id=\(user.id)") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                isLoading = false
                guard let data = data else { return }
                prescriptions = (try? JSONDecoder().decode([PrescriptionItem].self, from: data)) ?? []
            }
        }.resume()
    }
    
    func savePrescription() {
        isSubmitting = true
        let categoryTag = " [\(newCategory)]"
        let fullNotes = (newNotes.isEmpty ? "Daily application" : newNotes) + categoryTag + " [Frequency: \(newFrequency)x/day]"
        
        let body: [String: Any] = [
            "user_id": user.id,
            "doctor_id": 0, // 0 handles self-prescription / self-regimen in backend
            "medicines": newMedicine,
            "notes": fullNotes
        ]
        
        guard let url = URL(string: APIService.baseURL + "add_prescription.php"),
              let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            isSubmitting = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, res, err in
            DispatchQueue.main.async {
                isSubmitting = false
                showAddSheet = false
                
                // Update reminder preferences
                var prefs = SerumReminderPrefs.load()
                prefs.timesPerDay = newFrequency
                prefs.save()
                
                // Sync to backend Cloud
                let fmt = DateFormatter()
                fmt.dateFormat = "HH:mm"
                let bodyDict: [String: Any] = [
                    "user_id": user.id,
                    "frequency": prefs.timesPerDay,
                    "time_1": fmt.string(from: prefs.time1),
                    "time_2": fmt.string(from: prefs.time2),
                    "time_3": fmt.string(from: prefs.time3)
                ]
                if let url = URL(string: APIService.baseURL + "update_reminders.php") {
                    var hr = URLRequest(url: url)
                    hr.httpMethod = "POST"
                    hr.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    hr.httpBody = try? JSONSerialization.data(withJSONObject: bodyDict)
                    URLSession.shared.dataTask(with: hr).resume()
                }
                
                // Clear form
                newMedicine = ""
                newNotes = ""
                newFrequency = 1
                isLoading = true
                fetchPrescriptions()
            }
        }.resume()
    }

    func formattedDate(_ s: String) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let d = f.date(from: s) {
            f.dateStyle = .medium
            return f.string(from: d)
        }
        return s
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // Header
                    VStack(spacing: 6) {
                        HStack(spacing: 6) {
                            Text("CARE REGIMEN TRACKER")
                                .font(.system(size: 11, weight: .heavy))
                                .tracking(1.2)
                                .foregroundColor(AppTheme.primaryBrand)
                            Image(systemName: "sparkles")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.primaryBrand)
                        }
                        
                        Text("Medicine & Care Tracker")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.titleText)
                        
                        Text("Log daily hair serums, tonics & specialist recommended regimens")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.bodyText(0.75))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 14)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -15)
                    .animation(.easeOut(duration: 0.6), value: animate)

                    // Today Adherence Hero Progress Card
                    GlassCard(cornerRadius: 22, paddingAmount: 20) {
                        HStack(spacing: 18) {
                            // Circular Gauge
                            ZStack {
                                Circle()
                                    .stroke(Color.black.opacity(0.06), lineWidth: 10)
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat(max(0.02, todayCompliancePercent)))
                                    .stroke(
                                        todayCompliancePercent >= 1.0 ? AnyShapeStyle(AppTheme.mintGradient) :
                                        AnyShapeStyle(AppTheme.brandGradient),
                                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                                    )
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 80, height: 80)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: todayCompliancePercent)
                                
                                VStack(spacing: 1) {
                                    Text("\(completedDosesCount)/\(totalDailyDoses)")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(AppTheme.titleText)
                                    Text("DOSES")
                                        .font(.system(size: 8, weight: .heavy))
                                        .foregroundColor(AppTheme.bodyText(0.6))
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text(todayDisplayString)
                                        .font(.caption.weight(.bold))
                                        .foregroundColor(AppTheme.primaryBrand)
                                    
                                    if todayCompliancePercent >= 1.0 && !prescriptions.isEmpty {
                                        Text("ALL DONE")
                                            .font(.system(size: 9, weight: .heavy))
                                            .foregroundColor(AppTheme.emeraldMint)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(AppTheme.emeraldMint.opacity(0.12))
                                            .clipShape(Capsule())
                                    }
                                }
                                
                                Text(todayCompliancePercent >= 1.0 && !prescriptions.isEmpty ? "All routines completed today!" : "Daily Adherence Progress")
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(AppTheme.titleText)
                                
                                Text(prescriptions.isEmpty ? "No routines logged yet. Tap + to add one." : "Check off your daily serum doses to maintain your care streak.")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.bodyText(0.75))
                                    .lineLimit(2)
                            }
                            
                            Spacer(minLength: 0)
                        }
                    }
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 15)
                    .animation(.easeOut(duration: 0.65), value: animate)

                    // Tab Picker
                    Picker("Tracker View", selection: $selectedTab) {
                        ForEach(TrackerTab.allCases) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 2)

                    if isLoading {
                        VStack(spacing: 12) {
                            ProgressView().tint(AppTheme.primaryBrand)
                            Text("Loading care routines...")
                                .font(.caption)
                                .foregroundColor(AppTheme.bodyText(0.7))
                        }
                        .padding(.top, 30)
                    } else if prescriptions.isEmpty {
                        // Empty state
                        GlassCard(cornerRadius: 22, paddingAmount: 24) {
                            VStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.primaryBrand.opacity(0.12))
                                        .frame(width: 64, height: 64)
                                    Image(systemName: "pills.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(AppTheme.primaryBrand)
                                }
                                
                                Text("No Active Care Routines")
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(AppTheme.titleText)
                                
                                Text("Add your daily hair serum, vitamins, or wait for your specialist to recommend a personalized care plan.")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.bodyText(0.75))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 10)
                                
                                Button {
                                    showAddSheet = true
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "plus")
                                        Text("Add First Routine")
                                    }
                                }
                                .buttonStyle(PrimaryButtonStyle(height: 44))
                                .padding(.top, 4)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 10)
                    } else {
                        // TAB 1: Today's Dose Checklist
                        if selectedTab == .today {
                            VStack(spacing: 12) {
                                ForEach(prescriptions) { rx in
                                    let meds = rx.medicines.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                                    let freq = extractFrequency(from: rx.notes)
                                    
                                    ForEach(meds, id: \.self) { med in
                                        ForEach(0..<freq, id: \.self) { doseIdx in
                                            let isTaken = isDoseTaken(rxId: rx.id, medName: med, doseIndex: doseIdx)
                                            let doseInfo = doseLabel(for: doseIdx, total: freq)
                                            
                                            GlassCard(cornerRadius: 18, paddingAmount: 16) {
                                                HStack(spacing: 14) {
                                                    // Time badge
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(doseInfo.period.uppercased())
                                                            .font(.system(size: 9, weight: .heavy))
                                                            .foregroundColor(AppTheme.primaryBrand)
                                                        Text(doseInfo.time)
                                                            .font(.subheadline.weight(.bold))
                                                            .foregroundColor(AppTheme.titleText)
                                                    }
                                                    .frame(width: 85, alignment: .leading)
                                                    
                                                    Divider().frame(height: 36).opacity(0.5)
                                                    
                                                    // Medicine details
                                                    VStack(alignment: .leading, spacing: 3) {
                                                        Text(med)
                                                            .font(.system(size: 15, weight: .bold))
                                                            .foregroundColor(AppTheme.titleText)
                                                            .lineLimit(1)
                                                        
                                                        Text(rx.doctor_name == "Self" ? "Self Regimen" : "Specialist \(rx.doctor_name.replacingOccurrences(of: "Dr. ", with: "").replacingOccurrences(of: "Dr.", with: ""))")
                                                            .font(.caption2)
                                                            .foregroundColor(AppTheme.bodyText(0.7))
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                    // Interactive Check button
                                                    Button {
                                                        toggleDose(rxId: rx.id, medName: med, doseIndex: doseIdx)
                                                    } label: {
                                                        HStack(spacing: 6) {
                                                            Image(systemName: isTaken ? "checkmark.circle.fill" : "circle")
                                                                .font(.system(size: 22, weight: .semibold))
                                                                .foregroundColor(isTaken ? AppTheme.emeraldMint : AppTheme.bodyText(0.4))
                                                            
                                                            Text(isTaken ? "Taken" : "Take")
                                                                .font(.caption.weight(.bold))
                                                                .foregroundColor(isTaken ? AppTheme.emeraldMint : AppTheme.titleText)
                                                        }
                                                        .padding(.horizontal, 10)
                                                        .padding(.vertical, 6)
                                                        .background(isTaken ? AppTheme.emeraldMint.opacity(0.12) : Color.white.opacity(0.7))
                                                        .clipShape(Capsule())
                                                        .overlay(Capsule().stroke(isTaken ? AppTheme.emeraldMint.opacity(0.4) : Color.black.opacity(0.08), lineWidth: 1))
                                                    }
                                                    .buttonStyle(PlainButtonStyle())
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            // TAB 2: Active Regimens Overview
                            VStack(spacing: 14) {
                                ForEach(Array(prescriptions.enumerated()), id: \.element.id) { idx, rx in
                                    GlassCard(cornerRadius: 20, paddingAmount: 18) {
                                        VStack(alignment: .leading, spacing: 14) {
                                            
                                            // Header
                                            HStack {
                                                HStack(spacing: 10) {
                                                    ZStack {
                                                        Circle()
                                                            .fill(rx.doctor_name == "Self" ? AppTheme.primaryBrand.opacity(0.12) : AppTheme.emeraldMint.opacity(0.15))
                                                            .frame(width: 40, height: 40)
                                                        
                                                        Image(systemName: rx.doctor_name == "Self" ? "person.fill" : "sparkles")
                                                            .foregroundColor(rx.doctor_name == "Self" ? AppTheme.primaryBrand : AppTheme.emeraldMint)
                                                            .font(.system(size: 18))
                                                    }
                                                    
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        Text(rx.doctor_name == "Self" ? "Personal Care Routine" : "Specialist \(rx.doctor_name.replacingOccurrences(of: "Dr. ", with: "").replacingOccurrences(of: "Dr.", with: ""))")
                                                            .font(.system(size: 15, weight: .bold))
                                                            .foregroundColor(AppTheme.titleText)
                                                        Text("Added: \(formattedDate(rx.created_at))")
                                                            .font(.caption2)
                                                            .foregroundColor(AppTheme.bodyText(0.7))
                                                    }
                                                }
                                                
                                                Spacer()
                                                
                                                Text("Plan #\(idx + 1)")
                                                    .font(.system(size: 10, weight: .heavy))
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(AppTheme.primaryBrand.opacity(0.1))
                                                    .foregroundColor(AppTheme.primaryBrand)
                                                    .clipShape(Capsule())
                                            }
                                            
                                            Divider().opacity(0.5)
                                            
                                            // Products
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text("Care Products & Regimens")
                                                    .font(.caption.weight(.bold))
                                                    .foregroundColor(AppTheme.bodyText(0.7))
                                                
                                                let meds = rx.medicines.components(separatedBy: ",")
                                                ForEach(meds, id: \.self) { med in
                                                    HStack(spacing: 8) {
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .foregroundColor(AppTheme.emeraldMint)
                                                            .font(.caption)
                                                        Text(med.trimmingCharacters(in: .whitespaces))
                                                            .font(.subheadline.bold())
                                                            .foregroundColor(AppTheme.titleText)
                                                        Spacer()
                                                    }
                                                    .padding(.vertical, 8)
                                                    .padding(.horizontal, 12)
                                                    .background(AppTheme.emeraldMint.opacity(0.08))
                                                    .cornerRadius(10)
                                                }
                                            }
                                            
                                            // Instructions / Notes
                                            if !rx.notes.isEmpty {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text("Directions & Frequency")
                                                        .font(.caption.weight(.bold))
                                                        .foregroundColor(AppTheme.bodyText(0.7))
                                                    
                                                    Text(rx.notes)
                                                        .font(.caption)
                                                        .foregroundColor(AppTheme.titleText)
                                                        .padding(10)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .background(Color.white.opacity(0.7))
                                                        .cornerRadius(10)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Academic Thesis Project Disclaimer
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.primaryBrand)
                            .padding(.top, 1)
                        Text("HairJourney Routine & Medicine Tracker is developed for educational habit adherence and wellness logging as part of an academic student thesis project.")
                            .font(.caption2)
                            .foregroundColor(AppTheme.bodyText(0.7))
                            .lineSpacing(2)
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 10)

                    Spacer(minLength: 90)
                }
                .padding(.horizontal, 16)
            }
            .refreshable {
                fetchPrescriptions()
            }
            
            // Add FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        showAddSheet = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.headline.bold())
                            Text("Add Routine")
                                .font(.subheadline.bold())
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(AppTheme.brandGradient)
                        .clipShape(Capsule())
                        .shadow(color: AppTheme.primaryBrand.opacity(0.35), radius: 10, y: 5)
                    }
                    .padding(20)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Care Routines")
                    .font(.headline.bold())
                    .foregroundColor(AppTheme.titleText)
            }
        }
        .onAppear {
            animate = true
            loadTakenDoses()
            fetchPrescriptions()
        }
        .sheet(isPresented: $showAddSheet) {
            addPrescriptionSheet()
        }
    }
    
    @ViewBuilder
    func addPrescriptionSheet() -> some View {
        ZStack {
            AppBackgroundView()
            
            VStack(spacing: 18) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.black.opacity(0.2))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                
                VStack(spacing: 4) {
                    Text("Add Care Regimen")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.titleText)
                    Text("Track your hair serum, tonic, or supplement routine")
                        .font(.caption)
                        .foregroundColor(AppTheme.bodyText(0.75))
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // Category Picker
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Regimen Type")
                                .font(.caption.bold())
                                .foregroundColor(AppTheme.bodyText)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(categories, id: \.self) { cat in
                                        let isSel = newCategory == cat
                                        Button {
                                            newCategory = cat
                                        } label: {
                                            Text(cat)
                                                .font(.caption.weight(.semibold))
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 7)
                                                .background(isSel ? AppTheme.primaryBrand : Color.white.opacity(0.7))
                                                .foregroundColor(isSel ? .white : AppTheme.titleText)
                                                .clipShape(Capsule())
                                                .overlay(Capsule().stroke(isSel ? Color.clear : Color.black.opacity(0.08), lineWidth: 1))
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                        
                        // Product Name
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Product / Regimen Name")
                                .font(.caption.bold())
                                .foregroundColor(AppTheme.bodyText)
                            TextField("e.g. Minoxidil 5% Topical / Rosemary Oil", text: $newMedicine)
                                .font(.subheadline)
                                .padding(12)
                                .background(Color.white.opacity(0.75))
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.06), lineWidth: 1))
                        }
                        
                        // Frequency
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Daily Application Frequency")
                                .font(.caption.bold())
                                .foregroundColor(AppTheme.bodyText)
                            Picker("Frequency", selection: $newFrequency) {
                                Text("1x / day").tag(1)
                                Text("2x / day").tag(2)
                                Text("3x / day").tag(3)
                            }
                            .pickerStyle(.segmented)
                            
                            Text("Automatically schedules your daily Serum & Routine reminders.")
                                .font(.caption2)
                                .foregroundColor(AppTheme.bodyText(0.7))
                        }
                        
                        // Notes / Directions
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Usage Directions / Notes (Optional)")
                                .font(.caption.bold())
                                .foregroundColor(AppTheme.bodyText)
                            TextField("e.g. Apply 1ml at bedtime onto dry scalp", text: $newNotes)
                                .font(.subheadline)
                                .padding(12)
                                .background(Color.white.opacity(0.75))
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.06), lineWidth: 1))
                        }
                        
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    savePrescription()
                } label: {
                    HStack {
                        if isSubmitting { ProgressView().tint(.white).padding(.trailing, 4) }
                        Text(isSubmitting ? "Saving Regimen..." : "Save Regimen")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(newMedicine.trimmingCharacters(in: .whitespaces).isEmpty || isSubmitting)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .presentationDetents([.fraction(0.72), .large])
    }
}
