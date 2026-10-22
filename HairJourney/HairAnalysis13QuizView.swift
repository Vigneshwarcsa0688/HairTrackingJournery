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
    
    var categoryTitle: String {
        switch currentQuestion {
        case 0, 9, 11: return "Scalp Condition"
        case 1, 4: return "Lifestyle & Rest"
        case 2, 8: return "Hair Density & Shedding"
        case 3: return "Genetics"
        case 5, 6: return "Nutrition"
        default: return "Hair Care & Styling"
        }
    }
    
    var body: some View {
        ZStack {
            AppBackgroundView()
            
            VStack(spacing: 20) {
                
                // Progress Header
                VStack(spacing: 10) {
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.caption.bold())
                                .foregroundColor(AppTheme.primaryBrand)
                            Text(categoryTitle.uppercased())
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(AppTheme.primaryBrand)
                                .tracking(1)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(AppTheme.primaryBrand.opacity(0.12))
                        .cornerRadius(20)
                        
                        Spacer()
                        
                        Text("Question \(currentQuestion + 1) / 12")
                            .font(.caption.bold())
                            .foregroundColor(AppTheme.bodyText)
                    }
                    .padding(.horizontal)
                    
                    // Custom gradient progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.black.opacity(0.08))
                                .frame(height: 7)
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [AppTheme.primaryBrand, AppTheme.irisPurple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(14, geo.size.width * CGFloat(currentQuestion + 1) / 12.0), height: 7)
                                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentQuestion)
                        }
                    }
                    .frame(height: 7)
                    .padding(.horizontal)
                }
                .padding(.top, 12)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : -15)
                .animation(.easeOut(duration: 0.5), value: animate)
                
                // Main Question & Options Card
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        GlassCard(cornerRadius: 24, padding: 22) {
                            VStack(spacing: 22) {
                                Text(questions[currentQuestion].1)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(AppTheme.titleText)
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, 4)
                                
                                VStack(spacing: 12) {
                                    ForEach(0..<questions[currentQuestion].2.count, id: \.self) { i in
                                        let isSelected = answers[currentQuestion] == i
                                        Button {
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                answers[currentQuestion] = i
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                                                nextQuestion()
                                            }
                                        } label: {
                                            HStack(spacing: 14) {
                                                ZStack {
                                                    Circle()
                                                        .stroke(isSelected ? AppTheme.primaryBrand : Color.black.opacity(0.2), lineWidth: isSelected ? 2 : 1.5)
                                                        .frame(width: 22, height: 22)
                                                    
                                                    if isSelected {
                                                        Circle()
                                                            .fill(AppTheme.primaryBrand)
                                                            .frame(width: 12, height: 12)
                                                    }
                                                }
                                                
                                                Text(questions[currentQuestion].2[i])
                                                    .font(.system(size: 15, weight: isSelected ? .bold : .medium))
                                                    .foregroundColor(isSelected ? AppTheme.primaryDark : AppTheme.titleText)
                                                
                                                Spacer()
                                                
                                                if isSelected {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 12, weight: .bold))
                                                        .foregroundColor(AppTheme.primaryBrand)
                                                }
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 14)
                                            .background(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .fill(isSelected ? AppTheme.primaryBrand.opacity(0.12) : Color.white.opacity(0.65))
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(isSelected ? AppTheme.primaryBrand.opacity(0.4) : Color.black.opacity(0.06), lineWidth: 1)
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        
                        // Back navigation button
                        if currentQuestion > 0 {
                            Button {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    currentQuestion -= 1
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.left")
                                        .font(.caption.bold())
                                    Text("Previous Question")
                                        .font(.subheadline.bold())
                                }
                                .foregroundColor(AppTheme.bodyText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.5))
                                .cornerRadius(20)
                            }
                            .buttonStyle(.plain)
                            .transition(.opacity)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
        }
        .navigationTitle("Hair Assessment")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { animate = true }
        
        // Sheet presentation for report
        .sheet(isPresented: $showReport) {
            HairAnalysisReportView(
                score: answers.filter { $0 >= 0 }.reduce(0, +),
                onFinish: {
                    dismiss()
                }
            )
        }
    }
    
    func nextQuestion() {
        if currentQuestion < questions.count - 1 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                currentQuestion += 1
            }
        } else {
            submitQuiz()
            showReport = true
        }
    }
    
    func submitQuiz() {
        var dict: [String: String] = [:]
        
        for i in 0..<questions.count {
            let key = questions[i].0
            let options = questions[i].2
            
            // Safe index lookup to prevent Index out of range
            if answers.indices.contains(i) {
                let answerIdx = answers[i]
                if options.indices.contains(answerIdx) {
                    dict[key] = options[answerIdx]
                } else {
                    dict[key] = options.first ?? ""
                }
            } else {
                dict[key] = options.first ?? ""
            }
        }
        
        APIService.shared.submitFullQuiz(
            userId: Int(user.id) ?? 0,
            answers: dict,
            result: "Quiz Completed"
        ) { _ in }
    }
}
