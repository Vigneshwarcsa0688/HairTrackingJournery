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
            AppTheme.gradient.ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.accent))
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    VStack(spacing: 12) {
                        PhotosPicker(selection: $avatarItem, matching: .images) {
                            ZStack {
                                if isUploadingProfilePic {
                                    Circle().fill(AppTheme.premiumAccentGradient).frame(width: 84, height: 84)
                                        .shadow(color: AppTheme.accent.opacity(0.3), radius: 8, y: 4)
                                    ProgressView().tint(.white)
                                } else if let pp = profilePicture, let url = URL(string: APIService.baseURL + pp) {
                                    AsyncImage(url: url) { phase in
                                        if let image = phase.image {
                                            image.resizable().scaledToFill()
                                        } else {
                                            Circle().fill(AppTheme.premiumAccentGradient)
                                            ProgressView().tint(.white)
                                        }
                                    }
                                    .frame(width: 84, height: 84)
                                    .clipShape(Circle())
                                    .shadow(color: AppTheme.accent.opacity(0.3), radius: 8, y: 4)
                                } else {
                                    Circle().fill(AppTheme.premiumAccentGradient).frame(width: 84, height: 84)
                                        .shadow(color: AppTheme.accent.opacity(0.3), radius: 8, y: 4)
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 32)).foregroundColor(.white)
                                }
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
                        .scaleEffect(animate ? 1 : 0.6)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: animate)
                        
                        Text(name.isEmpty ? user.name : name)
                            .font(.title.bold())
                            .foregroundColor(AppTheme.titleText)
                        
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(AppTheme.bodyText(0.7))
                    }
                    
                    GlassCard {
                        VStack(spacing: 16) {
                            profileField(icon: "person.fill", placeholder: "Full Name", text: $name)
                            profileField(icon: "phone.fill", placeholder: "Phone", text: $phone)
                            profileField(icon: "mappin.and.ellipse", placeholder: "Place", text: $place)
                            profileField(icon: "calendar", placeholder: "DOB (yyyy-mm-dd)", text: $dob)
                            
                            Button("Update Profile") {
                                updateProfile()
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                    }
                    
                    GlassCard {
                        VStack(spacing: 14) {
                            // ✅ ABOUT APP BUTTON
                            NavigationLink(destination: AboutView()) {
                                Label("About App", systemImage: "info.circle.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.15))
                                    .foregroundColor(.blue)
                                    .cornerRadius(16)
                            }
                            
                            Button(role: .destructive) {
                                showDeleteConfirm = true
                            } label: {
                                Label("Delete Account", systemImage: "trash.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppTheme.error.opacity(0.15))
                                    .foregroundColor(AppTheme.error)
                                    .cornerRadius(16)
                            }
                            
                            // ✅ UPDATED LOGOUT BUTTON
                            Button {
                                showLogoutConfirm = true
                            } label: {
                                Label("Logout", systemImage: "arrow.backward.circle.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppTheme.accent.opacity(0.15))
                                    .foregroundColor(AppTheme.accent)
                                    .cornerRadius(16)
                            }
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
                .frame(maxWidth: 550)
                .frame(maxWidth: .infinity, alignment: .center)
            }
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
        }
        
        // DELETE CONFIRM
        .confirmationDialog(
            "Are you sure you want to delete your account?",
            isPresented: $showDeleteConfirm
        ) {
            Button("Delete Account", role: .destructive) {
                deleteAccount()
            }
            Button("Cancel", role: .cancel) { }
        }
        
        // ✅ LOGOUT CONFIRM
        .alert("Logout", isPresented: $showLogoutConfirm) {
            Button("Yes", role: .destructive) {
                authVM.logout()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to logout?")
        }
        
        // SUCCESS ALERT
        .alert("Success", isPresented: $showSuccessDialog) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Profile updated successfully")
        }
    }
    
    func profileField(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppTheme.accent)
                .frame(width: 24)
            
            TextField(placeholder, text: text)
                .autocapitalization(.none)
                .foregroundColor(AppTheme.titleText)
        }
        .padding()
        .background(Color.white.opacity(0.45))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.6), lineWidth: 1)
        )
    }
}
