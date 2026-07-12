import SwiftUI

struct CreateSlotView: View {
    var doctor: User
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDate = Date()
    @State private var message = ""
    @State private var animate = false
    
    @State private var showSuccessDialog = false
    
    struct CreateSlotRequest: Codable {
        let doctor_id: Int
        let slot_time: String
    }
    
    func createSlot() {
        guard let url = URL(string: APIService.baseURL + "create_slot.php") else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let body = CreateSlotRequest(
            doctor_id: Int(doctor.id) ?? 0,
            slot_time: formatter.string(from: selectedDate)
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                showSuccessDialog = true
            }
        }.resume()
    }
    
    var body: some View {
        ZStack {
            AppTheme.gradient.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    
                    VStack(spacing: 8) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 65))
                            .foregroundColor(AppTheme.bodyText)
                            .scaleEffect(animate ? 1 : 0.7)
                            .animation(.easeOut(duration: 0.6), value: animate)
                        
                        Text("Create Appointment Slot")
                            .font(.title.bold())
                            .foregroundColor(AppTheme.titleText)

                        Text("Choose an available time for members")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.bodyText)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.top)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animate)
                    
                    GlassCard {
                        VStack(spacing: 20) {
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Select Date & Time")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.bodyText)
                                
                                DatePicker(
                                    "",
                                    selection: $selectedDate,
                                    displayedComponents: [.date, .hourAndMinute]
                                )
                                .datePickerStyle(.graphical)
                                .tint(.white)
                            }
                            
                            Button {
                                createSlot()
                            } label: {
                                Text("Create Slot")
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                    }
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 30)
                    .animation(.easeOut(duration: 0.7), value: animate)
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
        }
        .navigationTitle("Create Slot")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { animate = true }
        
        .alert("Success", isPresented: $showSuccessDialog) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("✅ Slot Created Successfully")
        }
    }
}

