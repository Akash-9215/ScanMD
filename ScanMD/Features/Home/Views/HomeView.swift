//
//  HomeView.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import SwiftUI

/// Redesigned premium home dashboard featuring scanner hero card, metric counters, and recent scans.
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: AppSpacing.xl) {
                        // Header Bar with Library Action Icon
                        AppHeaderView(
                            title: AppStrings.appName,
                            subtitle: AppStrings.welcomeTitle
                        ) {
                            IconButton(
                                iconName: AppIcons.folder,
                                badgeCount: viewModel.savedCount,
                                action: viewModel.handleLibraryAction
                            )
                        }
                        .padding(.top, AppSpacing.sm)
                        
                        // Hero Document Scanner Card
                        GlassCard {
                            VStack(spacing: AppSpacing.lg) {
                                HeroScannerBadge()
                                
                                VStack(spacing: AppSpacing.xs) {
                                    Text(viewModel.titleText)
                                        .appTypography(AppTypography.title2, color: AppColors.textPrimary)
                                        .multilineTextAlignment(.center)
                                    
                                    Text(viewModel.subtitleText)
                                        .appTypography(AppTypography.subheadline, color: AppColors.textSecondary)
                                        .multilineTextAlignment(.center)
                                }
                                
                                PrimaryButton(
                                    title: AppStrings.Scanner.scanDocument,
                                    iconName: AppIcons.cameraViewfinder,
                                    action: viewModel.handlePrimaryAction
                                )
                            }
                            .frame(maxWidth: .infinity)
                            .padding(AppSpacing.md)
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        
                        // Metric Stat Summary Badge
                        StatBadgeView(
                            title: AppStrings.Home.scansCount,
                            value: "\(viewModel.savedCount) PDF\(viewModel.savedCount == 1 ? "" : "s")",
                            iconName: AppIcons.docFill
                        )
                        .padding(.horizontal, AppSpacing.lg)
                        
                        // Recent Documents Section
                        if !viewModel.recentDocuments.isEmpty {
                            VStack(alignment: .leading, spacing: AppSpacing.md) {
                                HStack {
                                    Text(AppStrings.Home.recentTitle)
                                        .appTypography(AppTypography.headline, color: AppColors.textPrimary)
                                    Spacer()
                                    Button(action: viewModel.handleLibraryAction) {
                                        Text(AppStrings.Library.title)
                                            .appTypography(AppTypography.footnote, color: AppColors.primary)
                                    }
                                }
                                
                                VStack(spacing: AppSpacing.sm) {
                                    ForEach(viewModel.recentDocuments) { doc in
                                        DocumentRowCard(
                                            document: doc,
                                            onTap: { viewModel.selectedRecentDoc = doc },
                                            onDelete: { }
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, AppSpacing.lg)
                        }
                    }
                    .padding(.bottom, AppSpacing.xxl)
                }
            }
            .onAppear(perform: viewModel.loadData)
            .fullScreenCover(isPresented: $viewModel.showScannerSheet) {
                DocumentScannerView()
            }
            .sheet(isPresented: $viewModel.showLibrarySheet) {
                DocumentLibraryView()
            }
            .fullScreenCover(item: $viewModel.selectedRecentDoc) { doc in
                let scannedDoc = ScannedDocumentModel(
                    title: doc.title,
                    pages: [],
                    pdfURL: doc.fileURL
                )
                PDFPreviewView(document: scannedDoc)
            }
        }
    }
}

#Preview {
    HomeView()
}
