//
//  MedicalDocumentClassifierService.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import Foundation
import NaturalLanguage

/// Protocol defining medical document classification and verification service.
protocol MedicalDocumentClassifierProtocol {
    func classifyDocument(from ocrText: String) -> (isMedical: Bool, confidence: Double, reportType: String)
}

/// Natural Language and heuristic verification engine classifying documents into medical lab reports vs general scans.
final class MedicalDocumentClassifierService: MedicalDocumentClassifierProtocol {
    
    private let medicalKeywords: Set<String> = [
        "patient", "hospital", "laboratory", "clinic", "doctor", "physician", "pathologist",
        "specimen", "hemoglobin", "wbc", "rbc", "platelet", "glucose", "cholesterol",
        "triglyceride", "creatinine", "hba1c", "reference range", "ref range", "biological ref",
        "units", "mg/dl", "g/dl", "mmol/l", "cells/cumm", "pathology", "hematology",
        "biochemistry", "diagnostic", "prescription", "lab report", "test name"
    ]
    
    /// Classifies OCR text and returns medical verification status, confidence score, and report type.
    func classifyDocument(from ocrText: String) -> (isMedical: Bool, confidence: Double, reportType: String) {
        let lowerText = ocrText.lowercased()
        guard !lowerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return (false, 0.0, "Empty Document")
        }
        
        var matchCount = 0
        for keyword in medicalKeywords {
            if lowerText.contains(keyword) {
                matchCount += 1
            }
        }
        
        let confidence = min(1.0, Double(matchCount) / 4.0)
        let isMedical = matchCount >= 2 || lowerText.contains("medical") || lowerText.contains("scanmd")
        
        var detectedType = "Clinical Diagnostic Report"
        if lowerText.contains("blood") || lowerText.contains("hemoglobin") || lowerText.contains("wbc") {
            detectedType = "Complete Blood Count (CBC) Report"
        } else if lowerText.contains("cholesterol") || lowerText.contains("lipid") || lowerText.contains("triglyceride") {
            detectedType = "Lipid Profile Diagnostic Report"
        } else if lowerText.contains("glucose") || lowerText.contains("hba1c") || lowerText.contains("diabetes") {
            detectedType = "Glycemic & Metabolic Diagnostic Report"
        }
        
        return (isMedical, confidence, detectedType)
    }
}
