//
//  MedicalTestItem.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import Foundation

/// Status flag for extracted diagnostic test values.
enum MedicalTestStatus: String, Codable, Equatable {
    case normal
    case abnormalHigh
    case abnormalLow
    case critical
}

/// Represents a single structured lab test result row extracted from a medical report.
struct MedicalTestItem: Identifiable, Codable, Equatable {
    let id: UUID
    let testName: String
    let resultValue: String
    let unit: String
    let referenceRange: String
    let status: MedicalTestStatus
    
    init(
        id: UUID = UUID(),
        testName: String,
        resultValue: String,
        unit: String,
        referenceRange: String,
        status: MedicalTestStatus = .normal
    ) {
        self.id = id
        self.testName = testName
        self.resultValue = resultValue
        self.unit = unit
        self.referenceRange = referenceRange
        self.status = status
    }
}
