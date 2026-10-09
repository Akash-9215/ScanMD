//
//  GlassCard.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import SwiftUI

/// Reusable glassmorphic card container providing artistic backdrop blur, border highlights, and depth.
struct GlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(AppSpacing.xl)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                    .stroke(AppColors.glassSurface, lineWidth: 1)
            )
            .shadow(color: AppColors.shadow, radius: AppSpacing.md, x: 0, y: 8)
    }
}

#Preview {
    ZStack {
        AppColors.primaryGradient
            .ignoresSafeArea()
        
        GlassCard {
            VStack(spacing: AppSpacing.sm) {
                Text(AppStrings.appName)
                    .appTypography(AppTypography.title, color: AppColors.textInverse)
                Text(AppStrings.welcomeSubtitle)
                    .appTypography(AppTypography.subheadline, color: AppColors.textInverse.opacity(0.8))
            }
        }
        .padding()
    }
}
