//
//  PDFGeneratorService.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import UIKit
import PDFKit

/// Protocol defining PDF document creation service.
protocol PDFGeneratorServiceProtocol {
    func generatePDF(from pages: [ScannedPageModel], title: String) async throws -> URL
}

/// Service responsible for rendering scanned images into standardized multi-page PDF files.
final class PDFGeneratorService: PDFGeneratorServiceProtocol {
    
    /// Renders array of scanned pages into a PDF file saved in local temporary directory.
    func generatePDF(from pages: [ScannedPageModel], title: String) async throws -> URL {
        return try await Task.detached(priority: .userInitiated) {
            let pdfMetaData = [
                kCGPDFContextTitle as String: title,
                kCGPDFContextCreator as String: AppStrings.appName
            ]
            let format = UIGraphicsPDFRendererFormat()
            format.documentInfo = pdfMetaData
            
            // Standard A4 paper size dimensions in points (595.2 x 841.8)
            let pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)
            let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
            
            let data = renderer.pdfData { context in
                for page in pages {
                    context.beginPage()
                    let image = page.image
                    let fittedRect = self.calculateFittedRect(for: image.size, inside: pageRect)
                    image.draw(in: fittedRect)
                }
            }
            
            let fileName = "\(title.replacingOccurrences(of: " ", with: "_"))_\(UUID().uuidString.prefix(6)).pdf"
            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            try data.write(to: outputURL)
            return outputURL
        }.value
    }
    
    /// Calculates aspect-fit rect for an image inside standard PDF page boundaries.
    private func calculateFittedRect(for imageSize: CGSize, inside pageRect: CGRect) -> CGRect {
        let margin: CGFloat = AppSpacing.lg
        let maxRect = pageRect.insetBy(dx: margin, dy: margin)
        
        let widthRatio = maxRect.width / imageSize.width
        let heightRatio = maxRect.height / imageSize.height
        let scale = min(widthRatio, heightRatio)
        
        let scaledWidth = imageSize.width * scale
        let scaledHeight = imageSize.height * scale
        
        let x = maxRect.minX + (maxRect.width - scaledWidth) / 2
        let y = maxRect.minY + (maxRect.height - scaledHeight) / 2
        
        return CGRect(x: x, y: y, width: scaledWidth, height: scaledHeight)
    }
}
