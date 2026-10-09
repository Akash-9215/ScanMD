//
//  PrimaryButton.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import SwiftUI

/// Futuristic primary action button featuring dual-ring timeline scanner spinner and spring touch states.
struct PrimaryButton: View {
    let title: String
    let iconName: String?
    let isLoading: Bool
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    @State private var shimmerOffset: CGFloat = -150
    @State private var textPulse: Bool = false
    
    init(
        title: String,
        iconName: String? = nil,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.iconName = iconName
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Background Gradient Surface
                RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                    .fill(AppColors.primaryGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )
                    .shadow(color: AppColors.primary.opacity(0.35), radius: isPressed ? AppSpacing.xs : AppSpacing.md, x: 0, y: isPressed ? 2 : 6)
                
                // Continuous Diagonal Light Stripe Sweep
                GeometryReader { proxy in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.clear, .white.opacity(0.15), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 40, height: proxy.size.height * 3.5)
                        .rotationEffect(.degrees(20))
                        .position(x: shimmerOffset, y: proxy.size.height / 2)
                        .onAppear {
                            shimmerOffset = -150
                            withAnimation(.easeInOut(duration: 4.5).repeatForever(autoreverses: false)) {
                                shimmerOffset = proxy.size.width + 150
                            }
                        }
                }
                .mask(RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
                
                // Button Content Layout
                HStack(spacing: AppSpacing.md) {
                    if isLoading {
                        // Timeline-driven Dual Ring Spinner (Always rotates on every click)
                        TimelineView(.animation) { context in
                            let time = context.date.timeIntervalSinceReferenceDate
                            let outerAngle = time.truncatingRemainder(dividingBy: 1.1) / 1.1 * 360
                            let innerAngle = -time.truncatingRemainder(dividingBy: 0.8) / 0.8 * 360
                            
                            ZStack {
                                Circle()
                                    .trim(from: 0.1, to: 0.8)
                                    .stroke(
                                        LinearGradient(colors: [.white, .cyan], startPoint: .top, endPoint: .bottom),
                                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                                    )
                                    .frame(width: 22, height: 22)
                                    .rotationEffect(.degrees(outerAngle))
                                
                                Circle()
                                    .trim(from: 0.2, to: 0.75)
                                    .stroke(
                                        LinearGradient(colors: [.cyan, .white.opacity(0.5)], startPoint: .leading, endPoint: .trailing),
                                        style: StrokeStyle(lineWidth: 2.0, lineCap: .round)
                                    )
                                    .frame(width: 13, height: 13)
                                    .rotationEffect(.degrees(innerAngle))
                                
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 4, height: 4)
                                    .shadow(color: .cyan, radius: 4)
                            }
                        }
                        
                        Text(AppStrings.Scanner.processingDocument)
                            .appTypography(AppTypography.headline, color: AppColors.textInverse)
                            .opacity(textPulse ? 0.75 : 1.0)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                                    textPulse = true
                                }
                            }
                            .transition(.opacity.combined(with: .scale))
                    } else {
                        if let iconName {
                            Image(systemName: iconName)
                                .font(.system(size: AppSize.iconSm + 2, weight: .bold))
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(AppColors.textInverse)
                        }
                        
                        Text(title)
                            .appTypography(AppTypography.headline, color: AppColors.textInverse)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
            .frame(maxWidth: .infinity)
            .frame(height: AppSize.buttonHeightLg)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isPressed)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isLoading)
        }
        .buttonStyle(PrimaryTouchStyle(isPressed: $isPressed))
        .disabled(isLoading)
    }
}

/// Helper button style tracking active touch gesture state
private struct PrimaryTouchStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { newValue in
                isPressed = newValue
            }
    }
}

#Preview("Futuristic Primary Button States") {
    VStack(spacing: AppSpacing.xl) {
        PrimaryButton(
            title: AppStrings.Scanner.scanDocument,
            iconName: AppIcons.cameraViewfinder
        ) {}
        
        PrimaryButton(
            title: AppStrings.Scanner.scanDocument,
            iconName: AppIcons.cameraViewfinder,
            isLoading: true
        ) {}
    }
    .padding()
    .background(AppColors.background)
}
