import SwiftUI

struct Slot: Codable, Identifiable {
    var id: String
    var doctor_id: String
    var doctor_name: String
    var slot_time: String
}

struct BookAppointmentView: View {
    var user: User
    @ObservedObject private var langManager = AppLanguageManager.shared
    @State private var slots: [Slot] = []
    @State private var isLoading = true
    @State private var searchQuery = ""
    @State private var animate = false
    
    // Booking sheet state
    @State private var selectedSlot: Slot? = nil
    @State private var consultationNote: String = ""
    @State private var isBooking = false
    
    // Success feedback state
    @State private var showSuccessDialog = false
    @State private var showErrorAlert = false
    @State private var alertMessage = ""
    @State private var navigateToMyAppointments = false
    
    struct BookRequest: Codable {
        let user_id: Int
        let doctor_id: Int
        let slot_id: Int
    }
    
    var filteredSlots: [Slot] {
        if searchQuery.trimmingCharacters(in: .whitespaces).isEmpty {
            return slots
        }
        return slots.filter {
            $0.doctor_name.localizedCaseInsensitiveContains(searchQuery) ||
            $0.slot_time.localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    func fetchSlots() {
        isLoading = true
        guard let url = URL(string: APIService.baseURL + "get_available_slots.php") else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                isLoading = false
                if let data = data {
                    slots = (try? JSONDecoder().decode([Slot].self, from: data)) ?? []
                }
            }
        }.resume()
    }
    
    func confirmBooking(slot: Slot) {
        guard let url = URL(string: APIService.baseURL + "book_appointment.php"),
              let doctorId = Int(slot.doctor_id),
              let slotId = Int(slot.id) else { return }
        
        isBooking = true
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
                isBooking = false
                if let data = data,
                   let response = String(data: data, encoding: .utf8),
                   response.contains("success") {
                    selectedSlot = nil
                    alertMessage = "Consultation requested successfully! Waiting for expert confirmation."
                    showSuccessDialog = true
                    fetchSlots()
                } else {
                    alertMessage = "Booking failed. Please try again."
                    showErrorAlert = true
                }
            }
        }.resume()
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // Header
                    VStack(spacing: 6) {
                        HStack(spacing: 6) {
                            Text("SPECIALIST CONSULTATIONS")
                                .font(.system(size: 11, weight: .heavy))
                                .tracking(1.2)
                                .foregroundColor(AppTheme.primaryBrand)
                            Image(systemName: "sparkles")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.primaryBrand)
                        }
                        
                        Text(langManager.text("book_consultation"))
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.titleText)
                        
                        Text("Connect with hair care specialists for personalized routine advice")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.bodyText(0.75))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 16)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -15)
                    .animation(.easeOut(duration: 0.6), value: animate)
                    
                    // Search & Filter Box
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppTheme.bodyText(0.5))
                        
                        TextField("Search specialist or date...", text: $searchQuery)
                            .font(.subheadline)
                            .foregroundColor(AppTheme.titleText)
                        
                        if !searchQuery.isEmpty {
                            Button { searchQuery = "" } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(AppTheme.bodyText(0.4))
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.black.opacity(0.06), lineWidth: 1))
                    
                    // Navigation link to My Consultations
                    NavigationLink(destination: UserAppointmentsView(user: user), isActive: $navigateToMyAppointments) {
                        EmptyView()
                    }
                    .hidden()
                    
                    if isLoading {
                        VStack(spacing: 12) {
                            ProgressView().tint(AppTheme.primaryBrand)
                            Text("Finding available consultation slots...")
                                .font(.caption)
                                .foregroundColor(AppTheme.bodyText(0.7))
                        }
                        .padding(.top, 30)
                    } else if filteredSlots.isEmpty {
                        GlassCard(cornerRadius: 22, paddingAmount: 24) {
                            VStack(spacing: 12) {
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppTheme.bodyText(0.4))
                                
                                Text(langManager.text("no_open_slots"))
                                    .font(.headline.bold())
                                    .foregroundColor(AppTheme.titleText)
                                
                                Text(searchQuery.isEmpty ? langManager.text("no_open_slots_desc") : "No consultation slots match your search filter.")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.bodyText(0.75))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                        }
                        .padding(.top, 20)
                    } else {
                        ForEach(filteredSlots) { slot in
                            SlotCardView(slot: slot, animate: animate) {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                selectedSlot = slot
                            }
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
            }
            .refreshable {
                fetchSlots()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(langManager.text("book_consultation"))
                    .font(.headline.bold())
                    .foregroundColor(AppTheme.titleText)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: UserAppointmentsView(user: user)) {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 14, weight: .semibold))
                        Text("My Bookings")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundColor(AppTheme.primaryBrand)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppTheme.primaryBrand.opacity(0.1))
                    .clipShape(Capsule())
                }
            }
        }
        .sheet(item: $selectedSlot) { slot in
            BookingConfirmationSheet(
                slot: slot,
                note: $consultationNote,
                isBooking: isBooking,
                onConfirm: {
                    confirmBooking(slot: slot)
                },
                onCancel: {
                    selectedSlot = nil
                }
            )
            .presentationDetents([.fraction(0.65), .large])
        }
        .alert("Consultation Requested", isPresented: $showSuccessDialog) {
            Button("View My Consultations") {
                navigateToMyAppointments = true
            }
            Button("Done", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            animate = true
            fetchSlots()
        }
    }
}

// MARK: - Booking Confirmation Modal Sheet
struct BookingConfirmationSheet: View {
    var slot: Slot
    @Binding var note: String
    var isBooking: Bool
    var onConfirm: () -> Void
    var onCancel: () -> Void
    
    @ObservedObject private var specManager = ExpertSpecializationManager.shared
    
    private var expertNameClean: String {
        slot.doctor_name.replacingOccurrences(of: "Dr. ", with: "").replacingOccurrences(of: "Dr.", with: "")
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            VStack(spacing: 20) {
                // Drag handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.black.opacity(0.18))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                
                // Header
                VStack(spacing: 4) {
                    Text("Confirm Consultation")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.titleText)
                    
                    Text("Review the session details with your hair specialist")
                        .font(.caption)
                        .foregroundColor(AppTheme.bodyText(0.75))
                }
                
                // Specialist Summary Card
                GlassCard(cornerRadius: 18, paddingAmount: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [AppTheme.emeraldMint, AppTheme.primaryBrand], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 50, height: 50)
                                    .shadow(color: AppTheme.emeraldMint.opacity(0.3), radius: 6, y: 3)
                                
                                Image(systemName: "person.badge.shield.checkmark.fill")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Specialist \(expertNameClean)")
                                    .font(.headline.weight(.bold))
                                    .foregroundColor(AppTheme.titleText)
                                
                                Text(specManager.getSpecialization(for: slot.doctor_id))
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(AppTheme.primaryBrand)
                            }
                            
                            Spacer()
                        }
                        
                        Divider().opacity(0.5)
                        
                        // Slot Time
                        HStack(spacing: 10) {
                            Image(systemName: "calendar.badge.clock")
                                .foregroundColor(AppTheme.primaryBrand)
                                .font(.system(size: 16))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Scheduled Time")
                                    .font(.caption2)
                                    .foregroundColor(AppTheme.bodyText(0.6))
                                Text(formatDate(slot.slot_time))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(AppTheme.titleText)
                            }
                            
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Optional Note Box
                VStack(alignment: .leading, spacing: 6) {
                    Text("Consultation Topic / Notes (Optional)")
                        .font(.caption.weight(.bold))
                        .foregroundColor(AppTheme.bodyText(0.8))
                    
                    TextField("e.g. Discuss hair shedding, serum routine, scalp sensitivity...", text: $note)
                        .font(.subheadline)
                        .padding(12)
                        .background(Color.white.opacity(0.75))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.06), lineWidth: 1))
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 10) {
                    Button {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        onConfirm()
                    } label: {
                        HStack(spacing: 8) {
                            if isBooking {
                                ProgressView().tint(.white)
                            }
                            Image(systemName: "calendar.badge.checkmark")
                            Text(isBooking ? "Confirming Booking..." : "Confirm & Book Session")
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(isBooking)
                    
                    Button("Cancel", role: .cancel) {
                        onCancel()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(AppTheme.bodyText(0.7))
                    .padding(.top, 2)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
    }
}

struct SlotCardView: View {
    var slot: Slot
    var animate: Bool
    var bookAction: () -> Void
    
    @ObservedObject private var langManager = AppLanguageManager.shared
    @ObservedObject private var specManager = ExpertSpecializationManager.shared
    
    private var expertSpec: String {
        specManager.getSpecialization(for: slot.doctor_id)
    }
    
    private var expertLangs: [String] {
        specManager.getLanguages(for: slot.doctor_id)
    }
    
    private var expertNameClean: String {
        slot.doctor_name.replacingOccurrences(of: "Dr. ", with: "").replacingOccurrences(of: "Dr.", with: "")
    }
    
    var body: some View {
        GlassCard(cornerRadius: 20, paddingAmount: 18) {
            VStack(alignment: .leading, spacing: 14) {
                
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [AppTheme.emeraldMint, AppTheme.primaryBrand], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 48, height: 48)
                            .shadow(color: AppTheme.emeraldMint.opacity(0.3), radius: 6, y: 3)
                        
                        Image(systemName: "person.badge.shield.checkmark.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Specialist \(expertNameClean)")
                            .font(.headline.weight(.bold))
                            .foregroundColor(AppTheme.titleText)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.primaryBrand)
                            Text(formatDate(slot.slot_time))
                                .font(.caption.weight(.medium))
                                .foregroundColor(AppTheme.bodyText)
                        }
                    }
                    
                    Spacer()
                    
                    Text("AVAILABLE")
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundColor(AppTheme.emeraldMint)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(AppTheme.emeraldMint.opacity(0.12))
                        .clipShape(Capsule())
                }
                
                // Specialization & Spoken Languages Badge
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.primaryBrand)
                        
                        Text(expertSpec)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(AppTheme.titleText)
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(AppTheme.primaryBrand.opacity(0.08))
                    .clipShape(Capsule())
                    
                    // Languages tag
                    HStack(spacing: 5) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.emeraldMint)
                        
                        Text(expertLangs.joined(separator: " • "))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppTheme.bodyText(0.85))
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(AppTheme.emeraldMint.opacity(0.08))
                    .clipShape(Capsule())
                }
                
                Button(action: bookAction) {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar.badge.plus")
                        Text(langManager.text("request_consultation"))
                    }
                }
                .buttonStyle(PrimaryButtonStyle(height: 46))
            }
        }
        .opacity(animate ? 1 : 0)
        .offset(y: animate ? 0 : 20)
        .animation(.easeOut(duration: 0.65), value: animate)
    }
}
