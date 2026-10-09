//
//  AppStrings.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import SwiftUI

/// Centralized access point for localized strings referencing `Localizable.xcstrings`.
enum AppStrings {
    static let appName = String(localized: "app_name", defaultValue: "ScanMD")
    static let welcomeTitle = String(localized: "welcome_title", defaultValue: "Smart Document Scanner")
    static let welcomeSubtitle = String(localized: "welcome_subtitle", defaultValue: "Capture, OCR extract, and export high resolution PDFs")
    
    enum Home {
        static let recentTitle = String(localized: "home_recent_title", defaultValue: "Recent Documents")
        static let quickActions = String(localized: "home_quick_actions", defaultValue: "Quick Actions")
        static let scansCount = String(localized: "home_scans_count", defaultValue: "Documents Saved")
    }
    
    enum Scanner {
        static let scanDocument = String(localized: "scan_document", defaultValue: "Start New Scan")
        static let processingDocument = String(localized: "processing_document", defaultValue: "Processing Document...")
        static let scanTitle = String(localized: "scan_title", defaultValue: "Document Scanner")
        static let cameraUnsupported = String(localized: "camera_unsupported", defaultValue: "Hardware camera unavailable. Tap below for sample scan preview.")
        static let modeAuto = String(localized: "scanner_mode_auto", defaultValue: "AUTO SHUTTER")
        static let pagesCaptured = String(localized: "scanner_pages_format", defaultValue: "Pages Captured")
        static let saveTitlePlaceholder = String(localized: "scanner_save_title_placeholder", defaultValue: "Document Name")
    }
    
    enum PDF {
        static let previewTitle = String(localized: "pdf_preview_title", defaultValue: "PDF Preview & Save")
        static let generating = String(localized: "pdf_generating", defaultValue: "Rendering PDF Document...")
        static let share = String(localized: "pdf_share", defaultValue: "Share PDF")
        static let save = String(localized: "pdf_save", defaultValue: "Save Document")
        static let savedSuccess = String(localized: "pdf_saved_success", defaultValue: "PDF saved to library successfully")
    }
    
    enum OCR {
        static let title = String(localized: "ocr_title", defaultValue: "Extracted Text (OCR)")
        static let button = String(localized: "ocr_button", defaultValue: "OCR Text")
        static let copy = String(localized: "ocr_copy", defaultValue: "Copy Text")
        static let copied = String(localized: "ocr_copied", defaultValue: "Copied to Clipboard")
        static let extracting = String(localized: "ocr_extracting", defaultValue: "Recognizing Text...")
        static let empty = String(localized: "ocr_empty", defaultValue: "No text detected in this scanned page.")
    }
    
    enum Library {
        static let title = String(localized: "library_title", defaultValue: "Saved Library")
        static let empty = String(localized: "library_empty", defaultValue: "No Saved Documents")
        static let emptySubtitle = String(localized: "library_empty_subtitle", defaultValue: "Scanned and saved PDF documents will be displayed here.")
        static let delete = String(localized: "delete_document", defaultValue: "Delete Document")
    }
    
    enum Medical {
        static let title = String(localized: "medical_analysis_title", defaultValue: "Clinical Report & Analysis")
        static let verified = String(localized: "medical_verified", defaultValue: "Verified Medical Document")
        static let unverified = String(localized: "medical_unverified", defaultValue: "Non-Medical Document")
        static let patientName = String(localized: "medical_patient_name", defaultValue: "Patient")
        static let facility = String(localized: "medical_facility", defaultValue: "Facility / Lab")
        static let doctor = String(localized: "medical_doctor", defaultValue: "Physician / Pathologist")
        static let date = String(localized: "medical_date", defaultValue: "Specimen Date")
        static let labResults = String(localized: "medical_lab_results", defaultValue: "Structured Diagnostic Test Results")
        static let colTest = String(localized: "medical_col_test", defaultValue: "Diagnostic Test")
        static let colResult = String(localized: "medical_col_result", defaultValue: "Result")
        static let colRange = String(localized: "medical_col_range", defaultValue: "Ref. Range")
        static let colStatus = String(localized: "medical_col_status", defaultValue: "Status")
        static let pathologistSummary = String(localized: "medical_pathologist_summary", defaultValue: "Pathology Assessment & Diagnostic Insights")
        static let flaggedTitle = String(localized: "medical_flagged_title", defaultValue: "Flagged Out-of-Range Parameters")
        static let recommendations = String(localized: "medical_recommendations", defaultValue: "Clinical Guidance & Next Steps")
        static let analyzing = String(localized: "medical_analyzing", defaultValue: "Parsing Medical Parameters & Pathologist Assessment...")
        static let nonMedicalMsg = String(localized: "medical_non_medical_msg", defaultValue: "This document appears to be a general non-medical scan. No clinical lab tests or health parameters were detected.")
    }
}
