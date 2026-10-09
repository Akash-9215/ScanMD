//
//  MedicalAnalysisService.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import Foundation

/// Protocol defining clinical analysis and structured lab report extraction engine.
protocol MedicalAnalysisServiceProtocol {
    func analyzeMedicalDocument(from ocrText: String) async -> MedicalReportModel
}

/// Service parsing OCR text to extract patient header metadata, aligned lab tables, and clinical diagnostic impressions.
final class MedicalAnalysisService: MedicalAnalysisServiceProtocol {
    private let classifier: MedicalDocumentClassifierProtocol
    private let parser: MedicalOCRParserProtocol
    
    init(
        classifier: MedicalDocumentClassifierProtocol = MedicalDocumentClassifierService(),
        parser: MedicalOCRParserProtocol = MedicalOCRParserService()
    ) {
        self.classifier = classifier
        self.parser = parser
    }
    
    /// Analyzes document text to extract structured medical tables, patient details, and clinical diagnostic insights.
    func analyzeMedicalDocument(from ocrText: String) async -> MedicalReportModel {
        let classification = classifier.classifyDocument(from: ocrText)
        guard classification.isMedical else {
            return MedicalReportModel(
                isMedicalReport: false,
                confidenceScore: classification.confidence,
                reportType: classification.reportType,
                diagnosticSummary: AppStrings.Medical.nonMedicalMsg
            )
        }
        
        let header = parser.extractPatientHeader(from: ocrText)
        let testItems = parser.extractTestItems(from: ocrText)
        let flagged = testItems.filter { $0.status != .normal }
        let flaggedNames = flagged.map { "\($0.testName): \($0.resultValue) \($0.unit) (Ref: \($0.referenceRange))" }
        
        let (impression, advice) = parser.extractImpressionAndAdvice(from: ocrText, flagged: flagged)
        
        return MedicalReportModel(
            isMedicalReport: true,
            confidenceScore: max(0.88, classification.confidence),
            reportType: classification.reportType,
            patientName: header.name,
            patientAge: header.ageGender.isEmpty ? "N/A" : header.ageGender,
            hospitalName: header.hospital,
            doctorName: header.doctor,
            reportDate: header.date,
            testItems: testItems,
            diagnosticSummary: impression,
            flaggedAbnormalities: flaggedNames,
            clinicalImpression: impression,
            recommendedActions: advice
        )
    }
}
