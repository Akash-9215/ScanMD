//
//  MedicalClassifierTests.swift
//  ScanMDTests
//
//  Created by Tanveer Patel on 12/10/26.
//

import XCTest
@testable import ScanMD

/// Unit tests verifying NaturalLanguage semantic AI classification of medical documents.
final class MedicalClassifierTests: XCTestCase {
    private var classifier: MedicalDocumentClassifierService!
    
    override func setUp() {
        super.setUp()
        classifier = MedicalDocumentClassifierService()
    }
    
    func testClassifyLipidProfileAsMedical() async {
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
        
        let result = await classifier.classifyDocument(from: text)
        XCTAssertTrue(result.isMedical)
        XCTAssertGreaterThan(result.confidence, 0.4)
    }
    
    func testRejectNonMedicalReceipt() async {
        let text = """
        STARBUCKS COFFEE STORE #1428
        Caramel Macchiato Grande $5.75
        Blueberry Muffin $3.50
        Subtotal: $9.25
        Tax: $0.74
        Total: $9.99
        Thank you for visiting!
        """
        
        let result = await classifier.classifyDocument(from: text)
        XCTAssertFalse(result.isMedical)
    }
    
    func testRejectSoftwareCodeSnippet() async {
        let text = """
        import React, { useState, useEffect } from 'react';
        export default function App() {
            const [count, setCount] = useState(0);
            return <button onClick={() => setCount(count + 1)}>{count}</button>;
        }
        """
        
        let result = await classifier.classifyDocument(from: text)
        XCTAssertFalse(result.isMedical)
    }
}
