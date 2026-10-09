//
//  DocumentLibraryViewModel.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import SwiftUI
import Combine

@MainActor
final class DocumentLibraryViewModel: ObservableObject {
    @Published private(set) var savedDocuments: [SavedDocumentModel] = []
    @Published var searchText: String = ""
    @Published var selectedDocument: SavedDocumentModel?
    
    private let storageService: DocumentStorageService
    private var cancellables = Set<AnyCancellable>()
    
    init(storageService: DocumentStorageService = .shared) {
        self.storageService = storageService
        setupNotificationObservers()
        loadDocuments()
    }
    
    /// Loads saved document items from storage directory.
    func loadDocuments() {
        self.savedDocuments = storageService.fetchAllDocuments()
    }
    
    /// Filtered document list matching active search query.
    var filteredDocuments: [SavedDocumentModel] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return savedDocuments
        }
        return savedDocuments.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    /// Permanently deletes a saved document file.
    func deleteDocument(_ item: SavedDocumentModel) {
        storageService.deleteDocument(item)
        loadDocuments()
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.publisher(for: .documentStorageDidChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.loadDocuments()
            }
            .store(in: &cancellables)
    }
}
