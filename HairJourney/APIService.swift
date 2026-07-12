import Foundation

struct APIService {
    
    // ⚠️ If testing on REAL phone, replace localhost with your Mac IP
    static let baseURL = "http://14.139.187.229:8081/oct/spic_726/hairjourney/"
    //APIURL: http://14.139.187.229:8081/oct/spic_726/hairjourney/
    static let shared = APIService()
    
    // MARK: - Submit Full 13 Question Quiz
    func submitFullQuiz(userId: Int,
                        answers: [String: String],
                        result: String,
                        completion: @escaping (Bool) -> Void) {
        
        guard let url = URL(string: APIService.baseURL + "submit_quiz.php") else {
            completion(false)
            return
        }
        
        var body = answers
        body["user_id"] = "\(userId)"
        body["result_summary"] = result
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("❌ Quiz submit error:", error.localizedDescription)
                        completion(false)
                        return
                    }
                    
                    guard let data = data else {
                        completion(false)
                        return
                    }
                    
                    if let result = String(data: data, encoding: .utf8) {
                        print("✅ Quiz submit response:", result)
                    }
                    
                    completion(true)
                }
            }.resume()
            
        } catch {
            print("❌ JSON encoding error:", error)
            completion(false)
        }
    }
}

