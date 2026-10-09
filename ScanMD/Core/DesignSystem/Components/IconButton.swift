//
//  IconButton.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import SwiftUI

/// Reusable glassmorphic icon button with press scale micro-animations.
struct IconButton: View {
    let iconName: String
    let badgeCount: Int?
    let action: () -> Void
    @State private var isPressed: Bool = false
    
    init(iconName: String, badgeCount: Int? = nil, action: @escaping () -> Void) {
        self.iconName = iconName
        self.badgeCount = badgeCount
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(AppColors.glassSurface)
                    .frame(width: AppSize.buttonHeightMd, height: AppSize.buttonHeightMd)
                    .overlay(
                        Circle()
                            .stroke(AppColors.glassGradient, lineWidth: 1)
                    )
                
                Image(systemName: iconName)
                    .font(.system(size: AppSize.iconSm, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                
                if let count = badgeCount, count > 0 {
                    Text("\(count)")
                        .appTypography(AppTypography.caption, color: AppColors.textInverse)
                        .padding(.horizontal, AppSpacing.xs)
                        .padding(.vertical, 2)
                        .background(AppColors.highlight)
                        .clipShape(Capsule())
                        .offset(x: 6, y: -6)
                }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.92 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isPressed)
        ._onButtonGesture { pressing in
            isPressed = pressing
        } perform: {}
    }
}

#Preview {
    IconButton(iconName: AppIcons.camera, badgeCount: 3) {}
}
