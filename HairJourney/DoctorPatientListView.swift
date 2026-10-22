import SwiftUI

// MARK: - Patient model for list
struct PatientListItem: Codable, Identifiable {
    var id: String
    var name: String
    var email: String
    var phone: String?
    var place: String?
    var dob: String?
    var quiz_count: String
    var image_count: String
    var appointment_count: String
    var last_appointment: String?
}

struct DoctorPatientListView: View {
    var doctor: User
    @State private var patients: [PatientListItem] = []
    @State private var searchText = ""
    @State private var animate = false
    @State private var isLoading = true

    var filtered: [PatientListItem] {
        if searchText.isEmpty { return patients }
        return patients.filter { $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.email.localizedCaseInsensitiveContains(searchText) }
    }

    func fetchPatients() {
        guard let url = URL(string: APIService.baseURL + "get_all_patients.php") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                isLoading = false
                guard let data = data else { return }
                patients = (try? JSONDecoder().decode([PatientListItem].self, from: data)) ?? []
            }
        }.resume()
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.3.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.primaryBrand)
                        Text("Member Portfolios")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.titleText)
                    }
                    Text("Select a member to view their complete hair care portfolio")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.bodyText)
                }
                .padding(.top, 16)
                .padding(.bottom, 14)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : -20)
                .animation(.easeOut(duration: 0.6), value: animate)

                SearchBar(text: $searchText)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        if isLoading {
                            VStack(spacing: 12) {
                                ProgressView().tint(AppTheme.primaryBrand)
                                Text("Loading members...")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.bodyText)
                            }
                            .padding(.top, 50)
                        } else if filtered.isEmpty {
                            GlassCard(cornerRadius: 20, padding: 24) {
                                VStack(spacing: 10) {
                                    Image(systemName: "person.crop.circle.badge.questionmark")
                                        .font(.system(size: 40))
                                        .foregroundColor(AppTheme.bodyText.opacity(0.4))
                                    Text("No Members Found")
                                        .font(.headline)
                                        .foregroundColor(AppTheme.titleText)
                                    Text("Try adjusting your search query.")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.bodyText)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                            }
                            .padding(.horizontal, 4)
                        } else {
                            ForEach(Array(filtered.enumerated()), id: \.element.id) { idx, patient in
                                PatientRow(patient: patient, doctor: doctor, index: idx, animate: animate)
                            }
                        }
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .navigationTitle("Members")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { animate = true; fetchPatients() }
    }
}

// MARK: - Subviews for performance
struct PatientRow: View {
    let patient: PatientListItem
    let doctor: User
    let index: Int
    let animate: Bool
    
    var body: some View {
        NavigationLink(destination: PatientPortfolioView(
            patientId: patient.id,
            patientName: patient.name,
            doctor: doctor
        )) {
            GlassCard(cornerRadius: 18, padding: 14) {
                HStack(spacing: 14) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.primaryBrand, AppTheme.irisPurple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                        
                        Text(String(patient.name.prefix(1)).uppercased())
                            .font(.system(size: 19, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text(patient.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.titleText)
                        
                        Text(patient.email)
                            .font(.caption)
                            .foregroundColor(AppTheme.bodyText)
                            .lineLimit(1)
                        
                        HStack(spacing: 8) {
                            statChip("doc.text.fill", patient.quiz_count, "Quiz", color: AppTheme.primaryBrand)
                            statChip("photo.fill", patient.image_count, "Photos", color: AppTheme.emeraldMint)
                            statChip("calendar", patient.appointment_count, "Appts", color: AppTheme.coralRose)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.bodyText.opacity(0.4))
                }
            }
        }
        .buttonStyle(.plain)
        .opacity(animate ? 1 : 0)
        .offset(y: animate ? 0 : 25)
        .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.05), value: animate)
    }
    
    @ViewBuilder
    func statChip(_ icon: String, _ count: String, _ label: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(color)
            Text("\(count) \(label)")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(AppTheme.titleText)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(color.opacity(0.12))
    }
}
