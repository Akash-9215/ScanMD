//
//  MedicalTestTable.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import SwiftUI

/// Reusable table component rendering formatted clinical diagnostic lab test parameters.
struct MedicalTestTable: View {
    let testItems: [MedicalTestItem]
    
    var body: some View {
        VStack(spacing: AppSpacing.zero) {
            if testItems.isEmpty {
                Text("No tabular diagnostic parameters detected in this document.")
                    .appTypography(AppTypography.subheadline, color: AppColors.textSecondary)
                    .padding(AppSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                // Header Row
                HStack {
                    Text(AppStrings.Medical.colTest)
                        .appTypography(AppTypography.caption, color: AppColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(AppStrings.Medical.colResult)
                        .appTypography(AppTypography.caption, color: AppColors.textSecondary)
                        .frame(width: 75, alignment: .trailing)
                    
                    Text(AppStrings.Medical.colRange)
                        .appTypography(AppTypography.caption, color: AppColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Text(AppStrings.Medical.colStatus)
                        .appTypography(AppTypography.caption, color: AppColors.textSecondary)
                        .frame(width: 60, alignment: .center)
                }
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.sm)
                .background(AppColors.glassSurface)
                
                Divider()
                
                // Lab Items Rows
                ForEach(Array(testItems.enumerated()), id: \.element.id) { index, item in
                    HStack(spacing: AppSpacing.xs) {
                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            Text(item.testName)
                                .appTypography(AppTypography.subheadline, color: AppColors.textPrimary)
                                .minimumScaleFactor(0.85)
                                .lineLimit(2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(item.unit.isEmpty ? item.resultValue : "\(item.resultValue) \(item.unit)")
                            .appTypography(AppTypography.callout, color: item.status == .normal ? AppColors.textPrimary : AppColors.warning)
                            .frame(width: 75, alignment: .trailing)
                            .minimumScaleFactor(0.85)
                            .lineLimit(1)
                        
                        Text(item.referenceRange)
                            .appTypography(AppTypography.caption, color: AppColors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .minimumScaleFactor(0.75)
                            .lineLimit(2)
                        
                        statusBadge(for: item.status)
                            .frame(width: 60, alignment: .center)
                    }
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.sm)
                    .background(index % 2 == 0 ? AppColors.cardBackground : AppColors.background)
                    
                    if index < testItems.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md)
                .stroke(AppColors.glassSurface, lineWidth: 1)
        )
    }
    
    private func statusBadge(for status: MedicalTestStatus) -> some View {
        let text: String
        let color: Color
        
        switch status {
        case .normal:
            text = "Normal"
            color = AppColors.success
        case .abnormalHigh:
            text = "HIGH"
            color = AppColors.warning
        case .abnormalLow:
            text = "LOW"
            color = AppColors.warning
        case .critical:
            text = "CRITICAL"
            color = AppColors.error
        }
        
        return Text(text)
            .appTypography(AppTypography.caption, color: AppColors.textInverse)
            .padding(.horizontal, AppSpacing.xs)
            .padding(.vertical, 2)
            .background(color)
            .clipShape(Capsule())
    }
}

#Preview {
    let samples = [
        MedicalTestItem(testName: "Hemoglobin (Hb)", resultValue: "11.2", unit: "g/dL", referenceRange: "13.0 - 17.0", status: .abnormalLow),
        MedicalTestItem(testName: "WBC Count", resultValue: "7,800", unit: "/cumm", referenceRange: "4,000 - 11,000", status: .normal)
    ]
    MedicalTestTable(testItems: samples)
        .padding()
}

private extension AppSpacing {
    static let zero: CGFloat = 0
}

