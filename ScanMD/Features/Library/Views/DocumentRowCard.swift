//
//  DocumentRowCard.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import SwiftUI

/// Reusable card component rendering saved PDF document details and quick action buttons.
struct DocumentRowCard: View {
    let document: SavedDocumentModel
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppSpacing.md) {
                // PDF Document Thumbnail Icon Badge
                ZStack {
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .fill(AppColors.primaryGradient)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: AppIcons.docFill)
                        .font(.system(size: AppSize.iconMd))
                        .foregroundStyle(AppColors.textInverse)
                }
                
                // Title and Metadata Details
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(document.title)
                        .appTypography(AppTypography.headline, color: AppColors.textPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: AppSpacing.xs) {
                        Text(document.dateCreated.formatted(date: .abbreviated, time: .shortened))
                        Text("•")
                        Text("\(document.pageCount) Pg")
                        Text("•")
                        Text(document.fileSizeString)
                    }
                    .appTypography(AppTypography.caption, color: AppColors.textSecondary)
                }
                
                Spacer()
                
                // Share Action
                ShareLink(item: document.fileURL) {
                    Image(systemName: AppIcons.share)
                        .font(.system(size: AppSize.iconSm))
                        .foregroundStyle(AppColors.primary)
                }
                .buttonStyle(.plain)
                
                // Delete Action Menu
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: AppIcons.trash)
                        .font(.system(size: AppSize.iconSm))
                        .foregroundStyle(AppColors.error)
                }
                .buttonStyle(.plain)
            }
            .padding(AppSpacing.md)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
            .shadow(color: AppColors.shadow, radius: AppRadius.sm, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let sample = SavedDocumentModel(
        id: UUID(),
        title: "Medical_Report_2026.pdf",
        fileURLPath: "/tmp/sample.pdf",
        dateCreated: Date(),
        pageCount: 3,
        fileSizeString: "1.2 MB"
    )
    DocumentRowCard(document: sample, onTap: {}, onDelete: {})
        .padding()
}
