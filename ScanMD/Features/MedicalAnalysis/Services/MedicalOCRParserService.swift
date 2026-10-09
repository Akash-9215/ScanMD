//
//  MedicalOCRParserService.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import Foundation

/// Protocol defining regex-based clinical OCR parsing engine for patient metadata and lab test tables.
protocol MedicalOCRParserProtocol {
    func extractPatientHeader(from text: String) -> (name: String, ageGender: String, hospital: String, doctor: String, date: String)
    func extractTestItems(from text: String) -> [MedicalTestItem]
    func extractImpressionAndAdvice(from text: String, flagged: [MedicalTestItem]) -> (impression: String, advice: [String])
}

/// Service parsing raw OCR text into structured patient metadata, lab tables, and clinical impressions.
final class MedicalOCRParserService: MedicalOCRParserProtocol {
    
    func extractPatientHeader(from text: String) -> (name: String, ageGender: String, hospital: String, doctor: String, date: String) {
        let lines = text.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        
        let name = regexMatch(pattern: #"Patient\s*Name\s*:?\s*([A-Za-z\s]+?)(?=\s+Patient\s*ID|\s+Age|\s+Date|\n|$)"#, in: text) ?? "Patient"
        let ageGender = regexMatch(pattern: #"Age\s*/?\s*Gender\s*:?\s*([^\n]+?)(?=\s+Doctor|\s+Date|\n|$)"#, in: text) ?? ""
        let doctor = regexMatch(pattern: #"(?:Authorized\s*/?\s*Reporting\s*Doctor|Doctor|Physician)\s*:?\s*([A-Za-z\s\.\,]+?)(?=\s+Date|\s+Specimen|\n|$)"#, in: text) ?? "Attending Physician"
        let date = regexMatch(pattern: #"Date\s*:?\s*([0-9]{1,2}[-/\s][A-Za-z0-9]{3,9}[-/\s][0-9]{2,4})"#, in: text) ?? Date().formatted(date: .abbreviated, time: .omitted)
        
        var hospital = "Diagnostic Laboratory"
        for (idx, line) in lines.prefix(5).enumerated() {
            if idx > 0 && !line.lowercased().contains("synthetic") && !line.lowercased().contains("page") {
                hospital = line
                break
            }
        }
        
        return (name, ageGender, hospital, doctor, date)
    }
    
    func extractTestItems(from text: String) -> [MedicalTestItem] {
        var items: [MedicalTestItem] = []
        let lines = text.components(separatedBy: .newlines)
        
        let units = #"(?:µIU/mL|uIU/mL|mIU/L|pg/mL|ng/dL|g/dL|mg/dL|mmol/L|/cumm|10\^3/uL|10\^6/uL|%|U/L|IU/L|mEq/L)"#
        let pattern = #"^([A-Za-z0-9\s\(\)\-]+?)\s+([0-9\.,]+)\s+("# + units + #")\s+([0-9\.,]+\s*[\–\-–]\s*[0-9\.,]+\s*"# + units + #"?)\s+(\[?[A-Za-z]+\]?)"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return [] }
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            let nsRange = NSRange(trimmed.startIndex..<trimmed.endIndex, in: trimmed)
            if let match = regex.firstMatch(in: trimmed, options: [], range: nsRange) {
                let testName = substring(of: trimmed, matchRange: match.range(at: 1))
                let resultVal = substring(of: trimmed, matchRange: match.range(at: 2))
                let unit = substring(of: trimmed, matchRange: match.range(at: 3))
                let refRange = substring(of: trimmed, matchRange: match.range(at: 4))
                let flagStr = substring(of: trimmed, matchRange: match.range(at: 5)).uppercased()
                
                let status: MedicalTestStatus
                if flagStr.contains("HIGH") {
                    status = .abnormalHigh
                } else if flagStr.contains("LOW") {
                    status = .abnormalLow
                } else if flagStr.contains("CRITICAL") {
                    status = .critical
                } else {
                    status = .normal
                }
                
                items.append(MedicalTestItem(
                    testName: testName,
                    resultValue: resultVal,
                    unit: unit,
                    referenceRange: refRange,
                    status: status
                ))
            }
        }
        return items
    }
    
    func extractImpressionAndAdvice(from text: String, flagged: [MedicalTestItem]) -> (impression: String, advice: [String]) {
        let impMatch = regexMatch(pattern: #"(?:Impression\s*/?\s*Assessment|Diagnostic\s*Impression|Impression)\s*:?\n?([^\n]+(?:\n[^\n]+)?)"#, in: text)
        let advMatch = regexMatch(pattern: #"(?:Clinical\s*Comment\s*/?\s*Advice|Clinical\s*Advice|Recommendations)\s*:?\n?([^\n]+(?:\n[^\n]+)?)"#, in: text)
        
        let impression: String
        if let impMatch = impMatch, !impMatch.isEmpty {
            impression = impMatch
        } else if flagged.isEmpty {
            impression = "All evaluated parameters fall within normative physiological reference ranges."
        } else {
            let flaggedSummary = flagged.map { "\($0.testName) (\($0.resultValue) \($0.unit))" }.joined(separator: ", ")
            impression = "Out-of-range parameters identified: \(flaggedSummary). Clinical correlation recommended."
        }
        
        var advice: [String] = []
        if let advMatch = advMatch, !advMatch.isEmpty {
            advice.append(advMatch)
        } else if !flagged.isEmpty {
            advice.append("Schedule follow-up consultation with primary care physician.")
            advice.append("Repeat testing within 4 weeks if clinically indicated.")
        } else {
            advice.append("Maintain routine annual health screening.")
        }
        
        return (impression, advice)
    }
    
    private func regexMatch(pattern: String, in text: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return nil }
        let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
        if let match = regex.firstMatch(in: text, options: [], range: nsRange), match.numberOfRanges > 1 {
            let captureRange = match.range(at: 1)
            if let range = Range(captureRange, in: text) {
                return String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return nil
    }
    
    private func substring(of text: String, matchRange: NSRange) -> String {
        guard let range = Range(matchRange, in: text) else { return "" }
        return String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
