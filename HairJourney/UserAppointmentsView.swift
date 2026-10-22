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
                    scheduleNotification(id: "appt_48h_\(appt.id)", title: "Upcoming Consultation", body: "Your consultation with Expert \(appt.doctor_name.replacingOccurrences(of: "Dr. ", with: "").replacingOccurrences(of: "Dr.", with: "")) is in 48 hours.", date: date48h)
                }
                
                let date2h = slotDate.addingTimeInterval(-2 * 3600)
                if date2h > now {
                    scheduleNotification(id: "appt_2h_\(appt.id)", title: "Consultation Soon", body: "Your consultation with Expert \(appt.doctor_name.replacingOccurrences(of: "Dr. ", with: "").replacingOccurrences(of: "Dr.", with: "")) is in 2 hours.", date: date2h)
                }
                
                let dateDayOf = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: slotDate) ?? slotDate.addingTimeInterval(-8 * 3600)
                if dateDayOf > now && dateDayOf < slotDate {
                    scheduleNotification(id: "appt_dayof_\(appt.id)", title: "Consultation Today", body: "You have a consultation with Expert \(appt.doctor_name.replacingOccurrences(of: "Dr. ", with: "").replacingOccurrences(of: "Dr.", with: "")) today.", date: dateDayOf)
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
            AppBackgroundView()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    VStack(spacing: 6) {
                        Text("My Consultations")
                            .font(.title2.bold())
                            .foregroundColor(AppTheme.titleText)
                        
                        Text("Track booking status and upcoming expert appointments")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.bodyText(0.75))
                    }
                    .padding(.top, 16)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -15)
                    .animation(.easeOut(duration: 0.6), value: animate)
                    
                    ForEach(appointments) { appt in
                        GlassCard(cornerRadius: 20, paddingAmount: 16) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(AppTheme.brandGradient)
                                            .frame(width: 48, height: 48)
                                            .shadow(color: AppTheme.primaryBrand.opacity(0.25), radius: 6, y: 3)
                                        
                                        Image(systemName: "person.badge.shield.checkmark.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 20, weight: .semibold))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Expert \(appt.doctor_name.replacingOccurrences(of: "Dr. ", with: "").replacingOccurrences(of: "Dr.", with: ""))")
                                            .font(.headline.weight(.bold))
                                            .foregroundColor(AppTheme.titleText)
                                        
                                        HStack(spacing: 4) {
                                            Image(systemName: "calendar.badge.clock")
                                                .font(.system(size: 11))
                                                .foregroundColor(AppTheme.primaryBrand)
                                            Text(formatDate(appt.slot_time))
                                                .font(.caption.weight(.medium))
                                                .foregroundColor(AppTheme.bodyText)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    AppStatusBadge(status: appt.status)
                                }
                                
                                if appt.status == "Approved" {
                                    HStack(spacing: 6) {
                                        Image(systemName: "bell.badge.fill")
                                            .font(.system(size: 11))
                                            .foregroundColor(AppTheme.emeraldMint)
                                        Text("Reminders active (48h, 2h & morning of visit)")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(AppTheme.emeraldMint)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(AppTheme.emeraldMint.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                }
                            }
                        }
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : 20)
                        .animation(.easeOut(duration: 0.7), value: animate)
                    }
                    
                    if appointments.isEmpty {
                        GlassCard(cornerRadius: 22, paddingAmount: 24) {
                            VStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.primaryBrand.opacity(0.1))
                                        .frame(width: 64, height: 64)
                                    Image(systemName: "calendar.badge.plus")
                                        .font(.system(size: 28))
                                        .foregroundColor(AppTheme.primaryBrand)
                                }
                                
                                Text("No Consultations Yet")
                                    .font(.headline.bold())
                                    .foregroundColor(AppTheme.titleText)
                                
                                Text("You haven't scheduled any consultations yet. Consult with hair experts to receive tailored hair care recommendations.")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.bodyText(0.8))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 10)
                                
                                NavigationLink(destination: BookAppointmentView(user: user)) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "calendar.badge.plus")
                                        Text("Book First Consultation")
                                    }
                                }
                                .buttonStyle(PrimaryButtonStyle(height: 46))
                                .padding(.top, 6)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 20)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
            }
            .refreshable {
                fetchAppointments()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("My Consultations")
                    .font(.headline.bold())
                    .foregroundColor(AppTheme.titleText)
            }
        }
        .onAppear {
            animate = true
            fetchAppointments()
        }
    }
}

