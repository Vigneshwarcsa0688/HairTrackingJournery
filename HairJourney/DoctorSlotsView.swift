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

struct DoctorSlotsView: View {
    var doctor: User
    @State private var slots: [DoctorSlot] = []
    @State private var pendingSlotIDs: Set<String> = []
    @State private var animate = false
    
    func fetchSlots() {
        guard let url = URL(string: APIService.baseURL + "get_doctor_slots.php?doctor_id=\(doctor.id)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Slot fetch error:", error.localizedDescription)
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    slots = try JSONDecoder().decode([DoctorSlot].self, from: data)
                } catch {
                    print("Slot decode error:", error)
                }
            }
        }.resume()
    }
    
    // 🔥 Fetch appointments to know which slots are pending
    func fetchPendingAppointments() {
        guard let url = URL(string: APIService.baseURL + "get_doctor_appointments.php?doctor_id=\(doctor.id)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                if let data = data,
                   let appointments = try? JSONDecoder().decode([DoctorAppointmentStatus].self, from: data) {
                    
                    pendingSlotIDs = Set(
                        appointments
                            .filter { $0.status == "Pending" }
                            .map { $0.slot_id }
                    )
                }
            }
        }.resume()
    }
    
    func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = formatter.date(from: dateString) {
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return dateString
    }
    
    var body: some View {
        ZStack {
            AppTheme.gradient.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    VStack(spacing: 6) {
                        Text("Your Appointment Slots")
                            .font(.title.bold())
                            .foregroundColor(AppTheme.titleText)
                        
                        Text("Manage your availability")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.bodyText)
                    }
                    .padding(.top)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animate)
                    
                    ForEach(slots) { slot in
                        GlassCard {
                            HStack(spacing: 16) {
                                
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.15))
                                        .frame(width: 46, height: 46)
                                    
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(AppTheme.titleText)
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(formatDate(slot.slot_time))
                                        .font(.headline)
                                        .foregroundColor(AppTheme.titleText)
                                    
                                    statusView(for: slot)
                                }
                                
                                Spacer()
                            }
                        }
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : 25)
                        .animation(.easeOut(duration: 0.7), value: animate)
                    }
                    
                    if slots.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.largeTitle)
                                .foregroundColor(AppTheme.bodyText)
                            
                            Text("No slots created yet")
                                .foregroundColor(AppTheme.bodyText)
                                .font(.subheadline)
                        }
                        .padding(.top, 40)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
        }
        .navigationTitle("My Slots")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            animate = true
            fetchSlots()
            fetchPendingAppointments()
        }
    }
    
    // MARK: Status Logic (UI SAME, only logic changed)
    @ViewBuilder
    func statusView(for slot: DoctorSlot) -> some View {
        if slot.is_booked == "1" {
            badge(text: "Booked", color: .red)
        } else if pendingSlotIDs.contains(slot.id) {
            badge(text: "Pending Approval", color: .orange)
        } else {
            badge(text: "Available", color: .green)
        }
    }
    
    func badge(text: String, color: Color) -> some View {
        Text(text)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.25))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}

