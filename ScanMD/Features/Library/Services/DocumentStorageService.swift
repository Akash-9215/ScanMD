//
//  DocumentStorageService.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import Foundation

extension Notification.Name {
    static let documentStorageDidChange = Notification.Name("ScanMD_documentStorageDidChange")
}

/// Model representing a saved PDF document stored in local storage library.
struct SavedDocumentModel: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let fileURLPath: String
    let dateCreated: Date
    let pageCount: Int
    let fileSizeString: String
    
    var fileURL: URL {
        URL(fileURLWithPath: fileURLPath)
    }
}

/// Persistent file manager service for saving, loading, and managing PDF documents.
final class DocumentStorageService {
    static let shared = DocumentStorageService()
    private let storageDirectory: URL
    private let indexFileURL: URL
    
    private init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.storageDirectory = docs.appendingPathComponent("ScanMD_PDFs", isDirectory: true)
        self.indexFileURL = storageDirectory.appendingPathComponent("documents_index.json")
        
        try? FileManager.default.createDirectory(at: storageDirectory, withIntermediateDirectories: true)
    }
    
    /// Persists a generated PDF file into permanent storage directory.
    func saveDocument(from temporaryURL: URL, title: String, pageCount: Int) throws -> SavedDocumentModel {
        let destinationFileName = "\(UUID().uuidString).pdf"
        let destinationURL = storageDirectory.appendingPathComponent(destinationFileName)
        
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        try FileManager.default.copyItem(at: temporaryURL, to: destinationURL)
        
        let attributes = try? FileManager.default.attributesOfItem(atPath: destinationURL.path)
        let sizeInBytes = (attributes?[.size] as? Int64) ?? 0
        let formattedSize = ByteCountFormatter.string(fromByteCount: sizeInBytes, countStyle: .file)
        
        let savedItem = SavedDocumentModel(
            id: UUID(),
            title: title,
            fileURLPath: destinationURL.path,
            dateCreated: Date(),
            pageCount: pageCount,
            fileSizeString: formattedSize
        )
        
        var currentItems = fetchAllDocuments()
        currentItems.insert(savedItem, at: 0)
        saveIndex(items: currentItems)
        NotificationCenter.default.post(name: .documentStorageDidChange, object: nil)
        return savedItem
    }
    
    /// Returns all saved document models ordered by creation date descending.
    func fetchAllDocuments() -> [SavedDocumentModel] {
        guard let data = try? Data(contentsOf: indexFileURL),
              let items = try? JSONDecoder().decode([SavedDocumentModel].self, from: data) else {
            return []
        }
        return items.filter { FileManager.default.fileExists(atPath: $0.fileURLPath) }
    }
    
    /// Removes a document file and index record permanently.
    func deleteDocument(_ item: SavedDocumentModel) {
        try? FileManager.default.removeItem(atPath: item.fileURLPath)
        var items = fetchAllDocuments()
        items.removeAll { $0.id == item.id }
        saveIndex(items: items)
        NotificationCenter.default.post(name: .documentStorageDidChange, object: nil)
    }
    
    private func saveIndex(items: [SavedDocumentModel]) {
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: indexFileURL)
        }
    }
}
