//
//  MedicalFeatureExtractor.swift
//  ScanMD
//
//  Created by Tanveer Patel on 14/10/26.
//

import CoreML
import Foundation

/// Extracts 24-dimensional normalized clinical and structural features matching trained PyTorch Core ML model.
enum MedicalFeatureExtractor {
    private static let medKeywords: Set<String> = [
        "medicine", "doctor", "patient", "hospital", "pathology", "specimen",
        "laboratory", "diagnosis", "clinical", "reference", "serum", "blood",
        "report", "test", "profile", "count", "biopsy", "examination", "impression",
        "advice", "haemoglobin", "hemoglobin", "glucose", "urea", "creatinine",
        "bilirubin", "cholesterol", "urine", "plasma", "platelet", "hematology",
        "biochemistry", "unit", "result", "normal", "abnormal", "interval", "investigation"
    ]
    
    private static let nonMedKeywords: Set<String> = [
        "coffee", "receipt", "invoice", "subtotal", "tax", "price", "menu",
        "checkout", "bill", "item", "qty", "payment", "visa", "mastercard",
        "total", "store", "customer", "cashier", "discount", "terminal",
        "shipping", "order", "delivery", "espresso", "latte", "burger", "pizza"
    ]
    
    /// Generates MLMultiArray formatted as 1x24 matrix of Float32 for Core ML inference.
    static func extractFeatures(from text: String) -> MLMultiArray? {
        guard let array = try? MLMultiArray(shape: [1, 24], dataType: .float32) else {
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
        
        let unitsPat = #"(?:mg/dl|g/dl|mmol/l|u/l|%|pg/ml|ng/dl|ng/ml|µiu/ml|uiu/ml|fl|pg|cells|mill|cumm|bpm|ms|mm/hr|eu/dl)"#
        let unitsRegex = try? NSRegularExpression(pattern: unitsPat, options: .caseInsensitive)
        let unitMatches = unitsRegex?.numberOfMatches(in: lower, range: NSRange(location: 0, length: lower.utf16.count)) ?? 0
        
        let rangeRegex = try? NSRegularExpression(pattern: #"\d+(?:\.\d+)?\s*(?:-|–|to)\s*\d+(?:\.\d+)?"#)
        let rangeMatches = rangeRegex?.numberOfMatches(in: lower, range: NSRange(location: 0, length: lower.utf16.count)) ?? 0
        
        let hasHdr = ["patient name", "age:", "gender:", "ref by:", "collected:", "lab no", "patient id", "visit no", "registered"].contains(where: { lower.contains($0) }) ? 1.0 : 0.0
        
        let cbc = ["hemoglobin", "haemoglobin", "wbc", "rbc", "platelet", "hematocrit", "haematocrit", "neutrophil", "lymphocyte", "mcv", "mch", "mchc", "esr", "blood picture"].filter { lower.contains($0) }.count
        let lipid = ["cholesterol", "triglycerides", "triglyceride", "hdl", "ldl", "vldl", "lipid"].filter { lower.contains($0) }.count
        let liver = ["bilirubin", "sgot", "sgpt", "alt", "ast", "alp", "protein", "albumin", "globulin", "hepatic"].filter { lower.contains($0) }.count
        let renal = ["creatinine", "urea", "bun", "uric acid", "egfr", "kidney", "renal"].filter { lower.contains($0) }.count
        let diabetic = ["glucose", "hba1c", "sugar", "fasting", "post prandial", "insulin", "diabetology", "eag", "glycated"].filter { lower.contains($0) }.count
        let urinalysis = ["urine", "pus cells", "epithelial", "specific gravity", "urobilinogen", "nitrite", "casts", "crystals", "urinalysis"].filter { lower.contains($0) }.count
        let endocrine = ["tsh", "thyroid", "t3", "t4", "ft3", "ft4", "hormone", "vitamin", "b12", "folate", "ferritin"].filter { lower.contains($0) }.count
        let cardio = ["ecg", "troponin", "bnp", "sinus", "rhythm", "ventricular", "pr interval", "qrs", "qtc", "lead"].filter { lower.contains($0) }.count
        let radiology = ["x-ray", "radiograph", "radiology", "chest", "pa view", "lung", "spine", "mri", "bone", "fracture", "vertebra"].filter { lower.contains($0) }.count
        let discharge = ["discharge", "admission", "hospital", "clinical course", "emergency", "vitals", "discharge summary"].filter { lower.contains($0) }.count
        
        let code = ["import ", "export ", "function", "const ", "let ", "var ", "return ", "class ", "def ", "println"].filter { lower.contains($0) }.count
        let currency = ["$", "€", "£", "₹", "usd", "tax:", "subtotal", "change:", "cash:"].filter { lower.contains($0) }.count
        
        let digits = text.filter { $0.isNumber }.count
        let uppers = text.filter { $0.isUppercase }.count
        let tableLines = lines.filter { $0.range(of: #"\d+\.?\d*\s+[a-zA-Z/%]+"#, options: .regularExpression) != nil }.count
        
        let pathologist = ["pathologist", "biochemist", "impression", "signature", "dr.", "consultant", "attending"].contains(where: { lower.contains($0) }) ? 1.0 : 0.0
        let facility = ["laboratory", "laboratories", "lab", "diagnostics", "hospital", "centre", "center", "clinic", "mokhtabar", "alfa"].contains(where: { lower.contains($0) }) ? 1.0 : 0.0
        
        let values: [Float] = [
            min(1.0, Float(medMatches) / Float(totalWords)),
            min(1.0, Float(nonMedMatches) / Float(totalWords)),
            min(1.0, Float(unitMatches) / 5.0),
            min(1.0, Float(rangeMatches) / 5.0),
            Float(hasHdr),
            min(1.0, Float(cbc) / 4.0),
            min(1.0, Float(lipid) / 3.0),
            min(1.0, Float(liver) / 4.0),
            min(1.0, Float(renal) / 3.0),
            min(1.0, Float(diabetic) / 3.0),
            min(1.0, Float(urinalysis) / 3.0),
            min(1.0, Float(endocrine) / 3.0),
            min(1.0, Float(cardio) / 2.0),
            min(1.0, Float(radiology) / 2.0),
            min(1.0, Float(discharge) / 2.0),
            min(1.0, Float(code) / 4.0),
            min(1.0, Float(currency) / 3.0),
            min(1.0, Float(digits) / max(1.0, Float(text.count))),
            min(1.0, Float(uppers) / max(1.0, Float(text.count))),
            min(1.0, Float(totalLines) / 40.0),
            min(1.0, Float(totalWords) / 200.0),
            min(1.0, Float(tableLines) / Float(totalLines)),
            Float(pathologist),
            Float(facility)
        ]
        
        for (i, val) in values.enumerated() {
            array[[0, i] as [NSNumber]] = NSNumber(value: val)
        }
        return array
    }
}
