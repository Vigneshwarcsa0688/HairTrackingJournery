import SwiftUI
import UserNotifications

struct Appointment: Codable, Identifiable {
    var id: String
    var doctor_name: String
    var slot_time: String
    var status: String
}

struct UserAppointmentsView: View {
    var user: User
    @State private var appointments: [Appointment] = []
    @State private var animate = false
    
    func fetchAppointments() {
        guard let url = URL(string: APIService.baseURL + "get_user_appointments.php?user_id=\(user.id)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                if let data = data {
                    appointments = (try? JSONDecoder().decode([Appointment].self, from: data)) ?? []
                    scheduleReminders(for: appointments)
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
    
    func scheduleReminders(for appointments: [Appointment]) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            for appt in appointments where appt.status == "Approved" {
                guard let slotDate = formatter.date(from: appt.slot_time) else { continue }
                let now = Date()
                
                let date48h = slotDate.addingTimeInterval(-48 * 3600)
                if date48h > now {
                    scheduleNotification(id: "appt_48h_\(appt.id)", title: "Upcoming Appointment", body: "Your consultation with \n Dr. \(appt.doctor_name) is in 48 hours.", date: date48h)
                }
                
                let date2h = slotDate.addingTimeInterval(-2 * 3600)
                if date2h > now {
                    scheduleNotification(id: "appt_2h_\(appt.id)", title: "Appointment Soon", body: "Your consultation with \n Dr. \(appt.doctor_name) is in 2 hours.", date: date2h)
                }
                
                let dateDayOf = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: slotDate) ?? slotDate.addingTimeInterval(-8 * 3600)
                if dateDayOf > now && dateDayOf < slotDate {
                    scheduleNotification(id: "appt_dayof_\(appt.id)", title: "Appointment Today", body: "You have a consultation with \n Dr. \(appt.doctor_name) today.", date: dateDayOf)
                }
            }
        }
    }
    
    func scheduleNotification(id: String, title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        var comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        comps.second = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    var body: some View {
        ZStack {
            AppTheme.gradient.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    
                    VStack(spacing: 6) {
                        Text("My Consultations")
                            .font(.title.bold())
                            .foregroundColor(AppTheme.titleText)
                        
                        Text("Track your consultation requests")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.bodyText)
                    }
                    .padding(.top)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animate)
                    
                    ForEach(appointments) { appt in
                        GlassCard {
                            HStack(spacing: 16) {
                                
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 46, height: 46)
                                    
                                    Image(systemName: "stethoscope")
                                        .foregroundColor(AppTheme.titleText)
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(appt.doctor_name)
                                        .font(.headline)
                                        .foregroundColor(AppTheme.titleText)
                                    
                                    Text(formatDate(appt.slot_time))
                                        .font(.caption)
                                        .foregroundColor(AppTheme.bodyText)
                                }
                                
                                Spacer()
                                
                                statusBadge(appt.status)
                            }
                        }
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : 25)
                        .animation(.easeOut(duration: 0.7), value: animate)
                    }
                    
                    if appointments.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .font(.largeTitle)
                                .foregroundColor(AppTheme.secondaryText)
                            
                            Text("No consultations yet")
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

