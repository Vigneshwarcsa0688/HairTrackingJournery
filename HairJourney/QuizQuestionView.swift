//
//  QuizQuestionView.swift
//  HairJourney
//
//  Created by Mac-24 on 03/02/26.
//

import SwiftUI

struct QuizQuestionView: View {
    var user: User
    @State private var selectedAnswer = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How would you describe your scalp?")
                .font(.headline)
            
            ForEach(["Oily", "Dry", "Normal", "Itchy/Flaky"], id: \.self) { option in
                Button(option) {
                    selectedAnswer = option
                }
                .buttonStyle(.bordered)
            }
            
            NavigationLink("Submit Quiz") {
                QuizResultView(user: user)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
