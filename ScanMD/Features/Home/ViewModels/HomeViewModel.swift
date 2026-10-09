//
//  HomeViewModel.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var titleText: String = AppStrings.welcomeTitle
    @Published private(set) var subtitleText: String = AppStrings.welcomeSubtitle
    @Published private(set) var recentDocuments: [SavedDocumentModel] = []
    @Published private(set) var savedCount: Int = 0
    @Published var showScannerSheet: Bool = false
    @Published var showLibrarySheet: Bool = false
    @Published var selectedRecentDoc: SavedDocumentModel?
    
    private let storageService: DocumentStorageService
    private var cancellables = Set<AnyCancellable>()
    
    init(storageService: DocumentStorageService = .shared) {
        self.storageService = storageService
        setupObservers()
        loadData()
    }
    
    /// Reloads recent documents and metric counts
    func loadData() {
        let all = storageService.fetchAllDocuments()
        self.savedCount = all.count
        self.recentDocuments = Array(all.prefix(3))
    }
    
    /// Triggers scanner workflow
    func handlePrimaryAction() {
        showScannerSheet = true
    }
    
    /// Opens library view
    func handleLibraryAction() {
        showLibrarySheet = true
    }
    
    private func setupObservers() {
        NotificationCenter.default.publisher(for: .documentStorageDidChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.loadData()
            }
            .store(in: &cancellables)
    }
}
