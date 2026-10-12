//
//  VNDocumentCameraRepresentable.swift
//  ScanMD
//
//  Created by Tanveer Patel on 09/10/26.
//

import SwiftUI
import VisionKit

/// UIViewControllerRepresentable wrapper around VisionKit's VNDocumentCameraViewController.
struct VNDocumentCameraRepresentable: UIViewControllerRepresentable {
    let onFinish: ([UIImage]) -> Void
    let onCancel: () -> Void
    let onError: (Error) -> Void
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onFinish: onFinish, onCancel: onCancel, onError: onError)
    }
    
    /// Coordinator managing VisionKit document scanner delegate callbacks.
    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let onFinish: ([UIImage]) -> Void
        let onCancel: () -> Void
        let onError: (Error) -> Void
        
        init(
            onFinish: @escaping ([UIImage]) -> Void,
            onCancel: @escaping () -> Void,
            onError: @escaping (Error) -> Void
        ) {
            self.onFinish = onFinish
            self.onCancel = onCancel
            self.onError = onError
        }
        
        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFinishWith scan: VNDocumentCameraScan
        ) {
            var images: [UIImage] = []
            for i in 0..<scan.pageCount {
                images.append(scan.imageOfPage(at: i))
            }
            controller.dismiss(animated: true) {
                self.onFinish(images)
            }
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true) {
                self.onCancel()
            }
        }
        
        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFailWithError error: Error
        ) {
            controller.dismiss(animated: true) {
                self.onError(error)
            }
        }
    }
}
