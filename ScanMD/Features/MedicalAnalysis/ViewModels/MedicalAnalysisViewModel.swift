//
//  MedicalAnalysisViewModel.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import SwiftUI
import Combine

@MainActor
final class MedicalAnalysisViewModel: ObservableObject {
    @Published private(set) var isAnalyzing: Bool = false
    @Published private(set) var report: MedicalReportModel?
    @Published var errorMessage: String?
    
    private let ocrService: OCRServiceProtocol
    private let analysisService: MedicalAnalysisServiceProtocol
    
    init(
        ocrService: OCRServiceProtocol = OCRService(),
        analysisService: MedicalAnalysisServiceProtocol = MedicalAnalysisService()
    ) {
        self.ocrService = ocrService
        self.analysisService = analysisService
    }
    
    /// Analyzes document text extracted from pages or PDF URL to generate medical report.
    func analyzeDocument(pages: [ScannedPageModel], pdfURL: URL?) {
        isAnalyzing = true
        
        Task {
            do {
                var text = ""
                if let pdfURL = pdfURL {
                    text = try await ocrService.performOCR(on: pdfURL)
                } else if !pages.isEmpty {
                    var pageTexts: [String] = []
                    for page in pages {
                        let pageText = try await ocrService.performOCR(on: page.image)
                        pageTexts.append(pageText)
                    }
                    text = pageTexts.joined(separator: "\n")
                }
                
                let result = await analysisService.analyzeMedicalDocument(from: text)
                self.report = result
                self.isAnalyzing = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isAnalyzing = false
            }
        }
    }
}
