//
//  ModernCard.swift
//  HairJourney
//
//  Created by Mac-24 on 03/02/26.
//

import SwiftUI

struct ModernCard<Content: View>: View {
    var content: () -> Content
    
    var body: some View {
        content()
            .padding()
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 8)
    }
}
