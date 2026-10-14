# ScanMD Machine Learning Pipeline: Medical Document Neural Classifier

This directory contains the Python training pipeline, neural network architecture, and Apple Core ML model export tools for ScanMD.

---

## 1. Overview
The model classifies document OCR text into 6 diagnostic and non-medical categories:
1. `Non-Medical` (Receipts, invoices, boarding passes, software code, menus)
2. `Lipid Profile` (Total Cholesterol, HDL, LDL, Triglycerides)
3. `Complete Blood Count` (Hemoglobin, WBC, Platelets, Hematocrit)
4. `Liver Function` (Bilirubin, SGOT, SGPT, ALP, Protein, Albumin)
5. `Renal Function` (Creatinine, Urea, BUN, Uric Acid, eGFR)
6. `General Medical` (Prescriptions, Cardiology ECG, Clinical diagnostic notes)

---

## 2. Architecture & Feature Vector
- **Input**: 20-dimensional normalized feature vector extracted from raw OCR text:
  - Lexical medical & non-medical keyword densities
  - Laboratory measurement units (`mg/dL`, `g/dL`, `mmol/L`, `cells/cumm`)
  - Numeric reference ranges (`10 - 50`, `< 200`)
  - Clinical patient header markers
  - Organ-specific markers (Lipid, CBC, LFT, KFT, Cardiology, Rx)
  - Layout structure & table line density
- **Network**: 3-layer deep neural network with ReLU activations in PyTorch (`MedicalClassifierNet`).
- **Core ML Export**: Exported via `coremltools` as a native `.mlpackage` with `ClassifierConfig` providing class labels and calibrated probability distributions.

---

## 3. Training & Export Command
To retrain and export the model:
```bash
python3 ml/train_medical_classifier.py
```
This saves `MedicalClassifierModel.mlpackage` into `ScanMD/Features/MedicalAnalysis/Models/`.
