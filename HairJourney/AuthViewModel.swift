import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoggedIn = false
    @Published var errorMessage = ""
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "saved_session_user"),
           let savedUser = try? JSONDecoder().decode(User.self, from: data) {
            self.user = savedUser
            self.isLoggedIn = true
        }
    }
    
    func login(email: String, password: String) {
        guard let url = URL(string: APIService.baseURL + "login.php") else { return }
        
        let body = ["email": email, "password": password]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }
                
                if let raw = String(data: data, encoding: .utf8) {
                    print("LOGIN RESPONSE:", raw)
                }
                
                do {
                    let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
                    
                    if decoded.status == "success", let loggedUser = decoded.user {
                        print("LOGIN SUCCESS → Navigating to Dashboard")
                        self.user = loggedUser
                        self.isLoggedIn = true
                        self.errorMessage = ""
                        
                        // Save session
                        if let encoded = try? JSONEncoder().encode(loggedUser) {
                            UserDefaults.standard.set(encoded, forKey: "saved_session_user")
                        }
                        
                        // Sync Core Data specialization for expert
                        if let spec = CoreDataExpertManager.shared.getSpecialization(email: loggedUser.email) {
                            ExpertSpecializationManager.shared.setSpecialization(for: loggedUser.id, specialization: spec)
                        }
                    } else {
                        self.errorMessage = "Invalid credentials"
                    }
                    
                } catch {
                    self.errorMessage = "Decoding failed"
                    print("DECODE ERROR:", error)
                }
            }
        }.resume()
    }
    
    func logout() {
        user = nil
        isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: "saved_session_user")
    }
}

struct LoginResponse: Codable {
    var status: String
    var user: User?
}

