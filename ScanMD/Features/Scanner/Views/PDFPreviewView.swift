//
//  PDFPreviewView.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import SwiftUI

/// Full-screen document preview screen displaying rendered PDF, OCR engine, and Save/Share options.
struct PDFPreviewView: View {
    let document: ScannedDocumentModel
    let onDone: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State private var showOCRSheet: Bool = false
    @State private var showMedicalSheet: Bool = false
    @State private var isSaved: Bool = false
    @State private var showSaveToast: Bool = false
    
    init(document: ScannedDocumentModel, onDone: (() -> Void)? = nil) {
        self.document = document
        self.onDone = onDone
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: AppSpacing.zero) {
                    if let pdfURL = document.pdfURL {
                        PDFKitViewRepresentable(url: pdfURL)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.vertical, AppSpacing.sm)
                    } else {
                        ContentUnavailableView(
                            AppStrings.PDF.generating,
                            systemImage: AppIcons.docText
                        )
                    }
                }
                
                if showSaveToast {
                    VStack {
                        Spacer()
                        HStack(spacing: AppSpacing.sm) {
                            Image(systemName: AppIcons.checkmark)
                               .foregroundStyle(AppColors.success)
                            Text(AppStrings.PDF.savedSuccess)
                                .appTypography(AppTypography.subheadline, color: AppColors.textInverse)
                        }
                        .padding(.vertical, AppSpacing.md)
                        .padding(.horizontal, AppSpacing.lg)
                        .background(AppColors.primaryGradient)
                        .clipShape(Capsule())
                        .shadow(color: AppColors.shadow, radius: AppRadius.md)
                        .padding(.bottom, AppSpacing.xl)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle(document.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: handleCloseAction) {
                        Image(systemName: AppIcons.xmark)
                            .foregroundStyle(AppColors.textPrimary)
                    }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: { showMedicalSheet = true }) {
                        Image(systemName: AppIcons.stethoscope)
                            .foregroundStyle(AppColors.primary)
                    }
                    
                    Button(action: { showOCRSheet = true }) {
                        Image(systemName: AppIcons.ocr)
                            .foregroundStyle(AppColors.primary)
                    }
                    
                    if isSaved {
                        HStack(spacing: AppSpacing.xxs) {
                            Image(systemName: AppIcons.checkmark)
                                .font(.system(size: AppSize.iconSm))
                                .foregroundStyle(AppColors.success)
                        }
                    } else {
                        Button(action: saveDocumentToLibrary) {
                            Image(systemName: AppIcons.save)
                                .foregroundStyle(AppColors.primary)
                        }
                    }
                    
                    if let pdfURL = document.pdfURL {
                        ShareLink(item: pdfURL) {
                            Image(systemName: AppIcons.share)
                                .foregroundStyle(AppColors.primary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showOCRSheet) {
                OCRResultView(pages: document.pages, pdfURL: document.pdfURL)
            }
            .sheet(isPresented: $showMedicalSheet) {
                MedicalReportView(pages: document.pages, pdfURL: document.pdfURL)
            }
            .onAppear(perform: checkIfAlreadySaved)
        }
    }
    
    private func checkIfAlreadySaved() {
        guard let url = document.pdfURL else { return }
        let allSaved = DocumentStorageService.shared.fetchAllDocuments()
        if allSaved.contains(where: { $0.fileURLPath == url.path || $0.id == document.id }) {
            self.isSaved = true
        }
    }
    
    private func handleCloseAction() {
        dismiss()
        onDone?()
    }
    
    private func saveDocumentToLibrary() {
        guard let pdfURL = document.pdfURL else { return }
        do {
            _ = try DocumentStorageService.shared.saveDocument(
                from: pdfURL,
                title: document.title,
                pageCount: max(1, document.pages.count)
            )
            withAnimation(.spring()) {
                isSaved = true
                showSaveToast = true
            }
            Task {
                try? await Task.sleep(nanoseconds: 2_500_000_000)
                withAnimation { showSaveToast = false }
            }
        } catch {
            print("Failed to save document: \(error)")
        }
    }
}

private extension AppSpacing {
    static let zero: CGFloat = 0
}

#Preview {
    let sampleImage = UIImage(systemName: AppIcons.docText) ?? UIImage()
    let samplePage = ScannedPageModel(image: sampleImage, pageIndex: 1)
    let sampleDoc = ScannedDocumentModel(title: "Sample_Scan.pdf", pages: [samplePage])
    
    PDFPreviewView(document: sampleDoc)
}
