import SwiftUI

// MARK: - Model Matches Backend
struct DoctorAppointment: Codable, Identifiable {
    var id: String
    var user_name: String   // backend field
    var slot_time: String
    var status: String
}

enum AppointmentFilter: String, CaseIterable {
    case all = "All"
    case pending = "Pending"
    case approved = "Approved"
    case rejected = "Declined"
}

struct AppointmentDateInfo {
    let month: String
    let day: String
    let weekday: String
    let time: String
    let fullDate: String
}

struct DoctorAppointmentsView: View {
    var doctor: User
    @State private var appointments: [DoctorAppointment] = []
    @State private var selectedFilter: AppointmentFilter = .all
    @State private var isLoading = true
    @State private var updatingId: String? = nil
    @State private var animate = false
    
    struct StatusUpdateRequest: Codable {
        let appointment_id: Int
        let status: String
    }
    
    // MARK: - Data Fetching
    func fetchAppointments(showLoadingIndicator: Bool = true, completion: (() -> Void)? = nil) {
        if showLoadingIndicator {
            isLoading = true
        }
        guard let url = URL(string: APIService.baseURL + "get_doctor_appointments.php?doctor_id=\(doctor.id)") else {
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
                    print("Fetch error:", error.localizedDescription)
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    self.appointments = try JSONDecoder().decode([DoctorAppointment].self, from: data)
                } catch {
                    print("Decode error:", error)
                }
            }
        }.resume()
    }
    
    // MARK: - Update Status
    func updateStatus(id: String, newStatus: String) {
        guard let url = URL(string: APIService.baseURL + "update_appointment_status.php"),
              let appointmentId = Int(id) else { return }
        
        updatingId = id
        let body = StatusUpdateRequest(appointment_id: appointmentId, status: newStatus)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                // Optimistically update in place for zero-delay responsiveness
                if let idx = self.appointments.firstIndex(where: { $0.id == id }) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        self.appointments[idx].status = newStatus
                    }
                }
                self.updatingId = nil
                self.fetchAppointments(showLoadingIndicator: false)
            }
        }.resume()
    }
    
    // MARK: - Date Helpers
    func parseAppointmentDate(_ dateString: String) -> AppointmentDateInfo {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = formatter.date(from: dateString) {
            let mFmt = DateFormatter()
            mFmt.dateFormat = "MMM"
            let month = mFmt.string(from: date).uppercased()
            
            let dFmt = DateFormatter()
            dFmt.dateFormat = "d"
            let day = dFmt.string(from: date)
            
            let wFmt = DateFormatter()
            wFmt.dateFormat = "EEE"
            let weekday = wFmt.string(from: date)
            
            let tFmt = DateFormatter()
            tFmt.dateFormat = "h:mm a"
            let time = tFmt.string(from: date)
            
            let fullFmt = DateFormatter()
            fullFmt.dateFormat = "EEEE, MMMM d, yyyy"
            let fullDate = fullFmt.string(from: date)
            
            return AppointmentDateInfo(month: month, day: day, weekday: weekday, time: time, fullDate: fullDate)
        }
        return AppointmentDateInfo(month: "APPT", day: "--", weekday: "", time: dateString, fullDate: dateString)
    }
    
    // MARK: - Filtered & Sorted Appointments
    var sortedAppointments: [DoctorAppointment] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        return appointments.sorted {
            guard let d1 = formatter.date(from: $0.slot_time),
                  let d2 = formatter.date(from: $1.slot_time) else { return false }
            return d1 < d2
        }
    }
    
    var filteredAppointments: [DoctorAppointment] {
        switch selectedFilter {
        case .all:
            return sortedAppointments
        case .pending:
            return sortedAppointments.filter { $0.status == "Pending" }
        case .approved:
            return sortedAppointments.filter { $0.status == "Approved" }
        case .rejected:
            return sortedAppointments.filter { $0.status == "Rejected" }
        }
    }
    
    var pendingCount: Int {
        appointments.filter { $0.status == "Pending" }.count
    }
    var approvedCount: Int {
        appointments.filter { $0.status == "Approved" }.count
    }
    var rejectedCount: Int {
        appointments.filter { $0.status == "Rejected" }.count
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // ── Hero Header ──
                    VStack(spacing: 6) {
                        HStack(spacing: 6) {
                            Text("CONSULTATION DESK")
                                .font(.system(size: 11, weight: .heavy))
                                .tracking(1.2)
                                .foregroundColor(AppTheme.emeraldMint)
                            Image(systemName: "person.2.badge.gearshape.fill")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.emeraldMint)
                        }
                        
                        Text("Appointment Requests")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.titleText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                        
                        Text("Review member consultation bookings & confirm 1-on-1 sessions")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.bodyText(0.75))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 12)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animate)
                    
                    // ── Interactive Metric Filter Pills Bar ──
                    HStack(spacing: 8) {
                        filterMetricPill(
                            title: "All",
                            count: appointments.count,
                            filter: .all,
                            color: AppTheme.primaryBrand
                        )
                        filterMetricPill(
                            title: "Pending",
                            count: pendingCount,
                            filter: .pending,
                            color: AppTheme.amberWarm
                        )
                        filterMetricPill(
                            title: "Approved",
                            count: approvedCount,
                            filter: .approved,
                            color: AppTheme.emeraldMint
                        )
                        filterMetricPill(
                            title: "Declined",
                            count: rejectedCount,
                            filter: .rejected,
                            color: AppTheme.coralRose
                        )
                    }
                    .opacity(animate ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.1), value: animate)
                    
                    // ── Requests List ──
                    if isLoading && appointments.isEmpty {
                        // Smooth Shimmering Skeleton Loader
                        VStack(spacing: 14) {
                            ForEach(0..<3, id: \.self) { _ in
                                GlassCard(cornerRadius: 22, paddingAmount: 18) {
                                    VStack(alignment: .leading, spacing: 14) {
                                        HStack(spacing: 12) {
                                            Circle()
                                                .fill(Color.black.opacity(0.06))
                                                .frame(width: 48, height: 48)
                                            
                                            VStack(alignment: .leading, spacing: 6) {
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color.black.opacity(0.08))
                                                    .frame(width: 130, height: 16)
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color.black.opacity(0.05))
                                                    .frame(width: 90, height: 12)
                                            }
                                            Spacer()
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color.black.opacity(0.06))
                                                .frame(width: 80, height: 24)
                                        }
                                        
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.black.opacity(0.04))
                                            .frame(height: 54)
                                    }
                                }
                                .shimmering(duration: 1.8)
                            }
                        }
                        .padding(.top, 6)
                    } else if appointments.isEmpty {
                        // Full Empty State
                        GlassCard(cornerRadius: 22, paddingAmount: 26) {
                            VStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.primaryBrand.opacity(0.12))
                                        .frame(width: 68, height: 68)
                                    Image(systemName: "calendar.badge.clock")
                                        .font(.system(size: 32))
                                        .foregroundColor(AppTheme.primaryBrand)
                                }
                                
                                Text("No Consultation Requests")
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(AppTheme.titleText)
                                
                                Text("When members book an appointment from your open slots, their requests will appear here for your review and confirmation.")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.bodyText(0.75))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                        }
                        .padding(.top, 16)
                    } else if filteredAppointments.isEmpty {
                        // Filter Empty State
                        GlassCard(cornerRadius: 20, paddingAmount: 22) {
                            VStack(spacing: 10) {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .font(.system(size: 36))
                                    .foregroundColor(AppTheme.bodyText(0.4))
                                
                                Text("No \(selectedFilter.rawValue) Requests")
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(AppTheme.titleText)
                                
                                Text("There are currently no consultation requests under the \"\(selectedFilter.rawValue)\" filter.")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.bodyText(0.75))
                                
                                Button("Show All Requests") {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        selectedFilter = .all
                                    }
                                }
                                .font(.caption.bold())
                                .foregroundColor(AppTheme.primaryBrand)
                                .padding(.top, 4)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                        .padding(.top, 10)
                    } else {
                        // ── Rendered Appointment Cards ──
                        VStack(spacing: 14) {
                            ForEach(Array(filteredAppointments.enumerated()), id: \.element.id) { index, appointment in
                                let dateInfo = parseAppointmentDate(appointment.slot_time)
                                let isThisUpdating = updatingId == appointment.id
                                
                                GlassCard(cornerRadius: 22, paddingAmount: 18) {
                                    VStack(alignment: .leading, spacing: 14) {
                                        
                                        // Top Row: Member Avatar, Name & Status Badge
                                        HStack(spacing: 12) {
                                            ZStack {
                                                Circle()
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [AppTheme.emeraldMint, AppTheme.primaryBrand],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                                    .frame(width: 48, height: 48)
                                                    .shadow(color: AppTheme.emeraldMint.opacity(0.3), radius: 6, y: 3)
                                                
                                                Text(String(appointment.user_name.prefix(1)).uppercased())
                                                    .font(.system(size: 19, weight: .bold, design: .rounded))
                                                    .foregroundColor(.white)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(appointment.user_name)
                                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                                    .foregroundColor(AppTheme.titleText)
                                                    .lineLimit(1)
                                                
                                                HStack(spacing: 6) {
                                                    HStack(spacing: 3) {
                                                        Image(systemName: "person.crop.circle.badge.checkmark")
                                                            .font(.system(size: 9))
                                                        Text("Verified Member")
                                                            .font(.system(size: 10, weight: .semibold))
                                                    }
                                                    .foregroundColor(AppTheme.emeraldMint)
                                                    
                                                    Text("•")
                                                        .font(.system(size: 10))
                                                        .foregroundColor(AppTheme.bodyText(0.4))
                                                    
                                                    Text("Req #\(appointment.id)")
                                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                                        .foregroundColor(AppTheme.bodyText(0.55))
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            statusBadge(for: appointment.status)
                                        }
                                        
                                        // Scheduled Time & Consultation Details Box
                                        HStack(spacing: 14) {
                                            
                                            // Calendar Date Tile (Left)
                                            VStack(spacing: 2) {
                                                Text(dateInfo.month)
                                                    .font(.system(size: 10, weight: .heavy))
                                                    .tracking(0.5)
                                                    .foregroundColor(statusAccentColor(for: appointment.status))
                                                    .padding(.horizontal, 7)
                                                    .padding(.vertical, 2)
                                                    .background(statusAccentColor(for: appointment.status).opacity(0.12))
                                                    .clipShape(Capsule())
                                                
                                                Text(dateInfo.day)
                                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                                    .foregroundColor(AppTheme.titleText)
                                                
                                                Text(dateInfo.weekday)
                                                    .font(.system(size: 9, weight: .semibold))
                                                    .foregroundColor(AppTheme.bodyText(0.6))
                                            }
                                            .frame(width: 52)
                                            .padding(.vertical, 6)
                                            .background(Color.white.opacity(0.55))
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                            
                                            // Consultation Details (Right)
                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack(spacing: 6) {
                                                    Image(systemName: "clock.fill")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(AppTheme.primaryBrand)
                                                    
                                                    Text(dateInfo.time)
                                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                                        .foregroundColor(AppTheme.titleText)
                                                }
                                                
                                                HStack(spacing: 4) {
                                                    Image(systemName: "video.fill")
                                                        .font(.system(size: 10))
                                                        .foregroundColor(AppTheme.primaryBrand)
                                                    Text("1-on-1 Scalp & Care Consultation")
                                                        .font(.caption2.weight(.medium))
                                                        .foregroundColor(AppTheme.bodyText(0.8))
                                                }
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding(10)
                                        .background(Color.white.opacity(0.45))
                                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                                .stroke(Color.white, lineWidth: 1)
                                        )
                                        
                                        // ── Action Buttons for Pending Requests ──
                                        if appointment.status == "Pending" {
                                            Divider()
                                                .opacity(0.4)
                                                .padding(.vertical, 2)
                                            
                                            if isThisUpdating {
                                                HStack {
                                                    Spacer()
                                                    ProgressView()
                                                        .tint(AppTheme.primaryBrand)
                                                    Text("Updating request...")
                                                        .font(.caption.bold())
                                                        .foregroundColor(AppTheme.bodyText(0.7))
                                                    Spacer()
                                                }
                                                .padding(.vertical, 6)
                                            } else {
                                                HStack(spacing: 12) {
                                                    // Approve Button
                                                    Button(action: {
                                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                                        updateStatus(id: appointment.id, newStatus: "Approved")
                                                    }) {
                                                        HStack(spacing: 6) {
                                                            Image(systemName: "checkmark.circle.fill")
                                                                .font(.system(size: 14, weight: .bold))
                                                            Text("Approve Request")
                                                                .font(.subheadline.weight(.bold))
                                                        }
                                                        .frame(maxWidth: .infinity)
                                                        .padding(.vertical, 12)
                                                        .background(
                                                            LinearGradient(
                                                                colors: [AppTheme.emeraldMint, Color.teal],
                                                                startPoint: .leading,
                                                                endPoint: .trailing
                                                            )
                                                        )
                                                        .foregroundColor(.white)
                                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                                        .shadow(color: AppTheme.emeraldMint.opacity(0.35), radius: 6, y: 3)
                                                    }
                                                    .buttonStyle(InteractiveCardButtonStyle())
                                                    
                                                    // Decline Button
                                                    Button(action: {
                                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                                        updateStatus(id: appointment.id, newStatus: "Rejected")
                                                    }) {
                                                        HStack(spacing: 6) {
                                                            Image(systemName: "xmark.circle.fill")
                                                                .font(.system(size: 13, weight: .bold))
                                                            Text("Decline")
                                                                .font(.subheadline.weight(.semibold))
                                                        }
                                                        .frame(maxWidth: .infinity)
                                                        .padding(.vertical, 12)
                                                        .background(AppTheme.coralRose.opacity(0.12))
                                                        .foregroundColor(AppTheme.coralRose)
                                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                                .stroke(AppTheme.coralRose.opacity(0.3), lineWidth: 1)
                                                        )
                                                    }
                                                    .buttonStyle(InteractiveCardButtonStyle())
                                                }
                                            }
                                        } else if appointment.status == "Approved" {
                                            // Confirmed Consultation Info Pill
                                            HStack(spacing: 6) {
                                                Image(systemName: "checkmark.shield.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(AppTheme.emeraldMint)
                                                Text("Session confirmed. Video consultation will be active for this member.")
                                                    .font(.caption2.weight(.medium))
                                                    .foregroundColor(AppTheme.bodyText(0.8))
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 7)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(AppTheme.emeraldMint.opacity(0.08))
                                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                        }
                                    }
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
                fetchAppointments(showLoadingIndicator: false)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Appointment Requests")
                    .font(.headline.weight(.bold))
                    .foregroundColor(AppTheme.titleText)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    fetchAppointments()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.primaryBrand)
                }
            }
        }
        .onAppear {
            animate = true
            fetchAppointments()
        }
    }
    
    // MARK: - Metric Filter Pill Component
    @ViewBuilder
    private func filterMetricPill(
        title: String,
        count: Int,
        filter: AppointmentFilter,
        color: Color
    ) -> some View {
        let isSelected = selectedFilter == filter
        
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selectedFilter = filter
            }
        }) {
            VStack(spacing: 3) {
                Text("\(count)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? .white : AppTheme.titleText)
                
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .bold : .semibold))
                    .foregroundColor(isSelected ? .white.opacity(0.9) : AppTheme.bodyText(0.75))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                isSelected
                    ? AnyView(
                        LinearGradient(
                            colors: [color, color.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    : AnyView(Color.white.opacity(0.65))
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Color.clear : Color.white, lineWidth: 1)
            )
            .shadow(
                color: isSelected ? color.opacity(0.3) : Color.black.opacity(0.03),
                radius: isSelected ? 8 : 4,
                y: isSelected ? 3 : 1
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Status Helpers
    private func statusAccentColor(for status: String) -> Color {
        switch status {
        case "Approved":
            return AppTheme.emeraldMint
        case "Rejected":
            return AppTheme.coralRose
        default:
            return AppTheme.amberWarm
        }
    }
    
    @ViewBuilder
    private func statusBadge(for status: String) -> some View {
        switch status {
        case "Approved":
            HStack(spacing: 4) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 10))
                Text("Approved")
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundColor(AppTheme.emeraldMint)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(AppTheme.emeraldMint.opacity(0.12))
            .clipShape(Capsule())
            
        case "Rejected":
            HStack(spacing: 4) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 10))
                Text("Declined")
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundColor(AppTheme.coralRose)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(AppTheme.coralRose.opacity(0.12))
            .clipShape(Capsule())
            
        default:
            HStack(spacing: 4) {
                Image(systemName: "hourglass")
                    .font(.system(size: 10))
                Text("Pending Review")
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundColor(AppTheme.amberWarm)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(AppTheme.amberWarm.opacity(0.14))
            .clipShape(Capsule())
        }
    }
}
