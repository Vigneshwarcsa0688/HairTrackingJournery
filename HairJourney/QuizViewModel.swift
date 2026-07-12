import Foundation

class QuizViewModel: ObservableObject {
    @Published var message = ""
    
    struct QuizRequest: Codable {
        let user_id: Int
        let scalp_type: String
        let sleep_hours: String
        let hair_fall_frequency: String
        let result_summary: String
    }
    
    func submitQuiz(userId: String, answers: [String: String], resultSummary: String) {
        guard let url = URL(string: APIService.baseURL + "submit_quiz.php") else { return }
        
        let body = QuizRequest(
            user_id: Int(userId) ?? 0,
            scalp_type: answers["scalp_type"] ?? "",
            sleep_hours: answers["sleep_hours"] ?? "",
            hair_fall_frequency: answers["hair_fall_frequency"] ?? "",
            result_summary: resultSummary
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                self.message = "Quiz Submitted!"
            }
        }.resume()
    }
}

