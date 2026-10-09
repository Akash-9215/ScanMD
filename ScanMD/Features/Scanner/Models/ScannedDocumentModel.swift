//
//  ScannedDocumentModel.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import Foundation
import UIKit

/// Models a complete scanned document containing multiple scanned pages and optional PDF file URL.
struct ScannedDocumentModel: Identifiable, Equatable {
    let id: UUID
    var title: String
    var pages: [ScannedPageModel]
    let dateCreated: Date
    var pdfURL: URL?
    
    init(
        id: UUID = UUID(),
        title: String,
        pages: [ScannedPageModel],
        dateCreated: Date = Date(),
        pdfURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.pages = pages
        self.dateCreated = dateCreated
        self.pdfURL = pdfURL
    }
}
