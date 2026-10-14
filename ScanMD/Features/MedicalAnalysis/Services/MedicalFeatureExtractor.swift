//
//  MedicalFeatureExtractor.swift
//  ScanMD
//
//  Created by Tanveer Patel on 14/10/26.
//

import CoreML
import Foundation

/// Extracts 20-dimensional normalized clinical and structural features from OCR text for Core ML neural classification.
enum MedicalFeatureExtractor {
    private static let medKeywords: Set<String> = [
        "medicine", "doctor", "patient", "hospital", "pathology", "specimen",
        "laboratory", "diagnosis", "clinical", "reference", "serum", "blood",
        "report", "test", "profile", "count", "biopsy", "examination", "impression", "advice"
    ]
    
    private static let nonMedKeywords: Set<String> = [
        "coffee", "receipt", "invoice", "subtotal", "tax", "price", "menu",
        "checkout", "bill", "item", "qty", "payment", "visa", "mastercard",
        "total", "store", "customer", "cashier", "discount", "terminal"
    ]
    
    /// Generates MLMultiArray formatted as 1x20 matrix of Float16/Float32 for Core ML inference.
    static func extractFeatures(from text: String) -> MLMultiArray? {
        guard let array = try? MLMultiArray(shape: [1, 20], dataType: .float32) else {
            return nil
        }
        
        let lower = text.lowercased()
        let words = lower.components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count >= 2 }
        let totalWords = max(1, words.count)
        
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        let totalLines = max(1, lines.count)
        
        let medMatches = words.filter { medKeywords.contains($0) }.count
        let nonMedMatches = words.filter { nonMedKeywords.contains($0) }.count
        
        let unitsRegex = try? NSRegularExpression(pattern: #"(?:mg/dl|g/dl|mmol/l|u/l|%|pg/ml|ng/dl|µiu/ml|fl|pg|cells)"#, options: .caseInsensitive)
        let unitMatches = unitsRegex?.numberOfMatches(in: lower, range: NSRange(location: 0, length: lower.utf16.count)) ?? 0
        
        let rangeRegex = try? NSRegularExpression(pattern: #"\d+(?:\.\d+)?\s*(?:-|–|to)\s*\d+(?:\.\d+)?"#)
        let rangeMatches = rangeRegex?.numberOfMatches(in: lower, range: NSRange(location: 0, length: lower.utf16.count)) ?? 0
        
        let hasHeader = ["patient name", "age:", "gender:", "ref by:", "collected:"].contains(where: { lower.contains($0) }) ? 1.0 : 0.0
        
        let lipid = ["cholesterol", "triglycerides", "hdl", "ldl", "vldl", "lipid"].filter { lower.contains($0) }.count
        let cbc = ["hemoglobin", "wbc", "rbc", "platelet", "hematocrit", "neutrophil", "lymphocyte"].filter { lower.contains($0) }.count
        let liver = ["bilirubin", "sgot", "sgpt", "alt", "ast", "alp", "protein", "albumin"].filter { lower.contains($0) }.count
        let renal = ["creatinine", "urea", "bun", "uric acid", "egfr", "kidney"].filter { lower.contains($0) }.count
        let cardio = ["ecg", "troponin", "bnp", "sinus", "rhythm", "rate", "axis"].filter { lower.contains($0) }.count
        
        let code = ["import ", "export ", "function", "const ", "let ", "var ", "return ", "class "].filter { lower.contains($0) }.count
        let currency = ["$", "€", "£", "₹", "usd", "tax:"].filter { lower.contains($0) }.count
        
        let digits = text.filter { $0.isNumber }.count
        let uppers = text.filter { $0.isUppercase }.count
        let tableLines = lines.filter { $0.range(of: #"\d+\.?\d*\s+[a-zA-Z/%]+"#, options: .regularExpression) != nil }.count
        
        let pathologist = ["pathologist", "biochemist", "impression", "signature", "dr."].contains(where: { lower.contains($0) }) ? 1.0 : 0.0
        let specimen = ["serum", "whole blood", "edta", "plasma", "urine"].contains(where: { lower.contains($0) }) ? 1.0 : 0.0
        let rx = ["tab", "cap", "mg", "od", "bd", "tds", "hs", "dosage", "rx"].contains(where: { lower.contains($0) }) ? 1.0 : 0.0
        
        let values: [Float] = [
            min(1.0, Float(medMatches) / Float(totalWords)),
            min(1.0, Float(nonMedMatches) / Float(totalWords)),
            min(1.0, Float(unitMatches) / 5.0),
            min(1.0, Float(rangeMatches) / 5.0),
            Float(hasHeader),
            min(1.0, Float(lipid) / 3.0),
            min(1.0, Float(cbc) / 4.0),
            min(1.0, Float(liver) / 4.0),
            min(1.0, Float(renal) / 3.0),
            min(1.0, Float(cardio) / 2.0),
            min(1.0, Float(code) / 4.0),
            min(1.0, Float(currency) / 3.0),
            min(1.0, Float(digits) / max(1.0, Float(text.count))),
            min(1.0, Float(uppers) / max(1.0, Float(text.count))),
            min(1.0, Float(totalLines) / 30.0),
            min(1.0, Float(totalWords) / 150.0),
            min(1.0, Float(tableLines) / Float(totalLines)),
            Float(pathologist),
            Float(specimen),
            Float(rx)
        ]
        
        for (i, val) in values.enumerated() {
            array[[0, i] as [NSNumber]] = NSNumber(value: val)
        }
        
        return array
    }
}
