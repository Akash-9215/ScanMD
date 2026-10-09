//
//  DocumentLibraryView.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import SwiftUI

/// Main document library screen listing saved PDF documents with search and quick actions.
struct DocumentLibraryView: View {
    @StateObject private var viewModel = DocumentLibraryViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()
                
                if viewModel.filteredDocuments.isEmpty {
                    ContentUnavailableView(
                        AppStrings.Library.empty,
                        systemImage: AppIcons.folder,
                        description: Text(AppStrings.Library.emptySubtitle)
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: AppSpacing.md) {
                            ForEach(viewModel.filteredDocuments) { doc in
                                DocumentRowCard(
                                    document: doc,
                                    onTap: { viewModel.selectedDocument = doc },
                                    onDelete: { viewModel.deleteDocument(doc) }
                                )
                            }
                        }
                        .padding(AppSpacing.lg)
                    }
                    .searchable(text: $viewModel.searchText)
                }
            }
            .navigationTitle(AppStrings.Library.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: AppIcons.xmark)
                            .foregroundStyle(AppColors.textPrimary)
                    }
                }
            }
            .onAppear(perform: viewModel.loadDocuments)
            .fullScreenCover(item: $viewModel.selectedDocument) { doc in
                let scannedDoc = ScannedDocumentModel(
                    title: doc.title,
                    pages: [],
                    pdfURL: doc.fileURL
                )
                PDFPreviewView(document: scannedDoc)
            }
        }
    }
}

#Preview {
    DocumentLibraryView()
}
