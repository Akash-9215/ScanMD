//
//  DocumentScannerView.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import SwiftUI

/// Clean full-screen document scanner view with camera representable and controls.
struct DocumentScannerView: View {
    @StateObject private var viewModel = DocumentScannerViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var flashEnabled: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if viewModel.isCameraSupported {
                VNDocumentCameraRepresentable(
                    onFinish: viewModel.handleCapturedImages,
                    onCancel: { dismiss() },
                    onError: { error in
                        viewModel.errorMessage = error.localizedDescription
                    }
                )
                .ignoresSafeArea()
            } else {
                // Simulator Full-Screen Interactive Viewfinder UI
                VStack(spacing: AppSpacing.zero) {
                    // Top Bar
                    HStack {
                        IconButton(iconName: AppIcons.xmark) { dismiss() }
                        Spacer()
                        Text(AppStrings.Scanner.modeAuto)
                            .appTypography(AppTypography.caption, color: AppColors.primaryAccent)
                            .padding(.vertical, AppSpacing.xs)
                            .padding(.horizontal, AppSpacing.md)
                            .background(AppColors.glassSurface)
                            .clipShape(Capsule())
                        Spacer()
                        IconButton(iconName: flashEnabled ? AppIcons.flashOn : AppIcons.flashOff) {
                            flashEnabled.toggle()
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.xl)
                    
                    Spacer()
                    
                    // Central Camera Container Placeholder
                    VStack(spacing: AppSpacing.md) {
                        Image(systemName: AppIcons.docScanner)
                            .font(.system(size: AppSize.iconXl * 1.5))
                            .foregroundStyle(AppColors.primaryAccent)
                        
                        Text(AppStrings.Scanner.cameraUnsupported)
                            .appTypography(AppTypography.subheadline, color: AppColors.textInverse)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppSpacing.xl)
                    }
                    
                    Spacer()
                    
                    // Bottom Controls Bar
                    GlassCard {
                        HStack(spacing: AppSpacing.lg) {
                            // Page Counter Badge
                            VStack(spacing: AppSpacing.xxs) {
                                Text("\(viewModel.pages.count)")
                                    .appTypography(AppTypography.headline, color: AppColors.textPrimary)
                                Text(AppStrings.Scanner.pagesCaptured)
                                    .appTypography(AppTypography.caption, color: AppColors.textSecondary)
                            }
                            
                            Spacer()
                            
                            // Shutter Trigger Button
                            Button(action: viewModel.generateDemoScan) {
                                ZStack {
                                    Circle()
                                        .stroke(AppColors.primaryGradient, lineWidth: 4)
                                        .frame(width: 72, height: 72)
                                    
                                    Circle()
                                        .fill(AppColors.primaryGradient)
                                        .frame(width: 58, height: 58)
                                    
                                    Image(systemName: AppIcons.cameraViewfinder)
                                        .font(.system(size: AppSize.iconMd))
                                        .foregroundStyle(AppColors.textInverse)
                                }
                            }
                            .buttonStyle(.plain)
                            
                            Spacer()
                            
                            // Done PDF Render Button
                            if !viewModel.pages.isEmpty {
                                Button(action: viewModel.generatePDFDocument) {
                                    Image(systemName: AppIcons.checkmark)
                                        .font(.system(size: AppSize.iconMd))
                                        .foregroundStyle(AppColors.textInverse)
                                        .padding(AppSpacing.md)
                                        .background(AppColors.success)
                                        .clipShape(Circle())
                                }
                            } else {
                                Color.clear.frame(width: 44, height: 44)
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.xl)
                }
            }
        }
        .fullScreenCover(isPresented: $viewModel.showPDFPreview) {
            if let doc = viewModel.generatedDocument {
                PDFPreviewView(document: doc, onDone: { dismiss() })
            }
        }
    }
}

private extension AppSpacing {
    static let zero: CGFloat = 0
}

#Preview {
    DocumentScannerView()
}
