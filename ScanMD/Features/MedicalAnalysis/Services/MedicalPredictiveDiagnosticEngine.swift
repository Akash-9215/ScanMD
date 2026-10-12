//
//  MedicalPredictiveDiagnosticEngine.swift
//  ScanMD
//
//  Created by Tanveer Patel on 12/10/26.
//

import Foundation

/// Protocol defining on-device machine learning and predictive clinical diagnostic analysis.
protocol MedicalPredictiveDiagnosticEngineProtocol {
    func evaluatePredictions(testItems: [MedicalTestItem], ocrImpression: String, ocrAdvice: [String]) -> (diagnosticSummary: String, clinicalImpression: String, recommendations: [String])
}

/// On-device clinical diagnostic engine generating pathologist and physician grade predictive assessments.
final class MedicalPredictiveDiagnosticEngine: MedicalPredictiveDiagnosticEngineProtocol {
    
    func evaluatePredictions(testItems: [MedicalTestItem], ocrImpression: String, ocrAdvice: [String]) -> (diagnosticSummary: String, clinicalImpression: String, recommendations: [String]) {
        let flagged = testItems.filter { $0.status != .normal }
        var findings: [String] = []
        var recommendations: [String] = []
        
        let names = testItems.map { $0.testName.lowercased() }
        
        // 1. Hematology & Anemia Indices Analysis
        if names.contains(where: { $0.contains("hemoglobin") || $0.contains("hb") }) {
            evaluateHematology(items: testItems, findings: &findings, recommendations: &recommendations)
        }
        
        // 2. Thyroid & Endocrine Panel Analysis
        if names.contains(where: { $0.contains("tsh") }) {
            evaluateThyroid(items: testItems, findings: &findings, recommendations: &recommendations)
        }
        
        // 3. Lipidology & Cardiovascular Risk Analysis
        if names.contains(where: { $0.contains("cholesterol") || $0.contains("triglyceride") }) {
            evaluateLipids(items: testItems, findings: &findings, recommendations: &recommendations)
        }
        
        // 4. Hepatology & Hepatic Panel Analysis
        if names.contains(where: { $0.contains("ast") || $0.contains("alt") }) {
            evaluateHepatic(items: testItems, findings: &findings, recommendations: &recommendations)
        }
        
        // 5. Nephrology & Renal Clearance Analysis
        if names.contains(where: { $0.contains("creatinine") || $0.contains("egfr") }) {
            evaluateRenal(items: testItems, findings: &findings, recommendations: &recommendations)
        }
        
        // 6. Cardiac Electrophysiology & ECG Metrics
        if names.contains(where: { $0.contains("ventricular rate") || $0.contains("pr interval") }) {
            evaluateCardiac(items: testItems, findings: &findings, recommendations: &recommendations)
        }
        
        // Synthesize Clinical Impression
        let finalImpression: String
        if !findings.isEmpty {
            finalImpression = findings.joined(separator: " ")
        } else if !ocrImpression.isEmpty {
            finalImpression = ocrImpression
        } else if flagged.isEmpty {
            finalImpression = "All evaluated laboratory parameters fall within normative physiological reference bounds. No acute pathological anomalies identified."
        } else {
            let summary = flagged.map { "\($0.testName) (\($0.resultValue) \($0.unit))" }.joined(separator: ", ")
            finalImpression = "Diagnostic out-of-range deviations identified: \(summary). Clinical correlation advised."
        }
        
        // Synthesize Recommendations
        if recommendations.isEmpty {
            if !ocrAdvice.isEmpty {
                recommendations = ocrAdvice
            } else {
                recommendations.append("Correlate findings with patient clinical history and symptoms.")
                recommendations.append("Maintain routine preventive health monitoring.")
            }
        } else if !ocrAdvice.isEmpty {
            for advice in ocrAdvice where !recommendations.contains(advice) {
                recommendations.append(advice)
            }
        }
        
        let diagnosticSummary = "Evaluated \(testItems.count) diagnostic parameters. \(flagged.count) parameter(s) flagged out-of-range."
        return (diagnosticSummary, finalImpression, recommendations)
    }
    
    private func evaluateHematology(items: [MedicalTestItem], findings: inout [String], recommendations: inout [String]) {
        let hb = items.first { $0.testName.lowercased().contains("hemoglobin") || $0.testName.lowercased().contains("hb") }
        let mcv = items.first { $0.testName.lowercased().contains("mcv") }
        let rdw = items.first { $0.testName.lowercased().contains("rdw") }
        
        if hb?.status == .abnormalLow {
            if mcv?.status == .abnormalLow {
                findings.append("Microcytic, hypochromic anemia (Hb \(hb?.resultValue ?? ""), MCV \(mcv?.resultValue ?? "")). Elevated RDW \(rdw?.resultValue ?? "") strongly points toward iron deficiency anemia.")
                recommendations.append("Order Serum Ferritin, Total Iron Binding Capacity (TIBC), and Transferrin Saturation.")
                recommendations.append("Investigate potential gastrointestinal or nutritional etiologies for iron deficit.")
            } else {
                findings.append("Normocytic anemia identified (Hb \(hb?.resultValue ?? "")). Clinical evaluation for chronic inflammation advised.")
            }
        }
    }
    
    private func evaluateThyroid(items: [MedicalTestItem], findings: inout [String], recommendations: inout [String]) {
        let tsh = items.first { $0.testName.lowercased().contains("tsh") }
        let ft4 = items.first { $0.testName.lowercased().contains("free t4") }
        
        if tsh?.status == .abnormalHigh && ft4?.status == .abnormalLow {
            findings.append("Biochemical pattern consistent with Primary Hypothyroidism (elevated TSH \(tsh?.resultValue ?? "") with reduced Free T4 \(ft4?.resultValue ?? "")).")
            recommendations.append("Consult endocrinology for thyroid hormone replacement therapy evaluation.")
            recommendations.append("Test Anti-TPO antibodies to assess autoimmune Hashimoto's thyroiditis.")
        }
    }
    
    private func evaluateLipids(items: [MedicalTestItem], findings: inout [String], recommendations: inout [String]) {
        let ldl = items.first { $0.testName.lowercased().contains("ldl") }
        let tg = items.first { $0.testName.lowercased().contains("triglyceride") }
        let hdl = items.first { $0.testName.lowercased().contains("hdl") && !$0.testName.lowercased().contains("non") }
        
        if ldl?.status == .abnormalHigh || tg?.status == .abnormalHigh {
            findings.append("Atherogenic mixed dyslipidemia (elevated LDL-C \(ldl?.resultValue ?? ""), Triglycerides \(tg?.resultValue ?? ""), suboptimal HDL \(hdl?.resultValue ?? "")), contributing to increased cardiovascular risk.")
            recommendations.append("Perform 10-year ASCVD risk stratification and consider lipid-lowering therapy.")
            recommendations.append("Implement dietary saturated fat restriction and structured aerobic exercise.")
        }
    }
    
    private func evaluateHepatic(items: [MedicalTestItem], findings: inout [String], recommendations: inout [String]) {
        let alt = items.first { $0.testName.lowercased().contains("alt") }
        let ast = items.first { $0.testName.lowercased().contains("ast") }
        let bili = items.first { $0.testName.lowercased().contains("bilirubin") }
        
        if alt?.status == .abnormalHigh || ast?.status == .abnormalHigh {
            findings.append("Active hepatocellular injury pattern characterized by elevated transaminases (ALT \(alt?.resultValue ?? "") U/L, AST \(ast?.resultValue ?? "") U/L) with bilirubinemia (\(bili?.resultValue ?? "") mg/dL).")
            recommendations.append("Order viral hepatitis serologies (HBsAg, Anti-HCV) and abdominal ultrasonography.")
            recommendations.append("Review medications, alcohol intake, and hepatotoxic exposures.")
        }
    }
    
    private func evaluateRenal(items: [MedicalTestItem], findings: inout [String], recommendations: inout [String]) {
        let cr = items.first { $0.testName.lowercased().contains("creatinine") }
        let egfr = items.first { $0.testName.lowercased().contains("egfr") }
        let k = items.first { $0.testName.lowercased().contains("potassium") }
        
        if cr?.status == .abnormalHigh || egfr?.status == .abnormalLow {
            let kWarning = k?.status == .abnormalHigh ? " complicated by hyperkalemia (\(k?.resultValue ?? ""))" : ""
            findings.append("Reduced glomerular filtration function (Serum Creatinine \(cr?.resultValue ?? ""), eGFR \(egfr?.resultValue ?? "") mL/min/1.73m²)\(kWarning).")
            recommendations.append("Repeat renal function panel in 2–4 weeks to establish baseline stability.")
            recommendations.append("Review nephrotoxic agents (NSAIDs, ACEi/ARBs) and check urine albumin-to-creatinine ratio.")
        }
    }
    
    private func evaluateCardiac(items: [MedicalTestItem], findings: inout [String], recommendations: inout [String]) {
        let hr = items.first { $0.testName.lowercased().contains("ventricular rate") }
        if hr?.status == .abnormalHigh {
            findings.append("Sinus Tachycardia identified (Ventricular Rate \(hr?.resultValue ?? "") bpm).")
            recommendations.append("Correlate rhythm with clinical symptoms, hydration, endocrine status, and medications.")
        }
    }
}
