//
//  SpatialLayoutOCRTests.swift
//  ScanMDTests
//
//  Created by Tanveer Patel on 12/10/26.
//

import XCTest
import Vision
@testable import ScanMD

/// Unit tests validating spatial bounding box layout reconstruction for multi-column documents and lab tables.
final class SpatialLayoutOCRTests: XCTestCase {
    
    func testMultiColumnTableLineAssembly() {
        // Simulating scrambled bounding boxes from Vision OCR for a 2-row, 3-column lab table
        // Row 1 (y ≈ 0.65): "Total Cholesterol" (x=0.1), "268 mg/dL" (x=0.4), "[HIGH]" (x=0.8)
        // Row 2 (y ≈ 0.60): "Triglycerides" (x=0.1), "245 mg/dL" (x=0.4), "[HIGH]" (x=0.8)
        
        let obs1 = MockRecognizedObservation(string: "Total Cholesterol", minX: 0.1, midY: 0.651)
        let obs2 = MockRecognizedObservation(string: "[HIGH]", minX: 0.8, midY: 0.649)
        let obs3 = MockRecognizedObservation(string: "268 mg/dL", minX: 0.4, midY: 0.650)
        let obs4 = MockRecognizedObservation(string: "Triglycerides", minX: 0.1, midY: 0.601)
        let obs5 = MockRecognizedObservation(string: "245 mg/dL", minX: 0.4, midY: 0.600)
        let obs6 = MockRecognizedObservation(string: "[HIGH]", minX: 0.8, midY: 0.599)
        
        // Pass in scrambled observation order (column clusters)
        let scrambled = [obs1, obs4, obs3, obs5, obs2, obs6]
        let assembled = SpatialLayoutHelper.assemble(items: scrambled)
        
        let lines = assembled.components(separatedBy: "\n")
        XCTAssertEqual(lines.count, 2)
        XCTAssertEqual(lines[0], "Total Cholesterol 268 mg/dL [HIGH]")
        XCTAssertEqual(lines[1], "Triglycerides 245 mg/dL [HIGH]")
    }
}

/// Helper struct for unit testing spatial layout algorithms
struct MockRecognizedObservation {
    let string: String
    let minX: CGFloat
    let midY: CGFloat
}

struct SpatialLayoutHelper {
    static func assemble(items: [MockRecognizedObservation]) -> String {
        guard !items.isEmpty else { return "" }
        struct LineCluster {
            var y: CGFloat
            var items: [(x: CGFloat, text: String)]
        }
        var clusters: [LineCluster] = []
        let yTolerance: CGFloat = 0.012
        for item in items {
            let midY = item.midY
            let minX = item.minX
            if let idx = clusters.firstIndex(where: { abs($0.y - midY) < yTolerance }) {
                clusters[idx].items.append((x: minX, text: item.string))
                let count = CGFloat(clusters[idx].items.count)
                clusters[idx].y = (clusters[idx].y * (count - 1) + midY) / count
            } else {
                clusters.append(LineCluster(y: midY, items: [(x: minX, text: item.string)]))
            }
        }
        clusters.sort { $0.y > $1.y }
        return clusters.map { cluster in
            cluster.items.sorted { $0.x < $1.x }.map { $0.text }.joined(separator: " ")
        }.joined(separator: "\n")
    }
}
