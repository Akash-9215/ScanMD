//
//  MedicalDocumentClassifierService.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import Foundation

/// Protocol defining medical document classification and verification service.
protocol MedicalDocumentClassifierProtocol {
    func classifyDocument(from ocrText: String) -> (isMedical: Bool, confidence: Double, reportType: String)
}

/// Natural Language and heuristic verification engine classifying documents into medical lab reports vs general scans.
final class MedicalDocumentClassifierService: MedicalDocumentClassifierProtocol {
    
    private let strongClinicalTerms: Set<String> = [
        "patient name", "doctor", "physician", "pathologist", "pathology",
        "cardiology", "ecg measurements", "thyroid panel", "specimen",
        "reference range", "ref range", "expected value", "lab report",
        "test result", "diagnostic report", "hemoglobin", "wbc", "rbc",
        "platelet", "tsh", "free t3", "free t4", "ventricular rate", "pr interval"
    ]
    
    /// Classifies OCR text and returns medical verification status, confidence score, and report type.
    func classifyDocument(from ocrText: String) -> (isMedical: Bool, confidence: Double, reportType: String) {
        let lowerText = ocrText.lowercased()
        guard !lowerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return (false, 0.0, "Empty Document")
        }
        
        var matchCount = 0
        for term in strongClinicalTerms {
            if lowerText.contains(term) {
                matchCount += 1
            }
        }
        
        // Strict verification: requires at least 2 strong clinical terms or patient+doctor combination
        let hasHeaderCombo = lowerText.contains("patient") && (lowerText.contains("doctor") || lowerText.contains("physician"))
        let isMedical = matchCount >= 2 || (matchCount >= 1 && hasHeaderCombo)
        let confidence = min(1.0, Double(matchCount) / 3.0)
        
        var detectedType = "Clinical Diagnostic Report"
        if lowerText.contains("ecg") || lowerText.contains("cardiology") || lowerText.contains("ventricular rate") {
            detectedType = "12-Lead ECG Cardiology Report"
        } else if lowerText.contains("thyroid") || lowerText.contains("tsh") || lowerText.contains("free t3") {
            detectedType = "Thyroid Function Test (TFT) Report"
        } else if lowerText.contains("blood") || lowerText.contains("hemoglobin") || lowerText.contains("wbc") {
            detectedType = "Complete Blood Count (CBC) Report"
        } else if lowerText.contains("cholesterol") || lowerText.contains("lipid") || lowerText.contains("triglyceride") {
            detectedType = "Lipid Profile Diagnostic Report"
        } else if lowerText.contains("glucose") || lowerText.contains("hba1c") || lowerText.contains("diabetes") {
            detectedType = "Glycemic & Metabolic Diagnostic Report"
        }
        
        return (isMedical, confidence, detectedType)
    }
}
