//
//  AppTypography.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import SwiftUI

enum AppTypography {
    static let largeTitle = Font.largeTitle.bold()
    static let title = Font.title.weight(.semibold)
    static let title2 = Font.title2.weight(.semibold)
    static let title3 = Font.title3.weight(.medium)
    static let headline = Font.headline
    static let subheadline = Font.subheadline
    static let body = Font.body
    static let callout = Font.callout
    static let footnote = Font.footnote
    static let caption = Font.caption
}

struct AppTypographyModifier: ViewModifier {
    let font: Font
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundStyle(color)
    }
}

extension View {
    func appTypography(_ font: Font, color: Color = AppColors.textPrimary) -> some View {
        modifier(AppTypographyModifier(font: font, color: color))
    }
}
