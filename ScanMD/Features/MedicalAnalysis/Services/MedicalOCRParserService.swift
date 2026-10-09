//
//  MedicalOCRParserService.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import Foundation

/// Protocol defining universal regex-based clinical OCR parsing engine for patient metadata, report titles, and lab tables.
protocol MedicalOCRParserProtocol {
    func extractPatientHeader(from text: String) -> (name: String, ageGender: String, hospital: String, doctor: String, date: String, title: String)
    func extractTestItems(from text: String) -> [MedicalTestItem]
    func extractImpressionAndAdvice(from text: String, flagged: [MedicalTestItem]) -> (impression: String, advice: [String])
}

/// Service parsing raw OCR text into structured patient metadata, report titles, lab tables, and clinical impressions.
final class MedicalOCRParserService: MedicalOCRParserProtocol {
    
    func extractPatientHeader(from text: String) -> (name: String, ageGender: String, hospital: String, doctor: String, date: String, title: String) {
        let lines = text.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        
        let name = regexMatch(pattern: #"Patient\s*Name\s*:?\s*([A-Za-z\s]+?)(?=\s+Patient\s*ID|\s+Age|\s+Date|\n|$)"#, in: text) ?? "Patient"
        let ageGender = regexMatch(pattern: #"Age\s*/?\s*Gender\s*:?\s*([^\n]+?)(?=\s+Doctor|\s+Date|\n|$)"#, in: text) ?? ""
        
        var doctor = regexMatch(pattern: #"(?:Doctor|Physician)\s*:?\s*(Dr\.[^\n]+?)(?=\s+Specimen|\s+Patient|\s+Date|\n|$)"#, in: text)
        if doctor == nil || doctor == "Signature" {
            doctor = regexMatch(pattern: #"(?:Authorized\s*/?\s*Reporting\s*Doctor)\s*:?\s*(Dr\.[^\n]+?)(?=\n|$)"#, in: text)
        }
        let doctorName = doctor ?? "Attending Physician"
        let date = regexMatch(pattern: #"Date\s*:?\s*([0-9]{1,2}[-/\s][A-Za-z0-9]{3,9}[-/\s][0-9]{2,4}(?:\s*,\s*[0-9]{1,2}:[0-9]{2}\s*(?:AM|PM)?)?)"#, in: text) ?? Date().formatted(date: .abbreviated, time: .omitted)
        
        var hospital = "Diagnostic Laboratory"
        for line in lines.prefix(5) {
            let lower = line.lowercased()
            if (lower.contains("laboratory") || lower.contains("lab") || lower.contains("hospital") || lower.contains("diagnostics") || lower.contains("centre") || lower.contains("center") || lower.contains("clinic")) && !lower.contains("synthetic") && !lower.contains("department") {
                hospital = line
                break
            }
        }
        
        var title = "Clinical Diagnostic Report"
        for line in lines.prefix(6) {
            let upper = line.uppercased()
            if (upper.contains("PATHOLOGY") || upper.contains("CARDIOLOGY") || upper.contains("REPORT") || upper.contains("PROFILE") || upper.contains("TEST") || upper.contains("COUNT") || upper.contains("PANEL")) && !upper.contains("SYNTHETIC") && !upper.contains("DEPARTMENT") && !upper.contains("LABORATORY") && !upper.contains("HOSPITAL") && !upper.contains("CENTRE") {
                title = line.replacingOccurrences(of: "PATHOLOGY — ", with: "").replacingOccurrences(of: "CARDIOLOGY — ", with: "")
                break
            }
        }
        
        return (name, ageGender, hospital, doctorName, date, title)
    }
    
    func extractTestItems(from text: String) -> [MedicalTestItem] {
        var items: [MedicalTestItem] = []
        let lines = text.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        
        // Universal Pattern 1: Test Name | Result | Unit | Reference Range | Flag
        let p1 = #"^([A-Za-z0-9\s\(\)\-\+\/]+?)\s+([\+\-]?[0-9\.,]+)\s*([A-Za-z%/µμ\^0-9\.\-]+?\/?[A-Za-z0-9μµ\^]*)\s+(.+?)\s+(\[?[A-Za-z\-—]+\]?)$"#
        // Universal Pattern 2: Test Name | Result | Reference Range | Flag (no explicit unit)
        let p2 = #"^([A-Za-z0-9\s\(\)\-\+\/]+?)\s+([\+\-]?[0-9\.,]+)\s+(.+?)\s+(\[?[A-Za-z\-—]+\]?)$"#
        
        guard let r1 = try? NSRegularExpression(pattern: p1, options: [.caseInsensitive]),
              let r2 = try? NSRegularExpression(pattern: p2, options: [.caseInsensitive]) else { return [] }
        
        var inTable = false
        for line in lines {
            let lower = line.lowercased()
            if lower.contains("results") || lower.contains("measurements") || lower.contains("panel") || lower.contains("test result") || lower.contains("parameter result") || lower.contains("profile") || lower.contains("reference range") {
                inTable = true
                continue
            }
            if lower.contains("impression") || lower.contains("assessment") || lower.contains("clinical comment") || lower.contains("authorized") || lower.contains("disclaimer") {
                inTable = false
                continue
            }
            
            let nsRange = NSRange(line.startIndex..<line.endIndex, in: line)
            if inTable || r1.firstMatch(in: line, options: [], range: nsRange) != nil {
                if let match = r1.firstMatch(in: line, options: [], range: nsRange) {
                    appendMatch(match, line: line, hasUnit: true, items: &items)
                } else if let match = r2.firstMatch(in: line, options: [], range: nsRange) {
                    appendMatch(match, line: line, hasUnit: false, items: &items)
                }
            }
        }
        return items
    }
    
    private func appendMatch(_ match: NSTextCheckingResult, line: String, hasUnit: Bool, items: inout [MedicalTestItem]) {
        let tname = substring(of: line, matchRange: match.range(at: 1))
        if tname.lowercased().contains("patient") || tname.lowercased().contains("doctor") || tname.lowercased().contains("authorized") || tname.lowercased().contains("date") { return }
        
        let resultVal = substring(of: line, matchRange: match.range(at: 2))
        let unit = hasUnit ? substring(of: line, matchRange: match.range(at: 3)) : ""
        let refRange = substring(of: line, matchRange: match.range(at: hasUnit ? 4 : 3))
        let flagStr = substring(of: line, matchRange: match.range(at: hasUnit ? 5 : 4)).uppercased()
        
        let status: MedicalTestStatus
        if flagStr.contains("HIGH") { status = .abnormalHigh }
        else if flagStr.contains("LOW") { status = .abnormalLow }
        else if flagStr.contains("BORDERLINE") { status = .abnormalHigh }
        else if flagStr.contains("CRITICAL") { status = .critical }
        else { status = .normal }
        
        items.append(MedicalTestItem(testName: tname, resultValue: resultVal, unit: unit, referenceRange: refRange, status: status))
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
            let summary = flagged.map { "\($0.testName) (\($0.resultValue) \($0.unit))" }.joined(separator: ", ")
            impression = "Out-of-range parameters detected: \(summary). Clinical correlation advised."
        }
        
        var advice: [String] = []
        if let advMatch = advMatch, !advMatch.isEmpty {
            advice.append(advMatch)
        } else if !flagged.isEmpty {
            advice.append("Schedule follow-up consultation with primary care physician or specialist.")
            advice.append("Correlate laboratory findings with clinical symptoms and patient history.")
        } else {
            advice.append("Maintain routine health screening as clinically indicated.")
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
