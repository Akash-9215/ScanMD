//
//  MedicalReportView.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import SwiftUI

/// Full-screen medical analysis view rendering document verification status, patient metadata, structured test tables, and pathologist clinical insights.
struct MedicalReportView: View {
    let pages: [ScannedPageModel]
    let pdfURL: URL?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = MedicalAnalysisViewModel()
    
    init(pages: [ScannedPageModel] = [], pdfURL: URL? = nil) {
        self.pages = pages
        self.pdfURL = pdfURL
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                if viewModel.isAnalyzing {
                    analysisLoadingView
                } else if let report = viewModel.report {
                    ScrollView {
                        VStack(spacing: AppSpacing.lg) {
                            verificationHeaderCard(report: report)
                            if report.isMedicalReport {
                                patientMetadataCard(report: report)
                                testResultsSection(report: report)
                                pathologistAssessmentCard(report: report)
                            } else {
                                nonMedicalView
                            }
                        }
                        .padding(AppSpacing.md)
                    }
                }
            }
            .navigationTitle(AppStrings.Medical.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: AppIcons.xmark)
                            .foregroundStyle(AppColors.textPrimary)
                    }
                }
            }
            .task {
                viewModel.analyzeDocument(pages: pages, pdfURL: pdfURL)
            }
        }
    }
    
    private var analysisLoadingView: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .tint(AppColors.primary)
                .scaleEffect(1.2)
            Text(AppStrings.Medical.analyzing)
                .appTypography(AppTypography.subheadline, color: AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppSpacing.xl)
    }
    
    private func verificationHeaderCard(report: MedicalReportModel) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: report.isMedicalReport ? AppIcons.checkmarkShield : AppIcons.alertTriangle)
                .font(.system(size: AppSize.iconLg))
                .foregroundStyle(report.isMedicalReport ? AppColors.success : AppColors.warning)
            
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(report.isMedicalReport ? AppStrings.Medical.verified : AppStrings.Medical.unverified)
                    .appTypography(AppTypography.headline, color: AppColors.textPrimary)
                Text(report.reportType)
                    .appTypography(AppTypography.caption, color: AppColors.textSecondary)
            }
            Spacer()
        }
        .padding(AppSpacing.md)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }
    
    private func patientMetadataCard(report: MedicalReportModel) -> some View {
        VStack(spacing: AppSpacing.xs) {
            metadataRow(icon: AppIcons.docText, label: AppStrings.Medical.patientName, value: "\(report.patientName) (\(report.patientAge))")
            Divider().background(AppColors.glassSurface)
            metadataRow(icon: AppIcons.crossCase, label: AppStrings.Medical.facility, value: report.hospitalName)
            Divider().background(AppColors.glassSurface)
            metadataRow(icon: AppIcons.stethoscope, label: AppStrings.Medical.doctor, value: report.doctorName)
            Divider().background(AppColors.glassSurface)
            metadataRow(icon: AppIcons.heartPulse, label: AppStrings.Medical.date, value: report.reportDate)
        }
        .padding(AppSpacing.md)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }
    
    private func metadataRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(AppColors.primary)
                .frame(width: AppSize.iconSm)
            Text(label)
                .appTypography(AppTypography.caption, color: AppColors.textSecondary)
            Spacer()
            Text(value)
                .appTypography(AppTypography.subheadline, color: AppColors.textPrimary)
                .bold()
        }
    }
    
    private func testResultsSection(report: MedicalReportModel) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(AppStrings.Medical.labResults)
                .appTypography(AppTypography.headline, color: AppColors.textPrimary)
            MedicalTestTable(testItems: report.testItems)
        }
    }
    
    private func pathologistAssessmentCard(report: MedicalReportModel) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: AppIcons.sparkles)
                    .foregroundStyle(AppColors.primary)
                Text(AppStrings.Medical.pathologistSummary)
                    .appTypography(AppTypography.headline, color: AppColors.textPrimary)
            }
            Text(report.diagnosticSummary)
                .appTypography(AppTypography.body, color: AppColors.textSecondary)
            
            if !report.flaggedAbnormalities.isEmpty {
                Text(AppStrings.Medical.flaggedTitle)
                    .appTypography(AppTypography.subheadline, color: AppColors.error)
                    .bold()
                ForEach(report.flaggedAbnormalities, id: \.self) { flagged in
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: AppIcons.alertTriangle)
                            .foregroundStyle(AppColors.error)
                        Text(flagged)
                            .appTypography(AppTypography.caption, color: AppColors.error)
                    }
                }
            }
            
            Divider().background(AppColors.glassSurface)
            
            Text(AppStrings.Medical.recommendations)
                .appTypography(AppTypography.subheadline, color: AppColors.primary)
                .bold()
            ForEach(report.recommendedActions, id: \.self) { rec in
                Text("• \(rec)")
                    .appTypography(AppTypography.caption, color: AppColors.textPrimary)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }
    
    private var nonMedicalView: some View {
        VStack(spacing: AppSpacing.md) {
            Text(AppStrings.Medical.nonMedicalMsg)
                .appTypography(AppTypography.body, color: AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppSpacing.lg)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }
}

#Preview {
    MedicalReportView()
}
