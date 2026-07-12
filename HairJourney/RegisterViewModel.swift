import Foundation

class RegisterViewModel: ObservableObject {
    @Published var message = ""
    
    func register(name: String, email: String, phone: String, place: String, dob: String, role: String, password: String) {
        guard let url = URL(string: APIService.baseURL + "register.php") else { return }
        
        let body: [String: String] = [
            "name": name,
            "email": email,
            "phone": phone,
            "place": place,
            "dob": dob,
            "role": role,
            "password": password
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                self.message = "Registration Completed"
            }
        }.resume()
    }
}

