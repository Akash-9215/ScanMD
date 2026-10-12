//
//  EndToEndScanIntegrationTests.swift
//  ScanMDTests
//
//  Created by Tanveer Patel on 12/10/26.
//

import XCTest
@testable import ScanMD

/// Integration tests verifying end-to-end document scanning OCR pipeline and table parameter detection.
final class EndToEndScanIntegrationTests: XCTestCase {
    private var parser: MedicalOCRParserService!
    
    override func setUp() {
        super.setUp()
        parser = MedicalOCRParserService()
    }
    
    func testEndToEndLipidScanParsing() {
        let lipidSample = """
        APEX CLINICAL LABORATORY
        Department of Clinical Biochemistry | Mumbai, Maharashtra, India
        PATHOLOGY — LIPID PROFILE
        Patient Name Meera Joshi Patient ID SMD-2026-1002
        Age / Gender 45 years / Female Doctor Dr. Amit Shah
        Date 09-Oct-2026 Specimen / Study Serum | Fasting: 10 hours
        Biochemistry Results
        Test Result Reference / Desirable Value Flag
        Total Cholesterol 268 mg/dL Desirable: <200 mg/dL [HIGH]
        Triglycerides 245 mg/dL Normal: <150 mg/dL [HIGH]
        HDL Cholesterol 38 mg/dL Generally desirable: ≥50 mg/dL in women [LOW]
        LDL Cholesterol 181 mg/dL Optimal: <100 mg/dL [HIGH]
        VLDL Cholesterol 49 mg/dL Approx. 5–40 mg/dL [HIGH]
        Non-HDL Cholesterol 230 mg/dL Desirable: <130 mg/dL for many adults (HIGH]
        Impression / Assessment
        Elevated total cholesterol, LDL cholesterol, and triglycerides, along with low HDL cholesterol.
        Clinical Comment / Advice
        Cardiovascular risk assessment should consider blood pressure.
        """
        
        let header = parser.extractPatientHeader(from: lipidSample)
        XCTAssertEqual(header.name, "Meera Joshi")
        XCTAssertTrue(header.doctor.contains("Dr. Amit Shah"))
        
        let items = parser.extractTestItems(from: lipidSample)
        XCTAssertEqual(items.count, 6)
        
        let flagged = items.filter { $0.status != .normal }
        XCTAssertEqual(flagged.count, 6)
        
        let (impression, advice) = parser.extractImpressionAndAdvice(from: lipidSample, flagged: flagged)
        XCTAssertTrue(impression.contains("Elevated total cholesterol"))
        XCTAssertFalse(advice.isEmpty)
    }
}
