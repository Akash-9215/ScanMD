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
    @Published private(set) var isProcessing: Bool = false
    @Published private(set) var isAnimatingHero: Bool = false
    
    /// Prepares view animations on initial screen appearance
    func onAppear() {
        isAnimatingHero = true
    }
    
    /// Triggers asynchronous document scanning task with animated feedback
    func handlePrimaryAction() {
        isProcessing = true
        Task {
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            self.isProcessing = false
        }
    }
}
