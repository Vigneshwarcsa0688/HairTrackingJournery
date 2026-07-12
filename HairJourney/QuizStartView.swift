//
//  QuizStartView.swift
//  HairJourney
//
//  Created by Mac-24 on 03/02/26.
//

import SwiftUI

struct QuizStartView: View {
    var user: User
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Hair Growth Assessment")
                .font(.title)
                .bold()
            
            Text("Answer a few questions to analyze your hair health.")
                .multilineTextAlignment(.center)
            
            NavigationLink("Start Quiz") {
                QuizQuestionView(user: user)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
