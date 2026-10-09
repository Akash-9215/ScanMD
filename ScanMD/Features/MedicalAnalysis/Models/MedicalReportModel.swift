//
//  MedicalReportModel.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import Foundation

/// Structured clinical model representing medical document classification, parsed lab tests, and diagnostic insights.
struct MedicalReportModel: Identifiable, Equatable {
    let id: UUID
    let isMedicalReport: Bool
    let confidenceScore: Double
    let reportType: String
    let patientName: String
    let patientAge: String
    let hospitalName: String
    let doctorName: String
    let reportDate: String
    let testItems: [MedicalTestItem]
    let diagnosticSummary: String
    let flaggedAbnormalities: [String]
    let clinicalImpression: String
    let recommendedActions: [String]
    
    init(
        id: UUID = UUID(),
        isMedicalReport: Bool,
        confidenceScore: Double = 0.95,
        reportType: String = "Diagnostic Lab Report",
        patientName: String = "John Doe",
        patientAge: String = "34 Yrs",
        hospitalName: String = "Metropolitan Health & Diagnostics",
        doctorName: String = "Dr. Robert Vance, MD (Pathology)",
        reportDate: String = Date().formatted(date: .abbreviated, time: .omitted),
        testItems: [MedicalTestItem] = [],
        diagnosticSummary: String = "",
        flaggedAbnormalities: [String] = [],
        clinicalImpression: String = "",
        recommendedActions: [String] = []
    ) {
        self.id = id
        self.isMedicalReport = isMedicalReport
        self.confidenceScore = confidenceScore
        self.reportType = reportType
        self.patientName = patientName
        self.patientAge = patientAge
        self.hospitalName = hospitalName
        self.doctorName = doctorName
        self.reportDate = reportDate
        self.testItems = testItems
        self.diagnosticSummary = diagnosticSummary
        self.flaggedAbnormalities = flaggedAbnormalities
        self.clinicalImpression = clinicalImpression
        self.recommendedActions = recommendedActions
    }
}
