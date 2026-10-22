import SwiftUI

struct DoctorSlot: Codable, Identifiable {
    var id: String
    var slot_time: String
    var is_booked: String
}

struct DoctorAppointmentStatus: Codable {
    var id: String
    var slot_id: String
    var status: String
}

enum SlotFilter: String, CaseIterable {
    case all = "All"
    case available = "Available"
    case pending = "Pending"
    case booked = "Booked"
}

struct SlotDateInfo {
    let month: String
    let day: String
    let weekday: String
    let time: String
    let fullDate: String
    let rawDate: Date?
}

struct DoctorSlotsView: View {
    var doctor: User
    @State private var slots: [DoctorSlot] = []
    @State private var pendingSlotIDs: Set<String> = []
    @State private var selectedFilter: SlotFilter = .all
    @State private var isLoading = true
    @State private var animate = false
    
    @Environment(\.horizontalSizeClass) var sizeClass
    
    // MARK: - Data Fetching
    func loadData() {
        isLoading = true
        let group = DispatchGroup()
        
        group.enter()
        fetchSlots { group.leave() }
        
        group.enter()
        fetchPendingAppointments { group.leave() }
        
        group.notify(queue: .main) {
            withAnimation(.easeInOut(duration: 0.35)) {
                self.isLoading = false
            }
        }
    }
    
    func fetchSlots(completion: (() -> Void)? = nil) {
        guard let url = URL(string: APIService.baseURL + "get_doctor_slots.php?doctor_id=\(doctor.id)") else {
            completion?()
            return
        }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                defer { completion?() }
                if let error = error {
                    print("Slot fetch error:", error.localizedDescription)
                    return
                }
                guard let data = data else { return }
                do {
                    self.slots = try JSONDecoder().decode([DoctorSlot].self, from: data)
                } catch {
                    print("Slot decode error:", error)
                }
            }
        }.resume()
    }
    
    func fetchPendingAppointments(completion: (() -> Void)? = nil) {
        guard let url = URL(string: APIService.baseURL + "get_doctor_appointments.php?doctor_id=\(doctor.id)") else {
            completion?()
            return
        }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                defer { completion?() }
                if let data = data,
                   let appointments = try? JSONDecoder().decode([DoctorAppointmentStatus].self, from: data) {
                    self.pendingSlotIDs = Set(
                        appointments
                            .filter { $0.status == "Pending" }
                            .map { $0.slot_id }
                    )
                }
            }
        }.resume()
    }
    
    // MARK: - Date Formatting Helpers
    func parseSlotDate(_ dateString: String) -> SlotDateInfo {
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
            
            return SlotDateInfo(month: month, day: day, weekday: weekday, time: time, fullDate: fullDate, rawDate: date)
        }
        return SlotDateInfo(month: "SLOT", day: "--", weekday: "", time: dateString, fullDate: dateString, rawDate: nil)
    }
    
    // MARK: - Filtered & Sorted Slots
    var sortedSlots: [DoctorSlot] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        return slots.sorted {
            guard let d1 = formatter.date(from: $0.slot_time),
                  let d2 = formatter.date(from: $1.slot_time) else { return false }
            return d1 < d2
        }
    }
    
    var filteredSlots: [DoctorSlot] {
        switch selectedFilter {
        case .all:
            return sortedSlots
        case .available:
            return sortedSlots.filter { $0.is_booked != "1" && !pendingSlotIDs.contains($0.id) }
        case .pending:
            return sortedSlots.filter { $0.is_booked != "1" && pendingSlotIDs.contains($0.id) }
        case .booked:
            return sortedSlots.filter { $0.is_booked == "1" }
        }
    }
    
    // Counts
    var availableCount: Int {
        slots.filter { $0.is_booked != "1" && !pendingSlotIDs.contains($0.id) }.count
    }
    var pendingCount: Int {
        slots.filter { $0.is_booked != "1" && pendingSlotIDs.contains($0.id) }.count
    }
    var bookedCount: Int {
        slots.filter { $0.is_booked == "1" }.count
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // ── Hero Header ──
                    VStack(spacing: 6) {
                        HStack(spacing: 6) {
                            Text("SCHEDULE & AVAILABILITY")
                                .font(.system(size: 11, weight: .heavy))
                                .tracking(1.2)
                                .foregroundColor(AppTheme.emeraldMint)
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.emeraldMint)
                        }
                        
                        Text("My Consultation Slots")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.titleText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                        
                        Text("Manage open times and live consultation bookings")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.bodyText(0.75))
                    }
                    .padding(.top, 12)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animate)
                    

                    // ── Metrics & Filter Pills Bar ──
                    HStack(spacing: 8) {
                        filterMetricPill(
                            title: "All",
                            count: slots.count,
                            filter: .all,
                            color: AppTheme.primaryBrand
                        )
                        filterMetricPill(
                            title: "Available",
                            count: availableCount,
                            filter: .available,
                            color: AppTheme.emeraldMint
                        )
                        filterMetricPill(
                            title: "Pending",
                            count: pendingCount,
                            filter: .pending,
                            color: AppTheme.amberWarm
                        )
                        filterMetricPill(
                            title: "Booked",
                            count: bookedCount,
                            filter: .booked,
                            color: AppTheme.irisPurple
                        )
                    }
                    .opacity(animate ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.15), value: animate)
                    
                    // ── Slots List Content ──
                    if isLoading {
                        // Skeleton loading states
                        VStack(spacing: 12) {
                            ForEach(0..<4, id: \.self) { _ in
                                GlassCard(cornerRadius: 20, paddingAmount: 16) {
                                    HStack(spacing: 16) {
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.black.opacity(0.06))
                                            .frame(width: 58, height: 64)
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.black.opacity(0.08))
                                                .frame(width: 120, height: 18)
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.black.opacity(0.05))
                                                .frame(width: 80, height: 14)
                                        }
                                        Spacer()
                                    }
                                }
                                .shimmering(duration: 1.8)
                            }
                        }
                        .padding(.top, 4)
                    } else if slots.isEmpty {
                        // Complete Empty State
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
                                
                                Text("No Consultation Slots Scheduled")
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(AppTheme.titleText)
                                
                                Text("Publish your open consultation hours so members can schedule live 1-on-1 hair evaluations.")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.bodyText(0.75))
                                    .multilineTextAlignment(.center)
                                
                                NavigationLink(destination: CreateSlotView(doctor: doctor)) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Create First Slot")
                                    }
                                }
                                .buttonStyle(PrimaryButtonStyle(height: 46))
                                .padding(.top, 6)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                        .padding(.top, 10)
                    } else if filteredSlots.isEmpty {
                        // Filter Empty State
                        GlassCard(cornerRadius: 20, paddingAmount: 22) {
                            VStack(spacing: 10) {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .font(.system(size: 36))
                                    .foregroundColor(AppTheme.bodyText(0.4))
                                
                                Text("No \(selectedFilter.rawValue) Slots Found")
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(AppTheme.titleText)
                                
                                Text("There are currently no slots matching the \"\(selectedFilter.rawValue)\" filter.")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.bodyText(0.75))
                                
                                Button("Show All Slots") {
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
                        // ── Rendered Slots ──
                        VStack(spacing: 12) {
                            ForEach(Array(filteredSlots.enumerated()), id: \.element.id) { index, slot in
                                let dateInfo = parseSlotDate(slot.slot_time)
                                
                                GlassCard(cornerRadius: 20, paddingAmount: 16) {
                                    HStack(spacing: 16) {
                                        
                                        // Calendar Date Tile (Left)
                                        VStack(spacing: 2) {
                                            Text(dateInfo.month)
                                                .font(.system(size: 11, weight: .heavy))
                                                .tracking(0.5)
                                                .foregroundColor(statusAccentColor(for: slot))
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 2)
                                                .background(statusAccentColor(for: slot).opacity(0.12))
                                                .clipShape(Capsule())
                                            
                                            Text(dateInfo.day)
                                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                                .foregroundColor(AppTheme.titleText)
                                            
                                            Text(dateInfo.weekday)
                                                .font(.system(size: 10, weight: .semibold))
                                                .foregroundColor(AppTheme.bodyText(0.6))
                                        }
                                        .frame(width: 58)
                                        .padding(.vertical, 6)
                                        .background(Color.white.opacity(0.5))
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .stroke(Color.white, lineWidth: 1)
                                        )
                                        
                                        // Time & Consultation Details (Middle)
                                        VStack(alignment: .leading, spacing: 6) {
                                            HStack(alignment: .center, spacing: 6) {
                                                Image(systemName: "clock.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(AppTheme.primaryBrand)
                                                
                                                Text(dateInfo.time)
                                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                                    .foregroundColor(AppTheme.titleText)
                                                
                                                Spacer()
                                                
                                                // Status Pill
                                                statusBadge(for: slot)
                                            }
                                            
                                            HStack(spacing: 8) {
                                                HStack(spacing: 4) {
                                                    Image(systemName: "video.fill")
                                                        .font(.system(size: 10))
                                                    Text("1-on-1 Consultation")
                                                        .font(.caption2.weight(.medium))
                                                }
                                                .foregroundColor(AppTheme.bodyText(0.75))
                                                
                                                Text("•")
                                                    .font(.caption2)
                                                    .foregroundColor(AppTheme.bodyText(0.4))
                                                
                                                Text("Slot #\(slot.id)")
                                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                                    .foregroundColor(AppTheme.bodyText(0.5))
                                            }
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
                loadData()
            }
        }
        .navigationTitle("Consultation Slots")
        .navigationBarTitleDisplayMode(.inline)

        .onAppear {
            animate = true
            loadData()
        }
    }
    
    // MARK: - Filter Metric Pill Component
    @ViewBuilder
    private func filterMetricPill(
        title: String,
        count: Int,
        filter: SlotFilter,
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
    
    // MARK: - Status Badge & Colors
    private func statusAccentColor(for slot: DoctorSlot) -> Color {
        if slot.is_booked == "1" {
            return AppTheme.irisPurple
        } else if pendingSlotIDs.contains(slot.id) {
            return AppTheme.amberWarm
        } else {
            return AppTheme.emeraldMint
        }
    }
    
    @ViewBuilder
    private func statusBadge(for slot: DoctorSlot) -> some View {
        if slot.is_booked == "1" {
            HStack(spacing: 4) {
                Image(systemName: "person.crop.circle.badge.checkmark.fill")
                    .font(.system(size: 10))
                Text("Booked")
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundColor(AppTheme.irisPurple)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(AppTheme.irisPurple.opacity(0.12))
            .clipShape(Capsule())
        } else if pendingSlotIDs.contains(slot.id) {
            HStack(spacing: 4) {
                Image(systemName: "hourglass")
                    .font(.system(size: 10))
                Text("Pending Approval")
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundColor(AppTheme.amberWarm)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(AppTheme.amberWarm.opacity(0.14))
            .clipShape(Capsule())
        } else {
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 10))
                Text("Available")
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundColor(AppTheme.emeraldMint)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(AppTheme.emeraldMint.opacity(0.12))
            .clipShape(Capsule())
        }
    }
}
