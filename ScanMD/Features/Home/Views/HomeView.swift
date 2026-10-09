//
//  HomeView.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import SwiftUI

/// Main home view featuring artist-grade glassmorphic visuals, dynamic gradient rings, and animated scanning interactions.
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var pulseRing: Bool = false
    
    var body: some View {
        ZStack {
            // Background mesh gradient glow
            AppColors.background
                .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.xxl) {
                Spacer()
                
                // Animated Hero Scanner Icon with Pulse Ring
                ZStack {
                    Circle()
                        .stroke(AppColors.accentGradient, lineWidth: 2)
                        .frame(width: 130, height: 130)
                        .scaleEffect(pulseRing ? 1.18 : 0.95)
                        .opacity(pulseRing ? 0.35 : 0.75)
                        .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: pulseRing)
                    
                    Circle()
                        .fill(AppColors.primaryGradient)
                        .frame(width: 96, height: 96)
                        .shadow(color: AppColors.primary.opacity(0.4), radius: AppSpacing.lg, x: 0, y: 10)
                    
                    Image(systemName: AppIcons.docScanner)
                        .font(.system(size: AppSize.iconXl, weight: .semibold))
                        .foregroundStyle(AppColors.textInverse)
                }
                .onAppear { pulseRing = true }
                
                // Glassmorphic Card Container
                GlassCard {
                    VStack(spacing: AppSpacing.md) {
                        Text(viewModel.titleText)
                            .appTypography(AppTypography.title, color: AppColors.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text(viewModel.subtitleText)
                            .appTypography(AppTypography.subheadline, color: AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
                
                Spacer()
                
                // Interactive Animated Action Button
                PrimaryButton(
                    title: AppStrings.Scanner.scanDocument,
                    iconName: AppIcons.cameraViewfinder,
                    isLoading: viewModel.isProcessing,
                    action: viewModel.handlePrimaryAction
                )
                .padding(.horizontal, AppSpacing.lg)
                .padding(.bottom, AppSpacing.xl)
            }
        }
        .onAppear(perform: viewModel.onAppear)
    }
}

#Preview {
    HomeView()
}
