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
    private let predictiveEngine: MedicalPredictiveDiagnosticEngineProtocol
    
    init(
        classifier: MedicalDocumentClassifierProtocol = CoreMLMedicalClassifierService(),
        parser: MedicalOCRParserProtocol = MedicalOCRParserService(),
        predictiveEngine: MedicalPredictiveDiagnosticEngineProtocol = MedicalPredictiveDiagnosticEngine()
    ) {
        self.classifier = classifier
        self.parser = parser
        self.predictiveEngine = predictiveEngine
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
        
        let (rawImpression, rawAdvice) = parser.extractImpressionAndAdvice(from: ocrText, flagged: flagged)
        
        // Use Predictive Diagnostic Engine to synthesize physician-grade clinical impressions
        let (diagnosticSummary, clinicalImpression, recommendations) = predictiveEngine.evaluatePredictions(
            testItems: testItems,
            ocrImpression: rawImpression,
            ocrAdvice: rawAdvice
        )
        
        let titleLower = header.title.lowercased()
        let isMatchingTableTest = testItems.contains { item in
            let itemLower = item.testName.lowercased()
            return titleLower == itemLower || titleLower.contains(itemLower) || itemLower.contains(titleLower)
        }
        let isIndividualTest = isMatchingTableTest || [
            "count", "hemoglobin", "haemoglobin", "cholesterol", "triglyceride", "glucose",
            "creatinine", "urea", "bilirubin", "sgot", "sgpt", "alt", "ast", "alp", "calcium",
            "potassium", "sodium", "tsh", "test name", "test type", "investigation", "parameter"
        ].contains(where: { titleLower.contains($0) && !titleLower.contains("complete blood") })
        
        let reportTitle = (!isIndividualTest && header.title != "Clinical Diagnostic Report" && !header.title.isEmpty)
            ? header.title
            : classification.reportType
        
        return MedicalReportModel(
            isMedicalReport: true,
            confidenceScore: max(0.92, classification.confidence),
            reportType: reportTitle,
            patientName: header.name,
            patientAge: header.ageGender.isEmpty ? "N/A" : header.ageGender,
            hospitalName: header.hospital,
            doctorName: header.doctor,
            reportDate: header.date,
            testItems: testItems,
            diagnosticSummary: diagnosticSummary,
            flaggedAbnormalities: flaggedNames,
            clinicalImpression: clinicalImpression,
            recommendedActions: recommendations
        )
    }
}
