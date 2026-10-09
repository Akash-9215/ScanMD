//
//  AppColors.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import SwiftUI

/// Centralized color tokens and artistic gradient palettes for ScanMD.
enum AppColors {
    // Brand & Primary Colors
    static let primary = Color.indigo
    static let primaryAccent = Color.blue
    static let secondaryAccent = Color.cyan
    static let highlight = Color.purple
    
    // Backgrounds & Surface Depths
    static let background = Color(uiColor: .systemBackground)
    static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
    static let glassSurface = Color.white.opacity(0.12)
    static let cardBackground = Color(uiColor: .tertiarySystemBackground)
    
    // Text Tokens
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textInverse = Color.white
    
    // System & Status
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let shadow = Color.black.opacity(0.15)
    
    // Artistic Gradients
    static let primaryGradient = LinearGradient(
        colors: [primary, highlight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [primaryAccent, secondaryAccent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let glassGradient = LinearGradient(
        colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
