import SwiftUI
import PhotosUI

struct ProfileResponse: Codable {
    let status: String
    let user: ProfileUser?
}

struct ProfileUser: Codable {
    let id: String?
    let name: String?
    let email: String?
    let phone: String?
    let place: String?
    let dob: String?
    let role: String?
    let profile_picture: String?
}

struct ProfileView: View {
    
    var user: User
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @State private var name = ""
    @State private var phone = ""
    @State private var place = ""
    @State private var dob = ""
    @State private var profilePicture: String? = nil
    @State private var message = ""
    @State private var animate = false
    @State private var showDeleteConfirm = false
    @State private var isLoading = false
    @State private var avatarItem: PhotosPickerItem?
    @State private var isUploadingProfilePic = false
    
    @State private var showSuccessDialog = false
    
    // ✅ NEW: Logout dialog + navigation
    @State private var showLogoutConfirm = false
    
    @ObservedObject private var langManager = AppLanguageManager.shared
    @ObservedObject private var specManager = ExpertSpecializationManager.shared
    @State private var showLanguageSheet = false
    @State private var selectedSpecialization: String = ""
    @State private var selectedLanguages: [String] = []
    @State private var memberPreferredLang: String = ""
    
    struct UpdateRequest: Codable {
        let id: Int
        let name: String
        let phone: String
        let place: String
        let dob: String
    }
    
    func getUserIdAsInt() -> Int? {
        if let intId = user.id as? Int {
            return intId
        } else if let stringId = user.id as? String, let intId = Int(stringId) {
            return intId
        } else if let intId = user.id as? Int64 {
            return Int(intId)
        }
        return nil
    }
    
    func fetchProfile() {
        isLoading = true
        
        guard let userId = getUserIdAsInt() else {
            DispatchQueue.main.async {
                message = "❌ Invalid user ID format"
                isLoading = false
            }
            return
        }
        
        guard let url = URL(string: APIService.baseURL + "get_profile.php?user_id=\(userId)") else {
            isLoading = false
            message = "❌ Invalid URL"
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            
            DispatchQueue.main.async {
                isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    message = "❌ Network error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    message = "❌ No data received"
                }
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(ProfileResponse.self, from: data)
                
                DispatchQueue.main.async {
                    if decoded.status == "success", let u = decoded.user {
                        name = u.name ?? ""
                        phone = u.phone ?? ""
                        place = u.place ?? ""
                        dob = u.dob ?? ""
                        profilePicture = u.profile_picture
                        message = ""
                    } else {
                        message = "❌ Failed to load profile"
                    }
                }
                
            } catch {
                DispatchQueue.main.async {
                    message = "❌ Error parsing profile data"
                }
            }
            
        }.resume()
    }
    
    func updateProfile() {
        guard let userId = getUserIdAsInt() else {
            message = "❌ Invalid user ID format"
            return
        }
        
        guard let url = URL(string: APIService.baseURL + "update_profile.php") else {
            message = "❌ Invalid URL"
            return
        }
        
        let body = UpdateRequest(
            id: userId,
            name: name,
            phone: phone,
            place: place,
            dob: dob
        )
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: req) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    message = "❌ Update failed: \(error.localizedDescription)"
                    return
                }
                
                showSuccessDialog = true
                fetchProfile()
            }
        }.resume()
    }
    
    func uploadProfilePicture(data: Data) {
        guard let userId = getUserIdAsInt() else { return }
        guard let url = URL(string: APIService.baseURL + "upload_profile_picture.php") else { return }
        
        isUploadingProfilePic = true
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"user_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(userId)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"profile_picture\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { d, _, e in
            DispatchQueue.main.async {
                isUploadingProfilePic = false
                if let d = d, let json = try? JSONSerialization.jsonObject(with: d) as? [String: Any], json["status"] as? String == "success" {
                    fetchProfile() // Refresh to get the new image URL
                } else {
                    message = "❌ Failed to upload picture"
                }
            }
        }.resume()
    }
    
    func deleteAccount() {
        guard let userId = getUserIdAsInt() else { return }
        
        guard let url = URL(string: APIService.baseURL + "delete_account.php?id=\(userId)") else { return }
        
        URLSession.shared.dataTask(with: url) { _, _, _ in
            DispatchQueue.main.async {
                authVM.logout()
            }
        }.resume()
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            if isLoading {
                ProgressView()
                    .scaleEffect(1.3)
                    .tint(AppTheme.primaryBrand)
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // MARK: - Avatar & Identity Header
                    VStack(spacing: 12) {
                        PhotosPicker(selection: $avatarItem, matching: .images) {
                            ZStack(alignment: .bottomTrailing) {
                                if isUploadingProfilePic {
                                    Circle().fill(AppTheme.brandGradient).frame(width: 90, height: 90)
                                        .shadow(color: AppTheme.primaryBrand.opacity(0.35), radius: 8, y: 4)
                                    ProgressView().tint(.white)
                                } else if let pp = profilePicture, let url = URL(string: APIService.baseURL + pp) {
                                    CachedAsyncImage(url: url) { phase in
                                        if let image = phase.image {
                                            image.resizable().scaledToFill()
                                        } else {
                                            Circle().fill(AppTheme.brandGradient)
                                            ProgressView().tint(.white)
                                        }
                                    }
                                    .frame(width: 90, height: 90)
                                    .clipShape(Circle())
                                    .shadow(color: AppTheme.primaryBrand.opacity(0.25), radius: 8, y: 4)
                                } else {
                                    Circle().fill(AppTheme.brandGradient).frame(width: 90, height: 90)
                                        .shadow(color: AppTheme.primaryBrand.opacity(0.35), radius: 8, y: 4)
                                    Text(name.isEmpty ? user.name.prefix(1).uppercased() : name.prefix(1).uppercased())
                                        .font(.system(size: 34, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                // Camera Edit Badge
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 28, height: 28)
                                        .shadow(color: Color.black.opacity(0.12), radius: 4, y: 2)
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(AppTheme.primaryBrand)
                                }
                                .offset(x: 2, y: 2)
                            }
                        }
                        .disabled(isUploadingProfilePic)
                        .onChange(of: avatarItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data),
                                   let jpegData = uiImage.jpegData(compressionQuality: 0.8) {
                                    uploadProfilePicture(data: jpegData)
                                }
                            }
                        }
                        .scaleEffect(animate ? 1 : 0.7)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animate)
                        
                        VStack(spacing: 4) {
                            Text(name.isEmpty ? user.name : name)
                                .font(.title2.weight(.bold))
                                .foregroundColor(AppTheme.titleText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
                            HStack(spacing: 6) {
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.bodyText(0.75))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                
                                Text(user.role.uppercased())
                                    .font(.system(size: 9, weight: .heavy))
                                    .tracking(0.6)
                                    .foregroundColor(AppTheme.primaryBrand)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(AppTheme.primaryBrand.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.top, 10)
                    
                    // MARK: - Personal Information Form
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeaderView(title: "Personal Information", subtitle: "Account", icon: "person.text.rectangle")
                        
                        GlassCard(cornerRadius: 22, paddingAmount: 18) {
                            VStack(spacing: 14) {
                                profileField(icon: "person.fill", placeholder: "Full Name", text: $name)
                                profileField(icon: "phone.fill", placeholder: "Phone Number", text: $phone)
                                profileField(icon: "mappin.and.ellipse", placeholder: "City / Place", text: $place)
                                profileField(icon: "calendar", placeholder: "Birth Date (yyyy-mm-dd)", text: $dob)
                                
                                Button {
                                    updateProfile()
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("Save Changes")
                                    }
                                }
                                .buttonStyle(PrimaryButtonStyle(height: 48))
                                .padding(.top, 4)
                            }
                        }
                    }
                    
                    // MARK: - Language & Specialization Preferences
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeaderView(
                            title: user.role.lowercased() == "doctor" ? langManager.text("specialization_and_languages") : langManager.text("language_preferences"),
                            subtitle: langManager.text("preferences"),
                            icon: "globe.americas.fill"
                        )
                        
                        GlassCard(cornerRadius: 22, paddingAmount: 16) {
                            VStack(spacing: 16) {
                                
                                // App Display Language
                                Button(action: {
                                    showLanguageSheet = true
                                }) {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(AppTheme.primaryBrand.opacity(0.12))
                                                .frame(width: 40, height: 40)
                                            Text(langManager.currentLanguage.flag)
                                                .font(.system(size: 20))
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(langManager.text("app_language"))
                                                .font(.subheadline.weight(.bold))
                                                .foregroundColor(AppTheme.titleText)
                                            Text(langManager.currentLanguage.displayName)
                                                .font(.caption)
                                                .foregroundColor(AppTheme.emeraldMint)
                                        }
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 4) {
                                            Text(langManager.text("change"))
                                                .font(.caption.bold())
                                                .foregroundColor(AppTheme.primaryBrand)
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(AppTheme.bodyText(0.4))
                                        }
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                if user.role.lowercased() == "doctor" {
                                    Divider().opacity(0.4)
                                    
                                    // Expert Clinical Specialization Picker
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(langManager.text("clinical_specialization").uppercased())
                                                .font(.system(size: 11, weight: .heavy))
                                                .tracking(1.0)
                                                .foregroundColor(AppTheme.primaryBrand)
                                            Spacer()
                                        }
                                        
                                        Menu {
                                            ForEach(ExpertSpecializationManager.availableSpecializations, id: \.self) { spec in
                                                Button(action: {
                                                    selectedSpecialization = spec
                                                    specManager.setSpecialization(for: user.id, specialization: spec)
                                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                                }) {
                                                    HStack {
                                                        Text(spec)
                                                        if selectedSpecialization == spec {
                                                            Image(systemName: "checkmark")
                                                        }
                                                    }
                                                }
                                            }
                                        } label: {
                                            HStack {
                                                Image(systemName: "cross.case.fill")
                                                    .foregroundColor(AppTheme.emeraldMint)
                                                    .font(.system(size: 14))
                                                Text(selectedSpecialization.isEmpty ? "Select Specialization" : selectedSpecialization)
                                                    .font(.subheadline.weight(.semibold))
                                                    .foregroundColor(AppTheme.titleText)
                                                Spacer()
                                                Image(systemName: "chevron.up.chevron.down")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(AppTheme.bodyText(0.5))
                                            }
                                            .padding(12)
                                            .background(Color.white.opacity(0.5))
                                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // MARK: - Legal, App Store Policies & About
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeaderView(title: "Legal & Information", subtitle: "Compliance", icon: "doc.text.fill")
                        
                        GlassCard(cornerRadius: 20, paddingAmount: 10) {
                            VStack(spacing: 0) {
                                NavigationLink(destination: PrivacyPolicyView()) {
                                    profileLinkRow(icon: "hand.raised.fill", title: "Privacy Policy", color: AppTheme.primaryBrand)
                                }
                                
                                Divider().padding(.leading, 46).opacity(0.5)
                                
                                NavigationLink(destination: TermsView()) {
                                    profileLinkRow(icon: "doc.plaintext.fill", title: "Terms & Conditions", color: AppTheme.irisPurple)
                                }
                                
                                Divider().padding(.leading, 46).opacity(0.5)
                                
                                NavigationLink(destination: AboutView()) {
                                    profileLinkRow(icon: "info.circle.fill", title: "About HairJourney", color: .blue)
                                }
                            }
                        }
                    }
                    
                    // MARK: - Account Actions (Logout & Delete)
                    VStack(alignment: .leading, spacing: 10) {
                        SectionHeaderView(title: "Account Security", subtitle: "Session", icon: "lock.shield.fill")
                        
                        GlassCard(cornerRadius: 20, paddingAmount: 14) {
                            VStack(spacing: 12) {
                                // Logout Button
                                Button {
                                    showLogoutConfirm = true
                                } label: {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(AppTheme.primaryBrand.opacity(0.12))
                                                .frame(width: 36, height: 36)
                                            Image(systemName: "arrow.backward.circle.fill")
                                                .foregroundColor(AppTheme.primaryBrand)
                                        }
                                        Text("Log Out")
                                            .font(.subheadline.bold())
                                            .foregroundColor(AppTheme.primaryBrand)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(AppTheme.bodyText(0.4))
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 4)
                                }
                                
                                Divider().opacity(0.5)
                                
                                // Delete Account Button
                                Button(role: .destructive) {
                                    showDeleteConfirm = true
                                } label: {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(AppTheme.coralRose.opacity(0.12))
                                                .frame(width: 36, height: 36)
                                            Image(systemName: "trash.fill")
                                                .foregroundColor(AppTheme.coralRose)
                                        }
                                        Text("Delete Account")
                                            .font(.subheadline.bold())
                                            .foregroundColor(AppTheme.coralRose)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(AppTheme.bodyText(0.4))
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: AppTheme.maxContentWidth(sizeClass))
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Profile")
                    .font(.headline.bold())
                    .foregroundColor(AppTheme.titleText)
            }
        }
        .onAppear {
            animate = true
            fetchProfile()
            selectedSpecialization = specManager.getSpecialization(for: user.id)
            selectedLanguages = specManager.getLanguages(for: user.id)
            memberPreferredLang = specManager.getMemberPreferredLanguage(for: user.id)
        }
        .sheet(isPresented: $showLanguageSheet) {
            LanguagePickerSheet()
                .presentationDetents([.medium, .large])
        }
        
        // DELETE CONFIRM
        .confirmationDialog(
            "Are you sure you want to permanently delete your account?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete My Account", role: .destructive) {
                deleteAccount()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone. All your progress photos, assessment history, and logs will be permanently erased.")
        }
        
        // LOGOUT CONFIRM
        .alert("Logout", isPresented: $showLogoutConfirm) {
            Button("Yes, Logout", role: .destructive) {
                authVM.logout()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to log out of your session?")
        }
        
        // SUCCESS ALERT
        .alert("Success", isPresented: $showSuccessDialog) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your profile has been successfully updated.")
        }
    }
    
    @ViewBuilder
    private func profileLinkRow(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(color.opacity(0.12))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(AppTheme.titleText)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(AppTheme.bodyText(0.4))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
    }
    
    func profileField(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.primaryBrand.opacity(0.1))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.primaryBrand)
            }
            
            TextField(placeholder, text: text)
                .autocapitalization(.none)
                .foregroundColor(AppTheme.titleText)
                .font(.subheadline)
        }
        .padding(10)
        .background(Color.white.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white, lineWidth: 1)
        )
    }
}
