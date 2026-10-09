//
//  StatBadgeView.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import SwiftUI

/// Reusable metric card badge component presenting numeric statistics and icon indicators.
struct StatBadgeView: View {
    let title: String
    let value: String
    let iconName: String
    let accentGradient: LinearGradient
    
    init(
        title: String,
        value: String,
        iconName: String,
        accentGradient: LinearGradient = AppColors.primaryGradient
    ) {
        self.title = title
        self.value = value
        self.iconName = iconName
        self.accentGradient = accentGradient
    }
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(accentGradient)
                    .frame(width: 42, height: 42)
                
                Image(systemName: iconName)
                    .font(.system(size: AppSize.iconSm, weight: .bold))
                    .foregroundStyle(AppColors.textInverse)
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(value)
                    .appTypography(AppTypography.headline, color: AppColors.textPrimary)
                
                Text(title)
                    .appTypography(AppTypography.caption, color: AppColors.textSecondary)
            }
            
            Spacer()
        }
        .padding(AppSpacing.md)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: AppColors.shadow, radius: AppRadius.sm, x: 0, y: 2)
    }
}

#Preview {
    StatBadgeView(title: "Documents Saved", value: "14 PDFs", iconName: AppIcons.docFill)
        .padding()
}
