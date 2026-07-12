import SwiftUI

struct QuizResultView: View {
    var user: User
    @StateObject var vm = QuizViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Your Hair Health Report")
                .font(.title.bold())
            
            Text("Mild hair fall detected. Maintain good diet & reduce stress.")
            
            Button("Save Report") {
                let answers = [
                    "scalp_type": "Oily",
                    "sleep_hours": "6–8 hours",
                    "hair_fall_frequency": "Sometimes"
                ]
                
                vm.submitQuiz(userId: user.id,
                              answers: answers,
                              resultSummary: "Mild Hair Fall")
            }
            .buttonStyle(.borderedProminent)
            
            Text(vm.message).foregroundColor(.green)
        }
        .padding()
        .navigationTitle("Quiz Result")
    }
}

