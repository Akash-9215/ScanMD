//
//  ScannedPageModel.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import UIKit

/// Represents a single captured scanned page with image data and page index.
struct ScannedPageModel: Identifiable, Equatable {
    let id: UUID
    let image: UIImage
    let pageIndex: Int
    let dateCaptured: Date
    
    init(id: UUID = UUID(), image: UIImage, pageIndex: Int, dateCaptured: Date = Date()) {
        self.id = id
        self.image = image
        self.pageIndex = pageIndex
        self.dateCaptured = dateCaptured
    }
}
