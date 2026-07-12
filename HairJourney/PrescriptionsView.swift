import SwiftUI

// MARK: - Model
struct PrescriptionItem: Codable, Identifiable {
    var id: String
    var doctor_name: String
    var medicines: String
    var notes: String
    var created_at: String
}

struct PrescriptionsView: View {
    var user: User
    @State private var prescriptions: [PrescriptionItem] = []
    @State private var animate = false
    @State private var isLoading = true
    
    // Add Prescription state
    @State private var showAddSheet = false
    @State private var newMedicine = ""
    @State private var newFrequency = 1
    @State private var newNotes = ""
    @State private var isSubmitting = false

    func fetchPrescriptions() {
        guard let url = URL(string: APIService.baseURL + "get_prescriptions.php?user_id=\(user.id)") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                isLoading = false
                guard let data = data else { return }
                prescriptions = (try? JSONDecoder().decode([PrescriptionItem].self, from: data)) ?? []
            }
        }.resume()
    }
    
    func savePrescription() {
        isSubmitting = true
        let body: [String: Any] = [
            "user_id": user.id,
            "doctor_id": 0, // 0 handles self-prescription in backend
            "medicines": newMedicine,
            "notes": newNotes + " [Frequency: \(newFrequency)x/day]"
        ]
        
        guard let url = URL(string: APIService.baseURL + "add_prescription.php"),
              let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            isSubmitting = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, res, err in
            DispatchQueue.main.async {
                isSubmitting = false
                showAddSheet = false
                
                // Also update the reminder preferences automatically and schedule them!
                var prefs = SerumReminderPrefs.load()
                prefs.timesPerDay = newFrequency
                prefs.save()
                
                // Sync to backend Cloud
                let uIdStr: String
                if let str = user.id as? String { uIdStr = str }
                else if let i = user.id as? Int { uIdStr = "\(i)" } else { uIdStr = "" }
                
                let fmt = DateFormatter()
                fmt.dateFormat = "HH:mm"
                let bodyDict: [String: Any] = [
                    "user_id": uIdStr,
                    "frequency": prefs.timesPerDay,
                    "time_1": fmt.string(from: prefs.time1),
                    "time_2": fmt.string(from: prefs.time2),
                    "time_3": fmt.string(from: prefs.time3)
                ]
                if let url = URL(string: APIService.baseURL + "update_reminders.php") {
                    var hr = URLRequest(url: url)
                    hr.httpMethod = "POST"
                    hr.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    hr.httpBody = try? JSONSerialization.data(withJSONObject: bodyDict)
                    URLSession.shared.dataTask(with: hr).resume()
                }
                
                // Clear form
                newMedicine = ""
                newNotes = ""
                isLoading = true
                fetchPrescriptions()
            }
        }.resume()
    }

    func formattedDate(_ s: String) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let d = f.date(from: s) { f.dateStyle = .medium; return f.string(from: d) }
        return s
    }

    var body: some View {
        ZStack {
            AppTheme.gradient.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {

                    // Header
                    VStack(spacing: 6) {
                        HStack(spacing: 8) {
                            Image(systemName: "pills.fill").font(.title2).foregroundColor(AppTheme.accent)
                            Text("My Medications").font(.title.bold()).foregroundColor(AppTheme.titleText)
                        }
                        Text("Track wellness and self-added routines").font(.subheadline).foregroundColor(AppTheme.bodyText)
                    }
                    .padding(.top)
                    .opacity(animate ? 1 : 0).offset(y: animate ? 0 : -20)
                    .animation(.easeOut(duration: 0.6), value: animate)

                    if isLoading {
                        ProgressView("Loading routines...")
                            .tint(AppTheme.accent).padding(.top, 40)
                    } else if prescriptions.isEmpty {
                        GlassCard {
                            VStack(spacing: 10) {
                                Image(systemName: "cross.case.fill")
                                    .font(.system(size: 40)).foregroundColor(AppTheme.bodyText(0.4))
                                Text("No routines yet")
                                    .font(.subheadline).foregroundColor(AppTheme.bodyText)
                                Text("You can add your own product or wait for your expert to recommend one.")
                                    .font(.caption).foregroundColor(AppTheme.bodyText(0.7))
                                    .multilineTextAlignment(.center)
                            }.frame(maxWidth: .infinity).padding(.vertical, 10)
                        }
                    } else {
                        ForEach(Array(prescriptions.enumerated()), id: \.element.id) { idx, rx in
                            GlassCard {
                                VStack(alignment: .leading, spacing: 14) {

                                    // Doctor + Date header
                                    HStack {
                                        HStack(spacing: 8) {
                                            ZStack {
                                                Circle().fill(AppTheme.accent.opacity(rx.doctor_name == "Self" ? 0.0 : 0.15)).frame(width: 38, height: 38)
                                                if rx.doctor_name == "Self" {
                                                    Image(systemName: "person.fill").foregroundColor(.orange)
                                                } else {
                                                    Image(systemName: "stethoscope").foregroundColor(AppTheme.accent)
                                                }
                                            }
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(rx.doctor_name == "Self" ? "Self-Prescribed" : "Dr. \(rx.doctor_name)")
                                                    .font(.headline.bold()).foregroundColor(AppTheme.titleText)
                                                Text(formattedDate(rx.created_at))
                                                    .font(.caption).foregroundColor(AppTheme.bodyText)
                                            }
                                        }
                                        Spacer()
                                        Text("Rx \(idx + 1)")
                                            .font(.caption.bold()).padding(.horizontal, 8).padding(.vertical, 4)
                                            .background(Color.purple.opacity(0.12))
                                            .foregroundColor(.purple).cornerRadius(8)
                                    }

                                    Divider().opacity(0.5)

                                    // Medicines
                                    VStack(alignment: .leading, spacing: 6) {
                                        Label("Products", systemImage: "pills.fill")
                                            .font(.subheadline.bold()).foregroundColor(AppTheme.titleText)

                                        let meds = rx.medicines.components(separatedBy: ",")
                                        ForEach(meds, id: \.self) { med in
                                            HStack(spacing: 8) {
                                                Image(systemName: "capsule.fill")
                                                    .foregroundColor(.green).font(.caption)
                                                Text(med.trimmingCharacters(in: .whitespaces))
                                                    .font(.subheadline).foregroundColor(AppTheme.titleText)
                                            }
                                            .padding(.vertical, 6).padding(.horizontal, 10)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.green.opacity(0.08)).cornerRadius(10)
                                        }
                                    }

                                    // Notes
                                    if !rx.notes.isEmpty {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Label("Notes", systemImage: "note.text")
                                                .font(.subheadline.bold()).foregroundColor(AppTheme.titleText)
                                            Text(rx.notes)
                                                .font(.subheadline).foregroundColor(AppTheme.bodyText)
                                                .padding(10).frame(maxWidth: .infinity, alignment: .leading)
                                                .background(Color.blue.opacity(0.07)).cornerRadius(10)
                                        }
                                    }
                                }
                            }
                            .opacity(animate ? 1 : 0).offset(y: animate ? 0 : 30)
                            .animation(.easeOut(duration: 0.7).delay(Double(idx) * 0.08), value: animate)
                        }
                    }
                    Spacer(minLength: 80)
                }
                .padding()
            }
            
            // Add FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(20)
                            .background(LinearGradient(colors: [AppTheme.accent, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .clipShape(Circle())
                            .shadow(color: AppTheme.accent.opacity(0.4), radius: 8, y: 4)
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Routines")
                    .font(.headline.bold())
                    .foregroundColor(AppTheme.titleText)
            }
        }
        .onAppear { animate = true; fetchPrescriptions() }
        .sheet(isPresented: $showAddSheet) {
            addPrescriptionSheet()
        }
    }
    
    @ViewBuilder
    func addPrescriptionSheet() -> some View {
        ZStack {
            AppTheme.gradient.ignoresSafeArea()
            VStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 3).fill(.gray.opacity(0.4))
                    .frame(width: 40, height: 5).padding(.top, 14)
                
                Text("New Routine").font(.title3.bold()).foregroundColor(AppTheme.titleText)
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Product / Serum Name").font(.subheadline.bold()).foregroundColor(AppTheme.titleText)
                        TextField("e.g. Minoxidil 5% Serum", text: $newMedicine)
                            .padding().background(Color.white.opacity(0.5)).cornerRadius(10)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Frequency").font(.subheadline.bold()).foregroundColor(AppTheme.titleText)
                        Picker("Frequency", selection: $newFrequency) {
                            Text("1x / day").tag(1)
                            Text("2x / day").tag(2)
                        }.pickerStyle(.segmented)
                        Text("This will update your Serum Calendar reminders too.").font(.caption2).foregroundColor(AppTheme.bodyText)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Notes (Optional)").font(.subheadline.bold()).foregroundColor(AppTheme.titleText)
                        TextField("Any specific instructions?", text: $newNotes)
                            .padding().background(Color.white.opacity(0.5)).cornerRadius(10)
                    }
                    
                }.padding(.horizontal)
                
                Spacer()
                
                Button {
                    savePrescription()
                } label: {
                    HStack {
                        if isSubmitting { ProgressView().tint(.white) }
                        Text(isSubmitting ? "Adding..." : "Save Routine").fontWeight(.semibold)
                    }
                    .foregroundColor(.white).frame(maxWidth: .infinity).padding(14)
                    .background(newMedicine.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(14)
                }
                .disabled(newMedicine.isEmpty || isSubmitting)
                .padding()
            }
        }
        .presentationDetents([.fraction(0.65)])
    }
}
