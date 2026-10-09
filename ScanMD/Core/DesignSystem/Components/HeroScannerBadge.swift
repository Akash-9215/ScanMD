//
//  HeroScannerBadge.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import SwiftUI

/// Reusable hero scanner badge component rendering concentric pulsing gradient rings and centered icon.
struct HeroScannerBadge: View {
    @State private var isPulsing: Bool = false
    
    var body: some View {
        ZStack(alignment: .center) {
            // Outer Pulsing Halo Ring
            Circle()
                .stroke(AppColors.accentGradient, lineWidth: 2)
                .frame(width: 96, height: 96)
                .scaleEffect(isPulsing ? 1.18 : 0.95, anchor: .center)
                .opacity(isPulsing ? 0.35 : 0.75)
                .animation(
                    .easeInOut(duration: 2.2).repeatForever(autoreverses: true),
                    value: isPulsing
                )
            
            // Solid Center Gradient Core
            Circle()
                .fill(AppColors.primaryGradient)
                .frame(width: 76, height: 76)
                .shadow(color: AppColors.primary.opacity(0.35), radius: AppSpacing.md, x: 0, y: 6)
            
            // Central Scanner Icon
            Image(systemName: AppIcons.docScanner)
                .font(.system(size: AppSize.iconLg, weight: .bold))
                .foregroundStyle(AppColors.textInverse)
        }
        .frame(width: 120, height: 120, alignment: .center)
        .onAppear {
            isPulsing = true
        }
    }
}

#Preview {
    HeroScannerBadge()
}
