//
//  DashboardRow.swift
//  HairJourney
//
//  Created by Mac-24 on 03/02/26.
//

import SwiftUI

struct DashboardRow: View {
    var icon: String
    var title: String
    var subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 48, height: 48)
                .background(AppTheme.premiumAccentGradient)
                .clipShape(Circle())
                .shadow(color: AppTheme.accent.opacity(0.3), radius: 6, y: 3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline).foregroundColor(AppTheme.titleText)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(AppTheme.bodyText)
            }
            
            Spacer()
            Image(systemName: "chevron.right.circle.fill")
                .font(.title3)
                .foregroundColor(AppTheme.accent.opacity(0.8))
        }
    }
}
