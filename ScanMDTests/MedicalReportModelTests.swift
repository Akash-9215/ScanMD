//
//  MedicalReportModelTests.swift
//  ScanMDTests
//
//  Created by Tanveer Patel on 12/10/26.
//

import XCTest
@testable import ScanMD

/// Unit tests verifying MedicalReportModel and MedicalTestItem data structures and status mappings.
final class MedicalReportModelTests: XCTestCase {
    
    func testMedicalTestItemFormatting() {
        let item = MedicalTestItem(
            testName: "Total Cholesterol",
            resultValue: "268",
            unit: "mg/dL",
            referenceRange: "<200 mg/dL",
            status: .abnormalHigh
        )
        
        XCTAssertEqual(item.testName, "Total Cholesterol")
        XCTAssertEqual(item.resultValue, "268")
        XCTAssertEqual(item.unit, "mg/dL")
        XCTAssertEqual(item.status, .abnormalHigh)
    }
    
    func testMedicalReportModelInstantiation() {
        let item = MedicalTestItem(
            testName: "HDL Cholesterol",
            resultValue: "38",
            unit: "mg/dL",
            referenceRange: "≥50 mg/dL",
            status: .abnormalLow
        )
        
        let report = MedicalReportModel(
            isMedicalReport: true,
            reportType: "PATHOLOGY — LIPID PROFILE",
            patientName: "Meera Joshi",
            patientAge: "45 years / Female",
            hospitalName: "APEX CLINICAL LABORATORY",
            doctorName: "Dr. Amit Shah",
            reportDate: "09-Oct-2026",
            testItems: [item],
            diagnosticSummary: "Evaluated 1 parameter.",
            flaggedAbnormalities: ["HDL Cholesterol (38 mg/dL)"],
            clinicalImpression: "Elevated lipid risk.",
            recommendedActions: ["Follow-up clinical consultation advised."]
        )
        
        XCTAssertTrue(report.isMedicalReport)
        XCTAssertEqual(report.patientName, "Meera Joshi")
        XCTAssertEqual(report.testItems.count, 1)
        XCTAssertEqual(report.flaggedAbnormalities.count, 1)
    }
}
