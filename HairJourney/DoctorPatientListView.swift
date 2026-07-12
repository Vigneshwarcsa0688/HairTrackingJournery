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
            AppTheme.gradient.ignoresSafeArea()
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.3.fill").font(.title2).foregroundColor(AppTheme.accent)
                        Text("My Members").font(.title.bold()).foregroundColor(AppTheme.titleText)
                    }
                    Text("Select a member to view their full portfolio")
                        .font(.subheadline).foregroundColor(AppTheme.bodyText)
                }
                .padding(.top, 20).padding(.bottom, 14)
                .opacity(animate ? 1 : 0).offset(y: animate ? 0 : -20)
                .animation(.easeOut(duration: 0.6), value: animate)

                SearchBar(text: $searchText).padding(.horizontal).padding(.bottom, 12)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        if isLoading {
                            ProgressView("Loading members...").tint(AppTheme.accent).padding(.top, 40)
                        } else if filtered.isEmpty {
                            GlassCard {
                                VStack(spacing: 8) {
                                    Image(systemName: "person.slash").font(.largeTitle)
                                        .foregroundColor(AppTheme.bodyText(0.4))
                                    Text("No members found").foregroundColor(AppTheme.bodyText)
                                }.frame(maxWidth: .infinity).padding()
                            }.padding(.horizontal)
                        } else {
                            ForEach(Array(filtered.enumerated()), id: \.element.id) { idx, patient in
                                PatientRow(patient: patient, doctor: doctor, index: idx, animate: animate)
                            }
                        }
                        Spacer(minLength: 40)
                    }.padding(.horizontal)
                }
            }
        }
        .navigationTitle("Members").navigationBarTitleDisplayMode(.inline)
        .onAppear { animate = true; fetchPatients() }
    }

    @ViewBuilder
    func statChip(_ icon: String, _ count: String, _ label: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon).font(.system(size: 9)).foregroundColor(AppTheme.accent)
            Text("\(count) \(label)").font(.system(size: 10)).foregroundColor(AppTheme.bodyText)
        }
        .padding(.horizontal, 6).padding(.vertical, 3)
        .background(Color.white.opacity(0.5)).cornerRadius(6)
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
            GlassCard {
                HStack(spacing: 14) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [AppTheme.accent, .purple.opacity(0.7)],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 52, height: 52)
                        Text(String(patient.name.prefix(1)))
                            .font(.title2.bold()).foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(patient.name).font(.headline.bold()).foregroundColor(AppTheme.titleText)
                        Text(patient.email).font(.caption).foregroundColor(AppTheme.bodyText)
                        
                        HStack(spacing: 10) {
                            statChip("doc.text", patient.quiz_count, "Quizzes")
                            statChip("photo", patient.image_count, "Photos")
                            statChip("calendar", patient.appointment_count, "Appts")
                        }
                    }
                    
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppTheme.bodyText(0.6))
                }
            }
        }
        .opacity(animate ? 1 : 0).offset(y: animate ? 0 : 25)
        .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.07), value: animate)
    }
    
    @ViewBuilder
    func statChip(_ icon: String, _ count: String, _ label: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon).font(.system(size: 9)).foregroundColor(AppTheme.accent)
            Text("\(count) \(label)").font(.system(size: 10)).foregroundColor(AppTheme.bodyText)
        }
        .padding(.horizontal, 6).padding(.vertical, 3)
        .background(Color.white.opacity(0.5)).cornerRadius(6)
    }
}
