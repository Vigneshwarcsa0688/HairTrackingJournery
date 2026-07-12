import SwiftUI

struct Slot: Codable, Identifiable {
    var id: String
    var doctor_id: String
    var doctor_name: String
    var slot_time: String
}

struct BookAppointmentView: View {
    var user: User
    @State private var slots: [Slot] = []
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var animate = false
    
    struct BookRequest: Codable {
        let user_id: Int
        let doctor_id: Int
        let slot_id: Int
    }
    
    func fetchSlots() {
        guard let url = URL(string: APIService.baseURL + "get_available_slots.php") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                if let data = data {
                    slots = (try? JSONDecoder().decode([Slot].self, from: data)) ?? []
                }
            }
        }.resume()
    }
    
    func book(slot: Slot) {
        guard let url = URL(string: APIService.baseURL + "book_appointment.php"),
              let doctorId = Int(slot.doctor_id),
              let slotId = Int(slot.id) else { return }
        
        let body = BookRequest(
            user_id: Int(user.id) ?? 0,
            doctor_id: doctorId,
            slot_id: slotId
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                if let data = data,
                   let response = String(data: data, encoding: .utf8),
                   response.contains("success") {
                    alertMessage = "Appointment booked successfully! Waiting for doctor approval."
                    showSuccessAlert = true
                    fetchSlots()
                } else {
                    alertMessage = "Booking failed. Try again."
                    showErrorAlert = true
                }
            }
        }.resume()
    }
    
    var body: some View {
        ZStack {
            AppTheme.gradient.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    
                    VStack(spacing: 6) {
                        Text("Book a Consultation")
                            .font(.title.bold())
                            .foregroundColor(AppTheme.titleText)
                        
                        Text("Choose an expert and time slot")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.bodyText)
                    }
                    .padding(.top)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animate)
                    
                    ForEach(slots) { slot in
                        SlotCardView(slot: slot, animate: animate) {
                            book(slot: slot)
                        }
                    }
                    
                    if slots.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.largeTitle)
                                .foregroundColor(AppTheme.secondaryText)
                            
                            Text("No slots available right now")
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
                Text("Book Consultation")
                    .font(.headline.bold())
                    .foregroundColor(AppTheme.titleText)
            }
        }
        .onAppear {
            animate = true
            fetchSlots()
        }
        .alert("Success", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: { Text(alertMessage) }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: { Text(alertMessage) }
    }
}

struct SlotCardView: View {
    var slot: Slot
    var animate: Bool
    var bookAction: () -> Void
    
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(slot.doctor_name)
                            .font(.headline)
                            .foregroundColor(AppTheme.titleText)
                        
                        Text(slot.slot_time)
                            .font(.subheadline)
                            .foregroundColor(AppTheme.bodyText)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "stethoscope")
                        .foregroundColor(AppTheme.secondaryText)
                }
                
                Button(action: bookAction) {
                    Text("Book Appointment")
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
        .opacity(animate ? 1 : 0)
        .offset(y: animate ? 0 : 25)
        .animation(.easeOut(duration: 0.7), value: animate)
    }
}

