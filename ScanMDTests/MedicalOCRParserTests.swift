//
//  MedicalOCRParserTests.swift
//  ScanMDTests
//
//  Created by Tanveer Patel on 12/10/26.
//

import XCTest
@testable import ScanMD

/// Unit tests verifying regex-based clinical OCR parsing engine for patient headers, lab tables, and diagnostic impressions.
final class MedicalOCRParserTests: XCTestCase {
    private var parser: MedicalOCRParserService!
    
    override func setUp() {
        super.setUp()
        parser = MedicalOCRParserService()
    }
    
    func testExtractPatientHeaderFromLipidReport() {
        let text = """
        APEX CLINICAL LABORATORY
        Department of Clinical Biochemistry | Mumbai, Maharashtra, India
        PATHOLOGY — LIPID PROFILE
        Patient Name Meera Joshi Patient ID SMD-2026-1002
        Age / Gender 45 years / Female Doctor Dr. Amit Shah
        Date 09-Oct-2026 Specimen / Study Serum | Fasting: 10 hours
        """
        
        let header = parser.extractPatientHeader(from: text)
        XCTAssertTrue(header.name.contains("Meera Joshi"))
        XCTAssertTrue(header.ageGender.contains("45 years") || header.ageGender.contains("Female"))
        XCTAssertTrue(header.hospital.contains("APEX CLINICAL LABORATORY"))
        XCTAssertTrue(header.doctor.contains("Dr. Amit Shah"))
        XCTAssertTrue(header.date.contains("09-Oct-2026"))
        XCTAssertTrue(header.title.contains("LIPID PROFILE"))
    }
    
    func testExtractLipidProfileTestItems() {
        let text = """
        Biochemistry Results
        Test Result Reference / Desirable Value Flag
        Total Cholesterol 268 mg/dL Desirable: <200 mg/dL [HIGH]
        Triglycerides 245 mg/dL Normal: <150 mg/dL [HIGH]
        HDL Cholesterol 38 mg/dL Generally desirable: ≥50 mg/dL in women [LOW]
        LDL Cholesterol 181 mg/dL Optimal: <100 mg/dL [HIGH]
        VLDL Cholesterol 49 mg/dL Approx. 5–40 mg/dL [HIGH]
        Non-HDL Cholesterol 230 mg/dL Desirable: <130 mg/dL for many adults (HIGH]
        Impression / Assessment
        Elevated total cholesterol.
        """
        
        let items = parser.extractTestItems(from: text)
        XCTAssertEqual(items.count, 6)
        
        let names = items.map { $0.testName }
        XCTAssertTrue(names.contains(where: { $0.contains("Total Cholesterol") }))
        XCTAssertTrue(names.contains(where: { $0.contains("Triglycerides") }))
        XCTAssertTrue(names.contains(where: { $0.contains("HDL Cholesterol") }))
        XCTAssertTrue(names.contains(where: { $0.contains("LDL Cholesterol") }))
        XCTAssertTrue(names.contains(where: { $0.contains("VLDL Cholesterol") }))
        XCTAssertTrue(names.contains(where: { $0.contains("Non-HDL Cholesterol") }))
        
        let totalChol = items.first { $0.testName.contains("Total Cholesterol") }
        XCTAssertEqual(totalChol?.resultValue, "268")
        XCTAssertEqual(totalChol?.status, .abnormalHigh)
        
        let hdl = items.first { $0.testName.contains("HDL") && !$0.testName.contains("Non") && !$0.testName.contains("VLDL") }
        XCTAssertEqual(hdl?.resultValue, "38")
        XCTAssertEqual(hdl?.status, .abnormalLow)
    }
    
    func testExtractCBCTestItems() {
        let text = """
        Hematology Panel Results
        Test Result Unit Reference Range Flag
        Hemoglobin 14.2 g/dL 13.0 - 17.0 NORMAL
        WBC Count 11500 /cumm 4000 - 11000 [HIGH]
        Platelet Count 250000 /cumm 150000 - 450000 NORMAL
        """
        
        let items = parser.extractTestItems(from: text)
        XCTAssertEqual(items.count, 3)
        XCTAssertEqual(items[1].status, .abnormalHigh)
    }
    
    func testExtractImpressionAndAdvice() {
        let text = """
        Impression / Assessment
        Elevated total cholesterol, LDL cholesterol, and triglycerides, along with low HDL cholesterol.
        Clinical Comment / Advice
        Cardiovascular risk assessment should consider blood pressure.
        """
        
        let (impression, advice) = parser.extractImpressionAndAdvice(from: text, flagged: [])
        XCTAssertTrue(impression.contains("Elevated total cholesterol"))
        XCTAssertFalse(advice.isEmpty)
        XCTAssertTrue(advice[0].contains("Cardiovascular risk"))
    }
}
