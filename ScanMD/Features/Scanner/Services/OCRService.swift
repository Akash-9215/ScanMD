//
//  OCRService.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import UIKit
import Vision
import PDFKit

/// Protocol defining OCR text recognition functionality on images and PDF files.
protocol OCRServiceProtocol {
    func performOCR(on image: UIImage) async throws -> String
    func performOCR(on pdfURL: URL) async throws -> String
}

/// Vision-powered OCR engine using VNRecognizeTextRequest and PDFKit text extraction.
final class OCRService: OCRServiceProtocol {
    
    /// Asynchronously extracts formatted text from a given UIImage using Apple Vision framework.
    func performOCR(on image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else { return "" }
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }
                
                let fullText = Self.assembleSpatialText(from: observations)
                continuation.resume(returning: fullText)
            }
            
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    /// Reconstructs natural document layout by clustering observations into horizontal lines (top-to-bottom, left-to-right).
    static func assembleSpatialText(from observations: [VNRecognizedTextObservation]) -> String {
        guard !observations.isEmpty else { return "" }
        
        struct LineCluster {
            var y: CGFloat
            var items: [(x: CGFloat, text: String)]
        }
        
        var clusters: [LineCluster] = []
        let yTolerance: CGFloat = 0.012
        
        for obs in observations {
            guard let text = obs.topCandidates(1).first?.string else { continue }
            let box = obs.boundingBox
            let midY = box.midY
            let minX = box.minX
            
            if let idx = clusters.firstIndex(where: { abs($0.y - midY) < yTolerance }) {
                clusters[idx].items.append((x: minX, text: text))
                let count = CGFloat(clusters[idx].items.count)
                clusters[idx].y = (clusters[idx].y * (count - 1) + midY) / count
            } else {
                clusters.append(LineCluster(y: midY, items: [(x: minX, text: text)]))
            }
        }
        
        clusters.sort { $0.y > $1.y }
        
        var formattedLines: [String] = []
        for cluster in clusters {
            let sorted = cluster.items.sorted { $0.x < $1.x }
            let lineText = sorted.map { $0.text }.joined(separator: " ")
            formattedLines.append(lineText)
        }
        
        return formattedLines.joined(separator: "\n")
    }
    
    /// Extracts text from a saved PDF file via PDFText extraction or rendering pages into Vision OCR.
    func performOCR(on pdfURL: URL) async throws -> String {
        guard let document = PDFDocument(url: pdfURL) else { return "" }
        var resultPages: [String] = []
        
        for i in 0..<document.pageCount {
            guard let page = document.page(at: i) else { continue }
            
            // Try extracting raw embedded text first
            if let pageText = page.string, !pageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                resultPages.append("--- Page \(i + 1) ---\n\(pageText)")
            } else {
                // Render page to image and perform Vision OCR
                let pageRect = page.bounds(for: .mediaBox)
                let renderer = UIGraphicsImageRenderer(size: pageRect.size)
                let image = renderer.image { ctx in
                    UIColor.white.set()
                    ctx.fill(pageRect)
                    ctx.cgContext.translateBy(x: 0, y: pageRect.size.height)
                    ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                    page.draw(with: .mediaBox, to: ctx.cgContext)
                }
                
                if let visionText = try? await performOCR(on: image), !visionText.isEmpty {
                    resultPages.append("--- Page \(i + 1) ---\n\(visionText)")
                }
            }
        }
        
        return resultPages.joined(separator: "\n\n")
    }
}
