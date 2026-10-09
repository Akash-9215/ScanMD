//
//  OCRResultView.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import SwiftUI

/// OCR result sheet displaying recognized text with clipboard copy action and feedback.
struct OCRResultView: View {
    let pages: [ScannedPageModel]
    let pdfURL: URL?
    @Environment(\.dismiss) private var dismiss
    @State private var extractedText: String = ""
    @State private var isExtracting: Bool = false
    @State private var showCopiedToast: Bool = false
    @State private var showMedicalReport: Bool = false
    private let ocrService: OCRServiceProtocol = OCRService()
    
    init(pages: [ScannedPageModel] = [], pdfURL: URL? = nil) {
        self.pages = pages
        self.pdfURL = pdfURL
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: AppSpacing.lg) {
                    if isExtracting {
                        VStack(spacing: AppSpacing.md) {
                            ProgressView()
                                .tint(AppColors.primary)
                            Text(AppStrings.OCR.extracting)
                                .appTypography(AppTypography.subheadline, color: AppColors.textSecondary)
                        }
                        .frame(maxHeight: .infinity)
                    } else if extractedText.isEmpty {
                        ContentUnavailableView(
                            AppStrings.OCR.empty,
                            systemImage: AppIcons.ocr
                        )
                    } else {
                        ScrollView {
                            Text(extractedText)
                                .appTypography(AppTypography.body, color: AppColors.textPrimary)
                                .padding(AppSpacing.lg)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppColors.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        
                        VStack(spacing: AppSpacing.sm) {
                            PrimaryButton(
                                title: AppStrings.Medical.title,
                                iconName: AppIcons.stethoscope,
                                action: { showMedicalReport = true }
                            )
                            
                            PrimaryButton(
                                title: showCopiedToast ? AppStrings.OCR.copied : AppStrings.OCR.copy,
                                iconName: showCopiedToast ? AppIcons.checkmark : AppIcons.copy,
                                action: copyToClipboard
                            )
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.bottom, AppSpacing.lg)
                    }
                }
            }
            .navigationTitle(AppStrings.OCR.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: AppIcons.xmark)
                            .foregroundStyle(AppColors.textPrimary)
                    }
                }
            }
            .sheet(isPresented: $showMedicalReport) {
                MedicalReportView(pages: pages, pdfURL: pdfURL)
            }
            .task {
                await recognizeDocumentText()
            }
        }
    }
    
    private func recognizeDocumentText() async {
        isExtracting = true
        if let pdfURL = pdfURL {
            if let text = try? await ocrService.performOCR(on: pdfURL) {
                self.extractedText = text
            }
        } else if !pages.isEmpty {
            var textResults: [String] = []
            for (index, page) in pages.enumerated() {
                if let text = try? await ocrService.performOCR(on: page.image), !text.isEmpty {
                    textResults.append("--- Page \(index + 1) ---\n\(text)")
                }
            }
            self.extractedText = textResults.joined(separator: "\n\n")
        }
        self.isExtracting = false
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = extractedText
        withAnimation(.spring()) {
            showCopiedToast = true
        }
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation { showCopiedToast = false }
        }
    }
}

#Preview {
    OCRResultView(pages: [])
}
