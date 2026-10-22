import SwiftUI

// MARK: - Portfolio Models
struct PatientProfile: Codable {
    var id: String
    var name: String
    var email: String
    var phone: String?
    var place: String?
    var dob: String?
    var profile_picture: String?
    var created_at: String?
}

struct PortfolioQuizReport: Codable, Identifiable {
    var id: String
    var scalp_type: String
    var sleep_hours: String
    var hair_fall_frequency: String
    var family_history: String
    var stress_level: String
    var diet: String
    var deficiencies: String
    var hair_texture: String
    var hair_loss_stage: String
    var sudden_thinning: String
    var dandruff: String
    var styling_tools: String
    var scalp_pain: String
    var result_summary: String
    var doctor_remark: String?
    var created_at: String
}

struct PortfolioAppointment: Codable, Identifiable {
    var id: String
    var doctor_name: String
    var slot_time: String
    var status: String
    var created_at: String
}

struct PortfolioImage: Codable, Identifiable {
    var id: String
    var image_path: String
    var progress_tag: String
    var view_type: String
    var capture_date: String
    var doctor_remark: String?
    var created_at: String
}

struct PortfolioPrescription: Codable, Identifiable {
    var id: String
    var doctor_name: String
    var medicines: String
    var notes: String
    var created_at: String
}

struct PortfolioClinicalScore: Codable, Identifiable {
    var id: String
    var mmas8: String
    var dlqi: String
    var created_at: String
}

struct PatientPortfolioData: Codable {
    var profile: PatientProfile
    var quiz_reports: [PortfolioQuizReport]
    var appointments: [PortfolioAppointment]
    var hair_images: [PortfolioImage]
    var prescriptions: [PortfolioPrescription]
    var compliance_percent: Double
    var compliance_days: Int
    var clinical_scores: [PortfolioClinicalScore]
}

// MARK: - Patient Portfolio View
struct PatientPortfolioView: View {
    var patientId: String
    var patientName: String
    var doctor: User

    @Environment(\.horizontalSizeClass) var sizeClass
    @State private var portfolio: PatientPortfolioData? = nil
    @State private var selectedTab = 0
    @State private var animate = false
    @State private var isLoading = true
    @State private var fullScreenItem: IdentifiableURL? = nil
    @State private var saveMessage = ""

    // Remark editing state
    @State private var editingQuizId: String? = nil
    @State private var quizRemarkDraft = ""
    @State private var editingImageId: String? = nil
    @State private var imageRemarkDraft = ""

    // Prescription state
    @State private var showPrescriptionSheet = false
    @State private var draftMedicines = ""
    @State private var draftRxNotes = ""
    @State private var draftRxFrequency = 1
    @State private var isSubmittingRx = false

    let tabs     = ["Profile", "Quiz", "Appts", "Photos", "Rx", "Serum"]
    let tabIcons  = ["person.fill", "doc.text.fill", "calendar", "photo.fill", "pills.fill", "drop.fill"]

    // MARK: - Data Fetching
    func fetchPortfolio() {
        guard let url = URL(string: APIService.baseURL + "get_patient_portfolio.php?patient_id=\(patientId)") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                isLoading = false
                guard let data = data,
                      let decoded = try? JSONDecoder().decode(PatientPortfolioData.self, from: data) else { return }
                portfolio = decoded
            }
        }.resume()
    }

    func saveQuizRemark(reportId: String, remark: String) {
        guard let url = URL(string: APIService.baseURL + "add_quiz_remark.php"),
              let id = Int(reportId) else { return }
        let body: [String: Any] = ["report_id": id, "doctor_remark": remark]
        var req = URLRequest(url: url); req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: req) { _, _, _ in
            DispatchQueue.main.async {
                editingQuizId = nil
                saveMessage = "✅ Remark saved"
                fetchPortfolio()
            }
        }.resume()
    }

    func saveImageRemark(imageId: String, remark: String) {
        guard let url = URL(string: APIService.baseURL + "add_image_remark.php"),
              let id = Int(imageId) else { return }
        let body: [String: Any] = ["image_id": id, "doctor_remark": remark]
        var req = URLRequest(url: url); req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: req) { _, _, _ in
            DispatchQueue.main.async {
                editingImageId = nil
                saveMessage = "✅ Feedback saved"
                fetchPortfolio()
            }
        }.resume()
    }

    func savePrescription() {
        guard let url = URL(string: APIService.baseURL + "add_prescription.php") else { return }
        isSubmittingRx = true
        let notes = draftRxNotes + (draftRxFrequency > 0 ? " [Frequency: \(draftRxFrequency)x/day]" : "")
        let body: [String: Any] = [
            "user_id": Int(patientId) ?? 0,
            "doctor_id": Int(doctor.id) ?? 0,
            "medicines": draftMedicines,
            "notes": notes
        ]
        var req = URLRequest(url: url); req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: req) { _, _, _ in
            DispatchQueue.main.async {
                isSubmittingRx = false
                showPrescriptionSheet = false
                draftMedicines = ""
                draftRxNotes = ""
                saveMessage = "✅ Routine recommendation issued"
                fetchPortfolio()
            }
        }.resume()
    }

    func exportPDF() {
        #if canImport(UIKit)
        guard let p = portfolio else { return }
        let html = """
        <html><head><style>
        body { font-family: Helvetica; color: #333; margin: 40px; }
        h1 { color: #7b5ea7; }
        h2 { color: #2c3e50; margin-top: 20px; }
        .card { background: #f9f9f9; padding: 15px; border-radius: 8px; margin-top: 15px; border: 1px solid #eee; }
        .row { display: flex; justify-content: space-between; padding: 6px 0; border-bottom: 1px solid #eee; }
        </style></head><body>
        <h1>Hair Journey — Member Report</h1>
        <hr>
        <h2>Member: \(p.profile.name)</h2>
        <div class="row"><span>Email</span><span>\(p.profile.email)</span></div>
        <div class="row"><span>Phone</span><span>\(p.profile.phone ?? "-")</span></div>
        <div class="row"><span>DOB</span><span>\(p.profile.dob ?? "-")</span></div>
        <div class="row"><span>Compliance</span><span>\(String(format: "%.0f%%", p.compliance_percent)) (\(p.compliance_days) days)</span></div>
        </div>
        <div class="card"><h2>Routines (\(p.prescriptions.count))</h2>
        \(p.prescriptions.map { "<div class='row'><span>\($0.medicines)</span><span>Expert \($0.doctor_name.replacingOccurrences(of: "Dr. ", with: "").replacingOccurrences(of: "Dr.", with: ""))</span></div>" }.joined())
        </div>
        </body></html>
        """
        let fmt = UIMarkupTextPrintFormatter(markupText: html)
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fmt, startingAtPageAt: 0)
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
        render.setValue(page, forKey: "paperRect")
        render.setValue(page, forKey: "printableRect")
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, page, nil as [AnyHashable: Any]?)
        for i in 0..<render.numberOfPages {
            UIGraphicsBeginPDFPage()
            render.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext()
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(p.profile.name)_Report.pdf")
        try? pdfData.write(to: fileURL)
        let av = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            av.popoverPresentationController?.sourceView = root.view
            root.present(av, animated: true)
        }
        #endif
    }

    func formatStatus(_ s: String) -> String {
        switch s.lowercased() {
        case "scheduled": return "Scheduled"
        case "completed": return "Done"
        case "cancelled": return "Cancelled"
        default: return s.capitalized
        }
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            AppTheme.gradient.ignoresSafeArea()
            VStack(spacing: 0) {

                // Member summary header
                if let p = portfolio {
                    GlassCard {
                        HStack(spacing: 14) {
                            ZStack {
                                if let pp = p.profile.profile_picture, let url = URL(string: APIService.baseURL + pp) {
                                    CachedAsyncImage(url: url) { phase in
                                        if let image = phase.image {
                                            image.resizable().scaledToFill()
                                        } else {
                                            Circle().fill(AppTheme.premiumAccentGradient)
                                        }
                                    }
                                    .frame(width: 64, height: 64)
                                    .clipShape(Circle())
                                    .shadow(color: AppTheme.accent.opacity(0.3), radius: 6, y: 3)
                                } else {
                                    Circle()
                                        .fill(AppTheme.premiumAccentGradient)
                                        .frame(width: 64, height: 64)
                                        .shadow(color: AppTheme.accent.opacity(0.3), radius: 6, y: 3)
                                    Text(String(p.profile.name.prefix(1)))
                                        .font(.title2.bold()).foregroundColor(.white)
                                }
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(p.profile.name).font(.title3.bold()).foregroundColor(AppTheme.titleText)
                                Text(p.profile.email).font(.caption).foregroundColor(AppTheme.bodyText)
                                HStack(spacing: 4) {
                                    Image(systemName: "phone.fill").font(.caption2).foregroundColor(AppTheme.accent)
                                    Text(p.profile.phone ?? "—").font(.caption).foregroundColor(AppTheme.bodyText)
                                }
                            }
                            Spacer()
                            VStack(spacing: 2) {
                                ZStack {
                                    Circle().stroke(Color.gray.opacity(0.15), lineWidth: 6).frame(width: 52, height: 52)
                                    Circle()
                                        .trim(from: 0, to: CGFloat(p.compliance_percent / 100))
                                        .stroke(p.compliance_percent >= 80
                                            ? AnyShapeStyle(AppTheme.complianceGradient)
                                            : AnyShapeStyle(p.compliance_percent > 50 ? Color.orange : AppTheme.error),
                                                style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                        .frame(width: 52, height: 52).rotationEffect(.degrees(-90))
                                        .animation(.spring(response: 0.7, dampingFraction: 0.7), value: animate)
                                    Text(String(format: "%.0f%%", p.compliance_percent))
                                        .font(.caption2.bold()).foregroundColor(AppTheme.titleText)
                                }
                                Text("Compliance").font(.system(size: 9)).foregroundColor(AppTheme.bodyText)
                            }
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal).padding(.top, 12)
                    .frame(maxWidth: AppTheme.maxContentWidth(sizeClass))
                    .frame(maxWidth: .infinity, alignment: .center)
                }

                // Tab bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(tabs.indices, id: \.self) { i in
                            Button {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { selectedTab = i }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: tabIcons[i]).font(.subheadline)
                                    if selectedTab == i { Text(tabs[i]).font(.subheadline.bold()) }
                                }
                                .foregroundColor(selectedTab == i ? .white : AppTheme.bodyText)
                                .padding(.horizontal, selectedTab == i ? 16 : 12)
                                .padding(.vertical, 10)
                                .background(selectedTab == i ? AnyView(AppTheme.premiumAccentGradient) : AnyView(Color.white.opacity(0.45)))
                                .cornerRadius(20)
                                .shadow(color: selectedTab == i ? AppTheme.accent.opacity(0.3) : .clear, radius: 6, y: 3)
                            }
                        }
                    }
                    .padding(.horizontal).padding(.vertical, 10)
                    .frame(minWidth: sizeClass == .regular ? AppTheme.maxContentWidth(sizeClass) : 0, alignment: .center)
                }
                .frame(maxWidth: AppTheme.maxContentWidth(sizeClass))

                if !saveMessage.isEmpty {
                    Text(saveMessage).font(.caption.bold()).foregroundColor(.green)
                        .transition(.opacity).padding(.bottom, 4)
                }

                // Content area
                if isLoading {
                    VStack(spacing: 10) {
                        ProgressView()
                            .scaleEffect(1.5).progressViewStyle(CircularProgressViewStyle(tint: AppTheme.accent))
                        Text("Loading member portfolio...").foregroundColor(AppTheme.bodyText)
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let p = portfolio {
                    ScrollView(showsIndicators: false) {
                        Group {
                            switch selectedTab {
                            case 0:
                                PortfolioProfileTab(p: p, sizeClass: sizeClass, onExport: exportPDF)
                            case 1:
                                PortfolioQuizTab(
                                    reports: p.quiz_reports,
                                    editingQuizId: $editingQuizId,
                                    quizRemarkDraft: $quizRemarkDraft,
                                    onSave: saveQuizRemark
                                )
                            case 2:
                                PortfolioAppointmentsTab(appointments: p.appointments, statusFormatter: formatStatus)
                            case 3:
                                PortfolioPhotosTab(
                                    images: p.hair_images,
                                    editingImageId: $editingImageId,
                                    imageRemarkDraft: $imageRemarkDraft,
                                    fullScreenItem: $fullScreenItem,
                                    onSave: saveImageRemark
                                )
                            case 4:
                                PortfolioPrescriptionsTab(
                                    prescriptions: p.prescriptions,
                                    onNew: { showPrescriptionSheet = true }
                                )
                            case 5:
                                SerumCalendarView(user: User(
                                    id: patientId, name: patientName,
                                    email: p.profile.email, role: "patient", created_at: nil
                                ))
                            default: EmptyView()
                            }
                        }
                        .padding(.horizontal).padding(.top, 8).padding(.bottom, 40)
                        .frame(maxWidth: AppTheme.maxContentWidth(sizeClass))
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(patientName)
                    .font(.headline.bold())
                    .foregroundColor(AppTheme.titleText)
            }
        }
        .onAppear { animate = true; fetchPortfolio() }
        .fullScreenCover(item: $fullScreenItem) { item in
            FullScreenImageViewer(url: item.url)
        }
        .sheet(isPresented: $showPrescriptionSheet) {
            ZStack {
                AppBackgroundView()
                VStack(spacing: 20) {
                    RoundedRectangle(cornerRadius: 3).fill(.gray.opacity(0.4))
                        .frame(width: 40, height: 5).padding(.top, 14)
                    Text("Provide Recommendation").font(.title2.bold()).foregroundColor(AppTheme.titleText)
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Products / Serums").font(.subheadline.bold()).foregroundColor(AppTheme.titleText)
                            TextEditor(text: $draftMedicines)
                                .frame(height: 100).padding(8)
                                .background(Color.white.opacity(0.5)).cornerRadius(10)
                                .foregroundColor(AppTheme.titleText)
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Frequency").font(.subheadline.bold()).foregroundColor(AppTheme.titleText)
                            Picker("Frequency", selection: $draftRxFrequency) {
                                Text("1x / day").tag(1)
                                Text("2x / day").tag(2)
                            }.pickerStyle(.segmented)
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Notes (Optional)").font(.subheadline.bold()).foregroundColor(AppTheme.titleText)
                            TextField("Any specific instructions?", text: $draftRxNotes)
                                .padding().background(Color.white.opacity(0.5)).cornerRadius(10)
                        }
                    }.padding(.horizontal)
                    Spacer()
                    Button(action: {
                        savePrescription()
                    }) {
                        Text("Save Recommendation").fontWeight(.bold)
                            .foregroundColor(.white).frame(maxWidth: .infinity).padding()
                            .background(AppTheme.accent).cornerRadius(12)
                    }.padding().disabled(draftMedicines.isEmpty || isSubmittingRx)
                }
            }.presentationDetents([.fraction(0.65)])
        }
    }
}

// MARK: - Tab Sub-Components

struct PortfolioProfileTab: View {
    let p: PatientPortfolioData
    let sizeClass: UserInterfaceSizeClass?
    let onExport: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            GlassCard {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Member Profile").font(.headline.bold()).foregroundColor(AppTheme.titleText)
                    Divider()
                    row("envelope.fill",  "Email",  p.profile.email)
                    row("phone.fill",     "Phone",  p.profile.phone ?? "—")
                    row("mappin",         "Place",  p.profile.place ?? "—")
                    row("calendar",       "DOB",    p.profile.dob ?? "—")
                }
            }

            LazyVGrid(columns: AppTheme.statsColumns(sizeClass), spacing: 14) {
                stat(p.quiz_reports.count, "Quizzes",     "doc.text.fill", .blue)
                stat(p.hair_images.count, "Photos",       "photo.fill",    .purple)
                stat(p.appointments.count, "Appts",       "calendar",      .green)
                stat(p.compliance_days, "Streak Days",   "flame.fill",    .orange)
            }

            Button(action: onExport) {
                Label("Export PDF Report", systemImage: "square.and.arrow.up")
                    .font(.subheadline.bold()).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(12)
                    .background(AppTheme.accent).cornerRadius(10)
            }.padding(.top, 8)
        }
    }

    @ViewBuilder
    private func row(_ icon: String, _ label: String, _ value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundColor(AppTheme.accent).frame(width: 20)
            Text(label).font(.subheadline).foregroundColor(AppTheme.bodyText)
            Spacer()
            Text(value).font(.subheadline.bold()).foregroundColor(AppTheme.titleText)
        }
    }

    @ViewBuilder
    private func stat(_ val: Int, _ label: String, _ icon: String, _ color: Color) -> some View {
        GlassCard {
            VStack(spacing: 6) {
                Image(systemName: icon).font(.title2).foregroundColor(color)
                Text("\(val)").font(.title2.bold()).foregroundColor(AppTheme.titleText)
                Text(label).font(.caption).foregroundColor(AppTheme.bodyText)
            }
        }
    }
}

struct PortfolioQuizTab: View {
    let reports: [PortfolioQuizReport]
    @Binding var editingQuizId: String?
    @Binding var quizRemarkDraft: String
    let onSave: (String, String) -> Void

    var body: some View {
        VStack(spacing: 16) {
            if reports.isEmpty {
                GlassCard {
                    VStack(spacing: 10) {
                        Image(systemName: "doc.text").font(.largeTitle).foregroundColor(AppTheme.bodyText(0.4))
                        Text("No quiz reports yet").foregroundColor(AppTheme.bodyText)
                    }.frame(maxWidth: .infinity).padding()
                }
            }
            ForEach(reports) { report in
                GlassCard {
                    VStack(alignment: .leading, spacing: 14) {

                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Hair Assessment Report").font(.headline.bold()).foregroundColor(AppTheme.titleText)
                                Text(formatDate(report.created_at)).font(.caption).foregroundColor(AppTheme.bodyText)
                            }
                            Spacer()
                            Text("#\(report.id)").font(.caption2).foregroundColor(AppTheme.bodyText(0.5))
                        }

                        Divider()

                        // AI Summary Banner
                        VStack(alignment: .leading, spacing: 6) {
                            Label("AI Result Summary", systemImage: "brain.head.profile")
                                .font(.caption.bold()).foregroundColor(AppTheme.accent)
                            Text(report.result_summary)
                                .font(.subheadline).foregroundColor(AppTheme.titleText)
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppTheme.accent.opacity(0.07)).cornerRadius(10)
                        }

                        Divider()

                        // Details Grid
                        Text("Assessment Details").font(.subheadline.bold()).foregroundColor(AppTheme.titleText)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            clinicalCell("Scalp Type",        report.scalp_type,           "waveform.path")
                            clinicalCell("Hair Texture",      report.hair_texture,          "scissors")
                            clinicalCell("Hair Fall Freq.",   report.hair_fall_frequency,   "wind")
                            clinicalCell("Sleep (hrs/night)", report.sleep_hours,           "moon.fill")
                            clinicalCell("Stress Level",      report.stress_level,          "bolt.heart.fill")
                            clinicalCell("Diet",              report.diet,                  "fork.knife")
                            clinicalCell("Deficiencies",      report.deficiencies.isEmpty ? "None" : report.deficiencies, "pills.fill")
                        }

                        // Yes/No indicators
                        Text("Symptom Indicators").font(.subheadline.bold()).foregroundColor(AppTheme.titleText)
                            .padding(.top, 4)

                        HStack(spacing: 10) {
                            indicatorBadge("Family History", report.family_history)
                            indicatorBadge("Sudden Thinning", report.sudden_thinning)
                            indicatorBadge("Dandruff", report.dandruff)
                            indicatorBadge("Scalp Pain", report.scalp_pain)
                        }

                        if !report.styling_tools.isEmpty && report.styling_tools.lowercased() != "no" {
                            Label("Uses styling tools: \(report.styling_tools)", systemImage: "sparkles")
                                .font(.caption).foregroundColor(.orange)
                        }

                        Divider()

                        // Expert Remark
                        if editingQuizId == report.id {
                            VStack(alignment: .leading, spacing: 8) {
                                Label("Your Expert Guidance", systemImage: "sparkles")
                                    .font(.caption.bold()).foregroundColor(AppTheme.accent)
                                TextEditor(text: $quizRemarkDraft)
                                    .frame(height: 100).padding(8)
                                    .background(Color.white.opacity(0.5)).cornerRadius(10)
                                    .foregroundColor(AppTheme.titleText)
                                HStack {
                                    Button("Cancel") { editingQuizId = nil }.foregroundColor(.red)
                                    Spacer()
                                    Button("Save Guidance") { onSave(report.id, quizRemarkDraft) }
                                        .font(.subheadline.bold()).foregroundColor(.white)
                                        .padding(.horizontal, 14).padding(.vertical, 8)
                                        .background(AppTheme.accent).cornerRadius(10)
                                }
                            }
                        } else {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Label("Expert Guidance", systemImage: "sparkles")
                                        .font(.caption.bold()).foregroundColor(AppTheme.accent)
                                    if let r = report.doctor_remark, !r.isEmpty {
                                        Text(r).font(.subheadline).foregroundColor(AppTheme.titleText)
                                            .padding(10).frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.blue.opacity(0.07)).cornerRadius(10)
                                    } else {
                                        Text("No expert guidance recorded yet")
                                            .font(.caption).foregroundColor(.orange)
                                    }
                                }
                                Spacer()
                                Button {
                                    quizRemarkDraft = report.doctor_remark ?? ""
                                    editingQuizId = report.id
                                } label: {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.title2).foregroundColor(AppTheme.accent)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func clinicalCell(_ label: String, _ value: String, _ icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundColor(AppTheme.accent).font(.system(size: 12)).frame(width: 16)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.system(size: 10)).foregroundColor(AppTheme.bodyText)
                Text(value.isEmpty ? "—" : value).font(.system(size: 12, weight: .bold)).foregroundColor(AppTheme.titleText)
            }
        }
        .padding(10).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.35)).cornerRadius(10)
    }

    @ViewBuilder
    private func indicatorBadge(_ label: String, _ value: String) -> some View {
        let isYes = value.lowercased() == "yes"
        VStack(spacing: 3) {
            Image(systemName: isYes ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isYes ? .red : .green).font(.title3)
            Text(label).font(.system(size: 9)).foregroundColor(AppTheme.bodyText).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PortfolioAppointmentsTab: View {
    let appointments: [PortfolioAppointment]
    let statusFormatter: (String) -> String

    var body: some View {
        VStack(spacing: 14) {
            if appointments.isEmpty {
                GlassCard {
                    VStack(spacing: 10) {
                        Image(systemName: "calendar.badge.exclamationmark").font(.largeTitle).foregroundColor(AppTheme.bodyText(0.4))
                        Text("No appointments found").foregroundColor(AppTheme.bodyText)
                    }.frame(maxWidth: .infinity).padding()
                }
            }
            ForEach(appointments) { appt in
                GlassCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Expert \(appt.doctor_name.replacingOccurrences(of: "Dr. ", with: "").replacingOccurrences(of: "Dr.", with: ""))").font(.headline).foregroundColor(AppTheme.titleText)
                            Text(formatDate(appt.slot_time)).font(.caption).foregroundColor(AppTheme.bodyText)
                        }
                        Spacer()
                        Text(statusFormatter(appt.status))
                            .font(.caption.bold())
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Color.green.opacity(0.15)).foregroundColor(.green).cornerRadius(8)
                    }
                }
            }
        }
    }
}

struct PortfolioPhotosTab: View {
    let images: [PortfolioImage]
    @Binding var editingImageId: String?
    @Binding var imageRemarkDraft: String
    @Binding var fullScreenItem: IdentifiableURL?
    let onSave: (String, String) -> Void

    private var albumKeys: [String] {
        Dictionary(grouping: images) { "\($0.capture_date)||\($0.progress_tag)" }
            .keys.sorted(by: >)
    }

    private func imagesForKey(_ key: String) -> [PortfolioImage] {
        images.filter { "\($0.capture_date)||\($0.progress_tag)" == key }
    }

    var body: some View {
        VStack(spacing: 16) {
            if images.isEmpty {
                GlassCard {
                    VStack(spacing: 10) {
                        Image(systemName: "photo.on.rectangle").font(.largeTitle).foregroundColor(AppTheme.bodyText(0.4))
                        Text("No photos uploaded yet").foregroundColor(AppTheme.bodyText)
                    }.frame(maxWidth: .infinity).padding()
                }
            }

            ForEach(albumKeys, id: \.self) { key in
                let parts = key.components(separatedBy: "||")
                let albumDate = parts.count > 0 ? parts[0] : ""
                let albumTag  = parts.count > 1 ? parts[1] : ""
                let albumImgs = imagesForKey(key)

                GlassCard {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(formatProgressTag(albumTag)).font(.headline.bold()).foregroundColor(AppTheme.titleText)
                                Text(formatDate(albumDate)).font(.caption).foregroundColor(AppTheme.bodyText)
                            }
                            Spacer()
                            Text("\(albumImgs.count) Views")
                                .font(.caption2.bold()).padding(.horizontal, 8).padding(.vertical, 4)
                                .background(Color.purple.opacity(0.1)).foregroundColor(.purple).cornerRadius(6)
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(albumImgs) { img in
                                    Button {
                                        if let url = URL(string: APIService.baseURL + img.image_path) {
                                            fullScreenItem = IdentifiableURL(url: url)
                                        }
                                    } label: {
                                        VStack(spacing: 6) {
                                            CachedAsyncImage(url: URL(string: APIService.baseURL + img.image_path)) { phase in
                                                if let i = phase.image {
                                                    i.resizable().scaledToFill()
                                                        .frame(width: 120, height: 160).clipped().cornerRadius(10)
                                                } else {
                                                    Color.gray.opacity(0.1).frame(width: 120, height: 160).cornerRadius(10)
                                                }
                                            }
                                            Text(img.view_type).font(.caption2.bold()).foregroundColor(AppTheme.titleText)
                                        }
                                    }
                                }
                            }
                        }

                        if let first = albumImgs.first {
                            Divider()
                            if editingImageId == first.id {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Expert Guidance").font(.caption.bold()).foregroundColor(AppTheme.bodyText)
                                    TextEditor(text: $imageRemarkDraft)
                                        .frame(height: 80).padding(4)
                                        .background(Color.white.opacity(0.5)).cornerRadius(8)
                                    HStack {
                                        Button("Cancel") { editingImageId = nil }.foregroundColor(.red)
                                        Spacer()
                                        Button("Save Feedback") { onSave(first.id, imageRemarkDraft) }
                                            .foregroundColor(.white).padding(8).background(AppTheme.accent).cornerRadius(8)
                                    }
                                }
                            } else {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Expert Feedback").font(.caption.bold()).foregroundColor(AppTheme.bodyText)
                                        HStack(spacing: 8) {
                                            Image(systemName: "hand.thumbsup.fill").foregroundColor(AppTheme.success)
                                            Text(first.doctor_remark ?? "Awaiting expert feedback")
                                                .font(.caption).foregroundColor(AppTheme.titleText)
                                                .italic(first.doctor_remark == nil)
                                        }
                                    }
                                    Spacer()
                                    Button {
                                        imageRemarkDraft = first.doctor_remark ?? ""
                                        editingImageId = first.id
                                    } label: {
                                        Image(systemName: "pencil.circle.fill").font(.title2).foregroundColor(AppTheme.accent)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct PortfolioPrescriptionsTab: View {
    let prescriptions: [PortfolioPrescription]
    let onNew: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Routines").font(.headline.bold()).foregroundColor(AppTheme.titleText)
                Spacer()
                Button(action: onNew) {
                    Label("Issue New", systemImage: "plus.circle.fill")
                        .font(.caption.bold()).padding(.horizontal, 10).padding(.vertical, 6)
                        .background(AppTheme.accent).foregroundColor(.white).cornerRadius(10)
                }
            }

            if prescriptions.isEmpty {
                GlassCard {
                    VStack(spacing: 10) {
                        Image(systemName: "pills.fill").font(.largeTitle).foregroundColor(AppTheme.bodyText(0.4))
                        Text("No routines issued yet").foregroundColor(AppTheme.bodyText)
                    }.frame(maxWidth: .infinity).padding()
                }
            }

            ForEach(prescriptions) { rx in
                GlassCard {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Label("Expert \(rx.doctor_name.replacingOccurrences(of: "Dr. ", with: "").replacingOccurrences(of: "Dr.", with: ""))", systemImage: "sparkles")
                                .font(.headline.bold()).foregroundColor(AppTheme.titleText)
                            Spacer()
                            Text(formatDate(rx.created_at)).font(.caption).foregroundColor(AppTheme.bodyText)
                        }
                        Divider()
                        Text(rx.medicines).font(.subheadline).foregroundColor(AppTheme.titleText)
                            .padding(8).frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.green.opacity(0.07)).cornerRadius(10)
                        if !rx.notes.isEmpty {
                            Text("Notes: \(rx.notes)").font(.caption).foregroundColor(AppTheme.bodyText)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Portfolio Compare Tab (3-Stage Dual-Handle Slider)
struct PortfolioCompareTab: View {
    let images: [PortfolioImage]
    @Binding var fullScreenItem: IdentifiableURL?

    @State private var selectedViewType = "Frontal"
    @State private var leftHandle: CGFloat  = 0.33
    @State private var rightHandle: CGFloat = 0.67

    let viewTypes = ["Frontal", "Left Lateral", "Right Lateral", "Vertex"]

    func image(for stage: String) -> PortfolioImage? {
        images.first { $0.progress_tag == stage && $0.view_type == selectedViewType }
    }

    var body: some View {
        VStack(spacing: 16) {

            // Angle selector
            GlassCard {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Select View Angle", systemImage: "camera.viewfinder")
                        .font(.caption.bold()).foregroundColor(AppTheme.bodyText)
                    ViewAngleSelector(options: viewTypes, selected: $selectedViewType)
                }
            }

            // Stage upload status row
            HStack {
                ForEach(["Baseline", "3 Months", "6 Months"], id: \.self) { stage in
                    let has = image(for: stage) != nil
                    VStack(spacing: 3) {
                        Text(stage).font(.caption.bold())
                            .foregroundColor(has ? AppTheme.titleText : AppTheme.bodyText(0.4))
                        Circle().fill(has ? AppTheme.accent : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }.frame(maxWidth: .infinity)
                }
            }.padding(.horizontal, 8)

            // Three-stage slider
            GeometryReader { geo in
                let w = geo.size.width
                let h: CGFloat = 400

                ZStack(alignment: .leading) {
                    // Layer 1: Baseline (background, full width)
                    imgLayer(stage: "Baseline", width: w, height: h)

                    // Layer 2: 3 Months clipped to rightHandle
                    imgLayer(stage: "3 Months", width: w, height: h)
                        .mask(HStack(spacing: 0) {
                            Rectangle().frame(width: w * rightHandle)
                            Spacer()
                        })

                    // Layer 3: 6 Months clipped to leftHandle
                    imgLayer(stage: "6 Months", width: w, height: h)
                        .mask(HStack(spacing: 0) {
                            Rectangle().frame(width: w * leftHandle)
                            Spacer()
                        })

                    // Stage labels at bottom
                    HStack(spacing: 0) {
                        stageChip("6 Months", width: w * leftHandle)
                        stageChip("3 Months", width: w * (rightHandle - leftHandle))
                        stageChip("Baseline", width: w * (1.0 - rightHandle))
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom).padding(.bottom, 10)

                    // Left (purple) handle: 6M | 3M boundary
                    dragHandle(color: .purple)
                        .offset(x: w * leftHandle - 16)
                        .gesture(DragGesture().onChanged { v in
                            let p = v.location.x / w
                            leftHandle = min(max(p, 0.05), rightHandle - 0.1)
                        })

                    // Right (orange) handle: 3M | Baseline boundary
                    dragHandle(color: .orange)
                        .offset(x: w * rightHandle - 16)
                        .gesture(DragGesture().onChanged { v in
                            let p = v.location.x / w
                            rightHandle = min(max(p, leftHandle + 0.1), 0.95)
                        })

                    // No-photos overlay
                    if image(for: "Baseline") == nil && image(for: "3 Months") == nil && image(for: "6 Months") == nil {
                        RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(0.55))
                            .overlay(VStack(spacing: 12) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.largeTitle).foregroundColor(.white)
                                Text("No photos uploaded for this member yet")
                                    .font(.callout).foregroundColor(.white)
                                    .multilineTextAlignment(.center).padding(.horizontal)
                            })
                    }
                }
                .frame(width: w, height: h).cornerRadius(16)
                .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
            }
            .frame(height: 400)

            // Legend
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Circle().fill(Color.purple).frame(width: 10, height: 10)
                    Text("6M \u{2194} 3M")
                }
                HStack(spacing: 4) {
                    Circle().fill(Color.orange).frame(width: 10, height: 10)
                    Text("3M \u{2194} Baseline")
                }
            }.font(.caption).foregroundColor(AppTheme.bodyText)

            Label("Drag coloured handles to compare milestones", systemImage: "hand.point.left.fill")
                .font(.caption2).foregroundColor(AppTheme.bodyText)

            Spacer(minLength: 30)
        }
    }

    @ViewBuilder
    private func imgLayer(stage: String, width: CGFloat, height: CGFloat) -> some View {
        if let img = image(for: stage), let url = URL(string: APIService.baseURL + img.image_path) {
            CachedAsyncImage(url: url) { phase in
                if let i = phase.image {
                    i.resizable().scaledToFill().frame(width: width, height: height).clipped()
                } else {
                    Color.gray.opacity(0.15).frame(width: width, height: height)
                }
            }
        } else {
            ZStack {
                Color.black.opacity(0.2).frame(width: width, height: height)
                VStack(spacing: 4) {
                    Image(systemName: "photo.slash").foregroundColor(.white.opacity(0.6))
                    Text(stage).font(.caption).foregroundColor(.white.opacity(0.6))
                    Text("Not uploaded").font(.system(size: 9)).foregroundColor(.white.opacity(0.4))
                }
            }
        }
    }

    @ViewBuilder
    private func stageChip(_ text: String, width: CGFloat) -> some View {
        if width > 30 {
            Text(text).font(.system(size: 10, weight: .bold)).foregroundColor(.white)
                .lineLimit(1).padding(.horizontal, 5).padding(.vertical, 2)
                .background(Color.black.opacity(0.5)).cornerRadius(5)
                .frame(width: width)
        } else {
            Color.clear.frame(width: max(width, 0))
        }
    }

    @ViewBuilder
    private func dragHandle(color: Color) -> some View {
        ZStack {
            Rectangle().fill(Color.white).frame(width: 2.5, height: 400)
            Circle().fill(color).frame(width: 30, height: 30)
                .overlay(Image(systemName: "arrow.left.and.right").font(.system(size: 10)).foregroundColor(.white))
                .shadow(color: color.opacity(0.5), radius: 5)
        }
    }
}
