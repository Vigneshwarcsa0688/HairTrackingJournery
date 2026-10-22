import SwiftUI

struct CreateSlotView: View {
    var doctor: User
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDate = Date()
    @State private var message = ""
    @State private var animate = false
    @State private var isSubmitting = false
    @State private var showSuccessDialog = false
    
    struct CreateSlotRequest: Codable {
        let doctor_id: Int
        let slot_time: String
    }
    
    func createSlot() {
        guard !isSubmitting else { return }
        guard let url = URL(string: APIService.baseURL + "create_slot.php") else { return }
        
        isSubmitting = true
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
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
                self.isSubmitting = false
                self.showSuccessDialog = true
            }
        }.resume()
    }
    
    var formattedPreviewDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: selectedDate)
    }
    
    var formattedPreviewTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    
                    // ── Header ──
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [AppTheme.emeraldMint, AppTheme.primaryBrand], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 76, height: 76)
                                .shadow(color: AppTheme.emeraldMint.opacity(0.35), radius: 10, y: 5)
                            
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 34, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(animate ? 1 : 0.7)
                        .animation(.easeOut(duration: 0.6), value: animate)
                        
                        Text("Create Appointment Slot")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.titleText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)

                        Text("Choose an available date and time for member consultations")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.bodyText(0.75))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 10)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animate)
                    
                    // ── Date & Time Selection Card ──
                    GlassCard(cornerRadius: 24, paddingAmount: 20) {
                        VStack(spacing: 18) {
                            
                            // Selected Slot Time Summary Box
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(AppTheme.primaryBrand.opacity(0.12))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "clock.badge.checkmark.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(AppTheme.primaryBrand)
                                }
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Selected Schedule")
                                        .font(.caption.bold())
                                        .foregroundColor(AppTheme.primaryBrand)
                                    
                                    Text("\(formattedPreviewDate) • \(formattedPreviewTime)")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(AppTheme.titleText)
                                }
                                
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.white.opacity(0.6))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                            
                            Divider()
                                .opacity(0.4)
                            
                            // Graphical Date Picker
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Choose Date & Hour")
                                    .font(.caption.bold())
                                    .foregroundColor(AppTheme.bodyText(0.8))
                                
                                DatePicker(
                                    "",
                                    selection: $selectedDate,
                                    displayedComponents: [.date, .hourAndMinute]
                                )
                                .datePickerStyle(.graphical)
                                .tint(AppTheme.primaryBrand)
                            }
                            
                            // Publish Button
                            Button {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                createSlot()
                            } label: {
                                HStack(spacing: 8) {
                                    if isSubmitting {
                                        ProgressView().tint(.white)
                                    } else {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.headline)
                                        Text("Publish Consultation Slot")
                                            .font(.headline.weight(.bold))
                                    }
                                }
                            }
                            .buttonStyle(PrimaryButtonStyle(height: 52))
                            .disabled(isSubmitting)
                        }
                    }
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 25)
                    .animation(.easeOut(duration: 0.7), value: animate)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationTitle("New Slot")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { animate = true }
        .alert("Slot Published", isPresented: $showSuccessDialog) {
            Button("Done") {
                dismiss()
            }
        } message: {
            Text("✅ Your consultation slot for \(formattedPreviewDate) at \(formattedPreviewTime) is now available for member booking.")
        }
    }
}
