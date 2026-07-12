import SwiftUI

// ✅ MODEL NOW MATCHES BACKEND
struct DoctorAppointment: Codable, Identifiable {
    var id: String
    var user_name: String   // backend field
    var slot_time: String
    var status: String
}

struct DoctorAppointmentsView: View {
    var doctor: User
    @State private var appointments: [DoctorAppointment] = []
    @State private var animate = false
    
    struct StatusUpdateRequest: Codable {
        let appointment_id: Int
        let status: String
    }
    
    // MARK: FETCH APPOINTMENTS
    func fetchAppointments() {
        guard let url = URL(string: APIService.baseURL + "get_doctor_appointments.php?doctor_id=\(doctor.id)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Fetch error:", error.localizedDescription)
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    appointments = try JSONDecoder().decode([DoctorAppointment].self, from: data)
                } catch {
                    print("Decode error:", error)
                }
            }
        }.resume()
    }
    
    // MARK: UPDATE STATUS
    func updateStatus(id: String, newStatus: String) {
        guard let url = URL(string: APIService.baseURL + "update_appointment_status.php"),
              let appointmentId = Int(id) else { return }
        
        let body = StatusUpdateRequest(appointment_id: appointmentId, status: newStatus)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                fetchAppointments() // refresh after approve/reject
            }
        }.resume()
    }
    
    // MARK: DATE FORMATTER
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
                VStack(spacing: 22) {
                    
                    VStack(spacing: 6) {
                        Text("Consultation Requests")
                            .font(.title.bold())
                            .foregroundColor(AppTheme.titleText)
                        
                        Text("Review and manage member bookings")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.bodyText)
                    }
                    .padding(.top)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animate)
                    
                    // MARK: APPOINTMENT CARDS
                    ForEach(appointments) { appointment in
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        
                                        // ✅ FIXED — use user_name
                                        Text(appointment.user_name)
                                            .font(.headline)
                                            .foregroundColor(.black)
                                        
                                        Text(formatDate(appointment.slot_time))
                                            .font(.caption)
                                            .foregroundColor(.black.opacity(0.85))
                                    }
                                    
                                    Spacer()
                                    statusBadge(appointment.status)
                                }
                                
                                if appointment.status == "Pending" {
                                    HStack(spacing: 14) {
                                        Button {
                                            updateStatus(id: appointment.id, newStatus: "Approved")
                                        } label: {
                                            Label("Approve", systemImage: "checkmark.circle.fill")
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(ApproveButtonStyle())
                                        
                                        Button {
                                            updateStatus(id: appointment.id, newStatus: "Rejected")
                                        } label: {
                                            Label("Reject", systemImage: "xmark.circle.fill")
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(RejectButtonStyle())
                                    }
                                }
                            }
                        }
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : 25)
                        .animation(.easeOut(duration: 0.7), value: animate)
                    }
                    
                    if appointments.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.largeTitle)
                                .foregroundColor(AppTheme.secondaryText)
                            
                            Text("No consultation requests yet")
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Consultations")
                    .font(.headline.bold())
                    .foregroundColor(AppTheme.titleText)
            }
        }
        .onAppear {
            animate = true
            fetchAppointments()
        }
    }
    
    // MARK: STATUS BADGE
    func statusBadge(_ status: String) -> some View {
        Text(status)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                status == "Approved" ? Color.green.opacity(0.25) :
                status == "Rejected" ? Color.red.opacity(0.25) :
                Color.orange.opacity(0.25)
            )
            .foregroundColor(
                status == "Approved" ? .green :
                status == "Rejected" ? .red : .orange
            )
            .cornerRadius(10)
    }
}

// MARK: BUTTON STYLES (UNCHANGED UI)

struct ApproveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(LinearGradient(colors: [.green, .mint],
                                       startPoint: .leading,
                                       endPoint: .trailing))
            .foregroundColor(.white)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct RejectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(LinearGradient(colors: [.red, .pink],
                                       startPoint: .leading,
                                       endPoint: .trailing))
            .foregroundColor(.white)
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

