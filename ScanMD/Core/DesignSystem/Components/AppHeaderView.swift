//
//  AppHeaderView.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import SwiftUI

/// Reusable top navigation header featuring brand logo accent and action slot.
struct AppHeaderView<TrailingContent: View>: View {
    let title: String
    let subtitle: String?
    let trailingView: () -> TrailingContent
    
    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder trailingView: @escaping () -> TrailingContent = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailingView = trailingView
    }
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                HStack(spacing: AppSpacing.xs) {
                    Text(title)
                        .appTypography(AppTypography.title2, color: AppColors.textPrimary)
                    
                    Image(systemName: AppIcons.sparkles)
                        .font(.system(size: AppSize.iconSm))
                        .foregroundStyle(AppColors.primaryAccent)
                }
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .appTypography(AppTypography.caption, color: AppColors.textSecondary)
                }
            }
            
            Spacer()
            
            trailingView()
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
    }
}

#Preview {
    AppHeaderView(title: "ScanMD Pro", subtitle: "Intelligent PDF Suite") {
        Image(systemName: AppIcons.folder)
    }
}
