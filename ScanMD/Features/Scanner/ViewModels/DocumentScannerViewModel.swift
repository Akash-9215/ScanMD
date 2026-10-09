//
//  DocumentScannerViewModel.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import SwiftUI
import Combine
import VisionKit

@MainActor
final class DocumentScannerViewModel: ObservableObject {
    @Published private(set) var pages: [ScannedPageModel] = []
    @Published private(set) var isGeneratingPDF: Bool = false
    @Published var generatedDocument: ScannedDocumentModel?
    @Published var showPDFPreview: Bool = false
    @Published var errorMessage: String?
    
    private let pdfService: PDFGeneratorServiceProtocol
    
    init(pdfService: PDFGeneratorServiceProtocol = PDFGeneratorService()) {
        self.pdfService = pdfService
    }
    
    /// Checks if device camera scanner is supported on current hardware platform.
    var isCameraSupported: Bool {
        VNDocumentCameraViewController.isSupported
    }
    
    /// Processes newly captured images from camera scanner into scanned page models.
    func handleCapturedImages(_ images: [UIImage]) {
        let newPages = images.enumerated().map { index, image in
            ScannedPageModel(image: image, pageIndex: pages.count + index + 1)
        }
        self.pages.append(contentsOf: newPages)
        generatePDFDocument()
    }
    
    /// Simulates document capture on environments without physical camera support (Simulator).
    func generateDemoScan() {
        let sampleImage = createSampleScannedPageImage()
        handleCapturedImages([sampleImage])
    }
    
    /// Converts current pages into a temporary PDF document for preview before user saving.
    func generatePDFDocument() {
        guard !pages.isEmpty else { return }
        isGeneratingPDF = true
        
        Task {
            do {
                let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .medium)
                let docTitle = "ScanMD_\(timestamp.replacingOccurrences(of: "/", with: "-"))"
                let temporaryURL = try await pdfService.generatePDF(from: pages, title: docTitle)
                
                let doc = ScannedDocumentModel(
                    title: docTitle,
                    pages: pages,
                    pdfURL: temporaryURL
                )
                
                self.generatedDocument = doc
                self.isGeneratingPDF = false
                self.showPDFPreview = true
            } catch {
                self.errorMessage = error.localizedDescription
                self.isGeneratingPDF = false
            }
        }
    }
    
    /// Generates a high-resolution demo scan image with document graphics for simulator testing.
    private func createSampleScannedPageImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 600, height: 800))
        return renderer.image { ctx in
            let rect = CGRect(x: 0, y: 0, width: 600, height: 800)
            UIColor.systemBackground.setFill()
            ctx.fill(rect)
            
            let headerRect = CGRect(x: 40, y: 50, width: 520, height: 60)
            let path = UIBezierPath(roundedRect: headerRect, cornerRadius: 12)
            UIColor.systemIndigo.withAlphaComponent(0.15).setFill()
            path.fill()
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22, weight: .bold),
                .foregroundColor: UIColor.systemIndigo,
                .paragraphStyle: paragraphStyle
            ]
            
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.label,
                .paragraphStyle: paragraphStyle
            ]
            
            "ScanMD Medical Document".draw(in: CGRect(x: 60, y: 68, width: 480, height: 30), withAttributes: titleAttributes)
            
            let sampleText = """
            DOCUMENT SCAN SUMMARY
            ------------------------------------------------
            Date: \(Date().formatted(date: .long, time: .shortened))
            Status: Verified High Quality Scan
            Engine: VisionKit + ScanMD Core
            
            This document sample was generated automatically for preview and testing.
            The multi-page PDF engine encodes images cleanly into PDFKit document specs.
            """
            sampleText.draw(in: CGRect(x: 40, y: 150, width: 520, height: 600), withAttributes: bodyAttributes)
        }
    }
}
