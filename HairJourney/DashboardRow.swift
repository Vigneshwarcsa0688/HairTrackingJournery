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
    var iconGradient: LinearGradient = AppTheme.brandGradient
    var badgeText: String? = nil
    var badgeColor: Color = AppTheme.primaryBrand
    
    var body: some View {
        HStack(spacing: 15) {
            // Modern Squircle Icon Container
            ZStack {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(iconGradient)
                    .frame(width: 48, height: 48)
                    .shadow(color: Color.black.opacity(0.10), radius: 6, x: 0, y: 3)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            // Text Titles
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundColor(AppTheme.titleText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    if let badge = badgeText {
                        Text(badge)
                            .font(.system(size: 9, weight: .heavy))
                            .tracking(0.5)
                            .foregroundColor(badgeColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(badgeColor.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(AppTheme.bodyText(0.75))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right.circle.fill")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(AppTheme.primaryBrand.opacity(0.75))
        }
    }
}

