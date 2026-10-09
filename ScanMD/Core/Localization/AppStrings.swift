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
    static let welcomeTitle = String(localized: "welcome_title", defaultValue: "Welcome to ScanMD")
    static let welcomeSubtitle = String(localized: "welcome_subtitle", defaultValue: "Your intelligent document scanner and manager")
    
    enum Scanner {
        static let scanDocument = String(localized: "scan_document", defaultValue: "Scan Document")
        static let processingDocument = String(localized: "processing_document", defaultValue: "Scanning Document...")
    }
}
