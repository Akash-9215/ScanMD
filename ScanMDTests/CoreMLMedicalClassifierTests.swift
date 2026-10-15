//
//  CoreMLMedicalClassifierTests.swift
//  ScanMDTests
//
//  Created by Tanveer Patel on 14/10/26.
//

import CoreML
import XCTest
@testable import ScanMD

/// Unit tests verifying Core ML on-device neural classification of medical vs non-medical documents.
final class CoreMLMedicalClassifierTests: XCTestCase {
    private var classifier: CoreMLMedicalClassifierService!
    
    override func setUp() {
        super.setUp()
        classifier = CoreMLMedicalClassifierService()
    }
    
    func testFeatureExtractorOutputValid() {
        let sample = "APEX CLINICAL LABORATORY\nTotal Cholesterol 245 mg/dL\nPatient Name: John"
        let features = MedicalFeatureExtractor.extractFeatures(from: sample)
        XCTAssertNotNil(features)
        XCTAssertEqual(features?.shape, [1, 24])
    }
    
    func testClassifyLipidProfileWithCoreML() async {
        let text = """
        APEX CLINICAL LABORATORY
        Department of Clinical Biochemistry
        PATHOLOGY — LIPID PROFILE
        Patient Name: Meera Joshi
        Total Cholesterol: 268 mg/dL
        Triglycerides: 245 mg/dL
        HDL: 38 mg/dL
        LDL: 181 mg/dL
        Dr. Amit Shah
        """
        
        let result = classifier.classifyDocument(from: text)
        XCTAssertTrue(result.isMedical)
        XCTAssertGreaterThan(result.confidence, 0.7)
        XCTAssertTrue(result.reportType.contains("Lipid") || result.reportType.contains("Medical"))
    }
    
    func testClassifyCompleteBloodCountWithCoreML() async {
        let text = """
        CITY HEALTH CARE LABORATORY
        Department of Hematology
        COMPLETE BLOOD COUNT (CBC)
        Patient Name: John Doe Age: 35
        Hemoglobin: 14.8 g/dL (13.0-17.0)
        WBC Total Count: 7200 cells/cumm
        Platelet Count: 240000 /cumm
        Specimen: EDTA Whole Blood
        Pathologist: Dr. Verma, MD
        """
        
        let result = classifier.classifyDocument(from: text)
        XCTAssertTrue(result.isMedical)
        XCTAssertGreaterThan(result.confidence, 0.7)
    }
    
    func testClassifyDiabetologyWithCoreML() async {
        let text = """
        DIACARE ADVANCED DIAGNOSTICS
        Department of Diabetology and Clinical Biochemistry
        DIABETOLOGY — HbA1c PANEL
        Patient Name: Manish Salunkhe
        HbA1c: 8.4 %
        Estimated Average Glucose (eAG): 194 mg/dL
        Fasting Plasma Glucose: 168 mg/dL
        """
        
        let result = classifier.classifyDocument(from: text)
        XCTAssertTrue(result.isMedical)
        XCTAssertGreaterThan(result.confidence, 0.7)
    }
    
    func testRejectNonMedicalReceiptWithCoreML() async {
        let text = """
        STARBUCKS COFFEE STORE #1428
        Caramel Macchiato Grande $5.75
        Blueberry Muffin $3.50
        Subtotal: $9.25
        Tax: $0.74
        Total: $9.99
        Thank you for visiting!
        """
        
        let result = classifier.classifyDocument(from: text)
        XCTAssertFalse(result.isMedical)
        XCTAssertEqual(result.reportType, "Non-Medical Document")
    }
    
    func testRejectSoftwareCodeSnippetWithCoreML() async {
        let text = """
        import React, { useState, useEffect } from 'react';
        export default function App() {
            const [count, setCount] = useState(0);
            return <button onClick={() => setCount(count + 1)}>{count}</button>;
        }
        """
        
        let result = classifier.classifyDocument(from: text)
        XCTAssertFalse(result.isMedical)
        XCTAssertEqual(result.reportType, "Non-Medical Document")
    }
}
