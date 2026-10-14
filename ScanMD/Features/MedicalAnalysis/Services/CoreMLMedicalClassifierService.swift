//
//  CoreMLMedicalClassifierService.swift
//  ScanMD
//
//  Created by Tanveer Patel on 14/10/26.
//

import CoreML
import Foundation

/// High-performance on-device Core ML neural classifier inferencing medical document categories with ANE/GPU acceleration.
final class CoreMLMedicalClassifierService: MedicalDocumentClassifierProtocol {
    private let coreMLModel: MedicalClassifierModel?
    private let fallbackService: MedicalDocumentClassifierProtocol
    
    init(
        model: MedicalClassifierModel? = nil,
        fallbackService: MedicalDocumentClassifierProtocol = MedicalDocumentClassifierService()
    ) {
        if let providedModel = model {
            self.coreMLModel = providedModel
        } else {
            let config = MLModelConfiguration()
            config.computeUnits = .all
            self.coreMLModel = try? MedicalClassifierModel(configuration: config)
        }
        self.fallbackService = fallbackService
    }
    
    /// Classifies document text using on-device PyTorch trained Core ML neural network with fallback.
    func classifyDocument(from ocrText: String) -> (isMedical: Bool, confidence: Double, reportType: String) {
        let trimmed = ocrText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return (false, 0.0, "Empty Document")
        }
        
        guard let model = coreMLModel,
              let features = MedicalFeatureExtractor.extractFeatures(from: ocrText) else {
            return fallbackService.classifyDocument(from: ocrText)
        }
        
        do {
            let input = MedicalClassifierModelInput(features: features)
            let output = try model.prediction(input: input)
            
            let predictedLabel = output.classLabel
            let probabilities = output.classLabel_probs
            
            let isMedical = (predictedLabel != "Non-Medical")
            let nonMedicalProb = probabilities["Non-Medical"] ?? 0.0
            let medicalConfidence = min(0.99, max(0.1, 1.0 - nonMedicalProb))
            
            let finalConfidence = isMedical ? medicalConfidence : (probabilities["Non-Medical"] ?? 0.95)
            let finalReportType = isMedical ? predictedLabel : "Non-Medical Document"
            
            return (isMedical, finalConfidence, finalReportType)
        } catch {
            return fallbackService.classifyDocument(from: ocrText)
        }
    }
}
