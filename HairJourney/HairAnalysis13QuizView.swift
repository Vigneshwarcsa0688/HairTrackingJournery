import SwiftUI

struct HairAnalysis13QuizView: View {
    var user: User
    @Environment(\.dismiss) var dismiss   // ✅ ADDED
    
    @State private var currentQuestion = 0
    @State private var answers: [Int] = Array(repeating: -1, count: 12)
    @State private var showReport = false
    @State private var animate = false
    
    let questions = [
        ("scalp_type","How would you describe your scalp?",["Oily","Dry","Normal","Itchy/Flaky"]),
        ("sleep_hours","How many hours do you sleep per night?",["8+ hours","6–8 hours","4–6 hours","<4 hours"]),
        ("hair_fall_frequency","How often do you notice hair fall?",["Rarely","Sometimes","Frequently","Severe daily shedding"]),
        ("family_history","Family history of hair loss?",["No","Maybe","One side","Both parents"]),
        ("stress_level","Stress level?",["Rarely","Occasionally","Often","Constantly"]),
        ("diet","Balanced diet?",["Yes","Partially","Rarely","No"]),
        ("deficiencies","Nutritional deficiencies?",["None","Iron deficiency","Vitamin D deficiency","Multiple"]),
        ("hair_texture","Hair texture?",["Fine","Medium","Thick","Coarse"]),
        ("sudden_thinning","Sudden thinning?",["No","Mild","Moderate","Severe"]),
        ("dandruff","Dandruff or itching?",["Never","Sometimes","Often","Always"]),
        ("styling_tools","Styling tools usage?",["Rarely","Sometimes","Often","Daily"]),
        ("scalp_pain","Scalp pain?",["No","Slightly","Moderate","Severe"])
    ]
    
    var body: some View {
        ZStack {
            AppTheme.gradient.ignoresSafeArea()
            
            VStack(spacing: 24) {
                
                VStack(spacing: 8) {
                    Text("Hair Health Assessment")
                        .font(.title.bold())
                        .foregroundColor(AppTheme.titleText)

                    Text("Question \(currentQuestion + 1) of 12")
                        .foregroundColor(AppTheme.bodyText)
                        .font(.subheadline)
                    
                    ProgressView(value: Double(currentQuestion + 1), total: 12)
                        .tint(.white)
                        .padding(.horizontal)
                }
                .padding(.top)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : -20)
                .animation(.easeOut(duration: 0.6), value: animate)
                
                GlassCard {
                    VStack(spacing: 20) {
                        Text(questions[currentQuestion].1)
                            .font(.title3.bold())
                            .multilineTextAlignment(.center)
                            .foregroundColor(AppTheme.titleText)

                        VStack(spacing: 14) {
                            ForEach(0..<questions[currentQuestion].2.count, id: \.self) { i in
                                Button {
                                    answers[currentQuestion] = i
                                    nextQuestion()
                                } label: {
                                    Text(questions[currentQuestion].2[i])
                                        .font(.subheadline.bold())
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(
                                            answers[currentQuestion] == i
                                            ? Color.white.opacity(0.3)
                                            : Color.white.opacity(0.12)
                                        )
                                        .foregroundColor(AppTheme.titleText)
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : 30)
                .animation(.easeOut(duration: 0.7), value: animate)
                
                Spacer()
            }
            .padding(.bottom)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { animate = true }
        
        // ✅ UPDATED SHEET
        .sheet(isPresented: $showReport) {
            HairAnalysisReportView(
                score: answers.reduce(0, +),
                onFinish: {
                    dismiss() // ✅ THIS TAKES USER TO DASHBOARD
                }
            )
        }
    }
    
    func nextQuestion() {
        if currentQuestion < questions.count - 1 {
            currentQuestion += 1
        } else {
            submitQuiz()
            showReport = true
        }
    }
    
    func submitQuiz() {
        var dict: [String: String] = [:]
        
        for i in 0..<questions.count {
            let key = questions[i].0
            let value = questions[i].2[answers[i]]
            dict[key] = value
        }
        
        APIService.shared.submitFullQuiz(
            userId: Int(user.id) ?? 0,
            answers: dict,
            result: "Quiz Completed"
        ) { _ in }
    }
}
