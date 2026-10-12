//
//  PredictiveDiagnosticEngineTests.swift
//  ScanMDTests
//
//  Created by Tanveer Patel on 12/10/26.
//

import XCTest
@testable import ScanMD

/// Unit tests validating multi-organ clinical AI predictive diagnostic engine and guideline recommendations.
final class PredictiveDiagnosticEngineTests: XCTestCase {
    private var engine: MedicalPredictiveDiagnosticEngine!
    
    override func setUp() {
        super.setUp()
        engine = MedicalPredictiveDiagnosticEngine()
    }
    
    func testLipidProfileDiagnosticAssessment() {
        let items: [MedicalTestItem] = [
            MedicalTestItem(testName: "Total Cholesterol", resultValue: "268", unit: "mg/dL", referenceRange: "<200", status: .abnormalHigh),
            MedicalTestItem(testName: "Triglycerides", resultValue: "245", unit: "mg/dL", referenceRange: "<150", status: .abnormalHigh),
            MedicalTestItem(testName: "HDL Cholesterol", resultValue: "38", unit: "mg/dL", referenceRange: ">50", status: .abnormalLow),
            MedicalTestItem(testName: "LDL Cholesterol", resultValue: "181", unit: "mg/dL", referenceRange: "<100", status: .abnormalHigh),
            MedicalTestItem(testName: "VLDL Cholesterol", resultValue: "49", unit: "mg/dL", referenceRange: "5-40", status: .abnormalHigh),
            MedicalTestItem(testName: "Non-HDL Cholesterol", resultValue: "230", unit: "mg/dL", referenceRange: "<130", status: .abnormalHigh)
        ]
        
        let assessment = engine.evaluatePredictions(
            testItems: items,
            ocrImpression: "Elevated total cholesterol",
            ocrAdvice: ["Cardiovascular risk assessment advised"]
        )
        
        XCTAssertTrue(assessment.diagnosticSummary.contains("Evaluated 6 diagnostic parameters"))
        XCTAssertTrue(assessment.diagnosticSummary.contains("6 parameter(s) flagged out-of-range"))
        XCTAssertFalse(assessment.clinicalImpression.isEmpty)
        XCTAssertFalse(assessment.recommendations.isEmpty)
        
        // Should contain cardiovascular risk recommendation
        let recs = assessment.recommendations.joined(separator: " ")
        XCTAssertTrue(recs.contains("cardiovascular") || recs.contains("lipid") || recs.contains("diet") || recs.contains("physician") || recs.contains("Cardiovascular"))
    }
    
    func testNormalParametersAssessment() {
        let items: [MedicalTestItem] = [
            MedicalTestItem(testName: "Hemoglobin", resultValue: "14.2", unit: "g/dL", referenceRange: "13-17", status: .normal),
            MedicalTestItem(testName: "Platelets", resultValue: "250000", unit: "/cumm", referenceRange: "150000-450000", status: .normal)
        ]
        
        let assessment = engine.evaluatePredictions(
            testItems: items,
            ocrImpression: "",
            ocrAdvice: []
        )
        
        XCTAssertTrue(assessment.diagnosticSummary.contains("0 parameter(s) flagged out-of-range"))
    }
}
