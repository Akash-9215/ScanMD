# ScanMD Machine Learning Pipeline: Medical Document Neural Classifier

This directory contains the Python training pipeline, neural network architecture, and Apple Core ML model export tools for ScanMD.

---

## 1. Overview
The model classifies document OCR text into 12 diagnostic and non-medical categories:
1. `Non-Medical` (Receipts, invoices, boarding passes, software code, menus, tickets)
2. `Complete Blood Count` (Hemoglobin, WBC, Platelets, Hematocrit, ESR, Blood Smear, Coagulation)
3. `Lipid Profile` (Total Cholesterol, HDL, LDL, Triglycerides, VLDL)
4. `Liver Function` (Bilirubin, SGOT, SGPT, ALP, Protein, Albumin, Globulin, GGT)
5. `Renal Function` (Creatinine, Urea, BUN, Uric Acid, eGFR, Microalbumin)
6. `Diabetology & Endocrine` (Glucose, HbA1c, Thyroid TFT, Insulin, Hormonal & Nutritional Assays)
7. `Urinalysis & Body Fluids` (Routine Urinalysis, 24h Urine Protein, CSF, Synovial, Pleural, Stool)
8. `Microbiology & Serology` (Cultures & Sensitivity, Dengue, Malaria, HIV, Hepatitis, Widal, VDRL)
9. `Histopathology & Cytology` (Biopsies: Skin, Lymph node, GI, Bone marrow; Pap smear, FNAC)
10. `Radiology & Imaging` (X-Rays: Chest/Spine/Knee/Abdomen; CT, MRI, Ultrasound USG, Echocardiogram)
11. `Cardiology & Functional Diagnostics` (ECG / EKG, Holter, Treadmill TMT, EEG, EMG, NCS, PFT/Spirometry)
12. `General Clinical Report` (Prescriptions, Clinical consultations, Discharge summaries, General notes)

---

## 2. Dataset Composition
- **177 New Sample Reports (`SampaleReport/`)**:
  - Complete PDF document extractions matching `medical_reports_dataset.json` across 7 major clinical categories and 59 specific report types.
- **138 Real Clinic Reports (`real_clinic_samples.json`)**: Real hospital and laboratory reports.
- **12 Synthetic Reports (`synthetic_reports.json`)**: Curated multi-modal clinical benchmark reports.
- **25+ Non-Medical Negative Samples**: Diverse receipts, code snippets, bills, boarding passes, and technical data.
- **Total Augmented Training Set**: 1,760 samples with noise augmentation.

---

## 3. Architecture & Feature Vector
- **Input**: 28-dimensional normalized feature vector extracted from raw OCR text:
  - Lexical medical & non-medical keyword densities
  - Laboratory measurement units (`mg/dL`, `g/dL`, `mmol/L`, `cells/cumm`, `CFU/mL`, `U/L`)
  - Numeric reference ranges (`10 - 50`, `< 200`, `3.5 - 5.0`)
  - Clinical patient header markers (`Patient Name`, `Age/Sex`, `Specimen`, `Lab ID`)
  - Category-specific markers (CBC, Lipid, LFT, KFT, Diabetes, Endocrine, Microbiology, Histopathology, Body Fluids, Radiology, Cardio/Functional, Discharge)
  - Layout structure, table lines density, upper/numeric ratios
  - Pathologist/signatory & facility detection
  - Diagnostic impression / clinical conclusion markers
- **Network**: 3-layer deep neural network with ReLU activations and Softmax probability calibration (`MedicalClassifierNet`).
- **Core ML Export**: Exported via `coremltools` as a native `.mlpackage` with `ClassifierConfig` providing class labels and calibrated probabilities.

---

## 4. Training & Export Command
To retrain and export the model:
```bash
.venv/bin/python ml/train_medical_classifier.py
```
This saves `MedicalClassifierModel.mlpackage` into `ScanMD/Features/MedicalAnalysis/Models/`.
