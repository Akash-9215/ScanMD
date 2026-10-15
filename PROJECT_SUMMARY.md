# ScanMD Project Summary & Architecture Blueprint

> **Notice for AI Agents**: This document is the single source of truth for ScanMD project structure, architecture, completed components, design system tokens, and upcoming feature roadmap. Always read and update this document when modifying or adding features to avoid unnecessary project re-analysis.

---

## 1. Project Overview & Tech Stack
- **App Name**: ScanMD
- **Platform**: iOS 17.0+ (SwiftUI)
- **Primary Goals**: High-performance document scanning (via VisionKit), image processing, OCR text recognition (via Vision & PDFKit), medical document verification, structured lab test alignment, and instant multi-page PDF generation & storage management.
- **Tech Stack**:
  - **Framework**: SwiftUI (declarative UI with `@Observable` / `ObservableObject`)
  - **Scanning**: Full-Screen Camera Interface + VisionKit (`VNDocumentCameraViewController`)
  - **OCR Engine**: Vision Framework (`VNRecognizeTextRequest`) + `PDFKit` text extraction
  - **Medical Classification & Pathology Engine**: Natural Language NLP + Clinical term signal heuristics classifier, structured diagnostic extractor, and expert pathologist recommendation engine
  - **PDF Processing**: PDFKit (`PDFDocument`, `PDFPage`, `UIGraphicsPDFRenderer`)
  - **Architecture**: Feature-First MVVM (Strict Separation of Concerns, Zero UI Business Logic)

---

## 2. Directory & Component Index

```
ScanMD/
├── Core/
│   ├── DesignSystem/
│   │   ├── AppColors.swift                 # Centralized color tokens & artistic gradients
│   │   ├── AppIcons.swift                  # Centralized SF Symbols enum catalog
│   │   ├── AppSpacing.swift               # Fixed spacing, radii, & element sizing tokens
│   │   ├── AppTypography.swift            # Font styles & appTypography view modifier
│   │   └── Components/
│   │       ├── GlassCard.swift             # Glassmorphic card container component
│   │       ├── PrimaryButton.swift         # Reusable glowing gradient button component
│   │       ├── AppHeaderView.swift         # Reusable navigation header bar component
│   │       ├── StatBadgeView.swift         # Reusable metric card badge component
│   │       ├── HeroScannerBadge.swift      # Concentric pulsing hero badge component with anchor centering
│   │       └── IconButton.swift            # Reusable glass icon button with micro-animations
│   └── Localization/
│       ├── AppStrings.swift                # String catalog wrapper (zero hardcoded strings)
│       └── Localizable.xcstrings           # Xcode String Catalog for internationalization
└── Features/
    ├── Home/
    │   ├── ViewModels/
    │   │   └── HomeViewModel.swift         # Dashboard logic, recent scans & observer bindings
    │   └── Views/
    │       └── HomeView.swift              # Redesigned artist-grade dashboard with stats & recent scans
    ├── Library/
    │   ├── Services/
    │   │   └── DocumentStorageService.swift # Local PDF storage service & NotificationCenter updates
    │   ├── ViewModels/
    │   │   └── DocumentLibraryViewModel.swift # Saved documents list observer, search & deletion
    │   └── Views/
    │       ├── DocumentRowCard.swift       # Reusable card component for document list item
    │       └── DocumentLibraryView.swift   # Saved PDF documents library sheet with search
    ├── MedicalAnalysis/
    │   ├── Models/
    │   │   ├── MedicalClassifierModel.mlpackage # Apple Core ML neural network package compiled from PyTorch
    │   │   ├── MedicalTestItem.swift       # Model for individual diagnostic lab test parameters & status
    │   │   └── MedicalReportModel.swift    # Clinical model containing patient header, lab table, & pathologist insights
    │   ├── Services/
    │   │   ├── MedicalFeatureExtractor.swift # 20-dimensional normalized structural/clinical feature extractor
    │   │   ├── CoreMLMedicalClassifierService.swift # Apple Neural Engine/GPU accelerated Core ML classifier
    │   │   ├── MedicalDocumentClassifierService.swift # NaturalLanguage NLEmbedding semantic AI classifier fallback
    │   │   ├── MedicalPredictiveDiagnosticEngine.swift # Multi-organ clinical AI predictive reasoning engine
    │   │   ├── MedicalOCRParserService.swift # Universal clinical OCR parsing engine for patient metadata & lab tables
    │   │   └── MedicalAnalysisService.swift # Deep clinical coordinator extracting patient info, lab tables, & pathologist impressions
    │   ├── ViewModels/
    │   │   └── MedicalAnalysisViewModel.swift # State manager orchestrating document analysis workflow
    │   └── Views/
    │       ├── MedicalTestTable.swift      # Formatted, aligned diagnostic lab test results table with status badges
    │       └── MedicalReportView.swift     # Complete medical report view showing patient header, test table, & recommendations
    └── Scanner/
        ├── Models/
        │   ├── ScannedPageModel.swift      # Model for individual captured pages
        │   └── ScannedDocumentModel.swift  # Model for complete document & PDF URL
        ├── Services/
        │   ├── PDFGeneratorService.swift   # Service rendering pages into multi-page PDF files
        │   └── OCRService.swift            # Vision & PDFKit text recognition engine for images and PDF files
        ├── ViewModels/
        │   └── DocumentScannerViewModel.swift # Full-screen scanner workflow & state management
        └── Views/
            ├── VNDocumentCameraRepresentable.swift # VisionKit camera controller wrapper
            ├── DocumentScannerView.swift   # Custom full-screen document scanner UI
            ├── PDFKitViewRepresentable.swift # PDFKit viewer wrapper
            ├── PDFPreviewView.swift        # Full-screen PDF previewer with Save status, Medical Report, & OCR action
            └── OCRResultView.swift         # Recognized text viewer sheet with Medical Analysis shortcut & copy toast
ml/
├── model_def.py                            # PyTorch MedicalClassifierNet architecture & 20-dim feature definitions
├── train_medical_classifier.py             # Model training loop & coremltools export pipeline (.mlpackage)
├── requirements.txt                        # Python ML dependencies (torch, coremltools, numpy)
└── README.md                               # ML architecture, training guide & dataset documentation
ScanMDTests/
├── CoreMLMedicalClassifierTests.swift       # On-device Core ML neural classifier unit tests (5 test cases)
├── SpatialLayoutOCRTests.swift             # Spatial layout line reconstruction & column clustering tests
├── MedicalOCRParserTests.swift             # Universal clinical OCR parsing & lab table extraction tests
├── MedicalClassifierTests.swift            # NaturalLanguage semantic AI classifier unit tests
├── PredictiveDiagnosticEngineTests.swift   # On-device predictive diagnostic & pathologist reasoning tests
├── MedicalReportModelTests.swift           # Model structures and status mapping tests
└── EndToEndScanIntegrationTests.swift      # End-to-end full document scanning & OCR pipeline integration tests
```

---

## 3. Design System Tokens Summary

### Color Tokens (`AppColors`)
- `primary` (Indigo), `primaryAccent` (Blue), `secondaryAccent` (Cyan), `highlight` (Purple)
- `background` (System background), `cardBackground` (Tertiary background), `glassSurface` (Opacity white)
- `primaryGradient`, `accentGradient`, `glassGradient`

### Spacing & Corner Radii (`AppSpacing` & `AppRadius`)
- Spacing: `xxs` (2pt), `xs` (4pt), `sm` (8pt), `md` (12pt), `lg` (16pt), `xl` (24pt), `xxl` (32pt), `xxxl` (48pt)
- Radii: `sm` (4pt), `md` (8pt), `lg` (12pt), `xl` (16pt), `pill` (999pt)

### Reusable Components Catalog
- `GlassCard`, `PrimaryButton`, `AppHeaderView`, `StatBadgeView`, `HeroScannerBadge`, `IconButton`, `DocumentRowCard`, `MedicalTestTable`

---

## 4. Feature Modules & Status

| Feature | Components / Files | Status | Description |
| :--- | :--- | :--- | :--- |
| **Design System** | `AppColors`, `AppTypography`, `AppSpacing`, `AppIcons`, `GlassCard`, `PrimaryButton`, `AppHeaderView`, `StatBadgeView`, `HeroScannerBadge`, `IconButton` | ✅ Complete | Reusable UI components & design system tokens |
| **Localization** | `AppStrings`, `Localizable.xcstrings` | ✅ Complete | Centralized localized string catalog (Zero hardcoding) |
| **Home Dashboard** | `HomeView`, `HomeViewModel` | ✅ Complete | Redesigned artist-grade dashboard with hero card, stat counters, and recent scans |
| **Document Scanning** | `DocumentScannerView`, `VNDocumentCameraRepresentable`, `DocumentScannerViewModel` | ✅ Complete | Full-screen camera scanner interface with VisionKit, temporary preview rendering & explicit user saving |
| **PDF Generation** | `PDFGeneratorService`, `PDFKitViewRepresentable`, `PDFPreviewView` | ✅ Complete | Multi-page PDF renderer & full-screen previewer with saved status badge |
| **OCR Text Recognition** | `OCRService`, `OCRResultView` | ✅ Complete | Spatial layout-aware Vision & PDFKit accurate text extraction preserving multi-column tables |
| **Medical Document Verification & Analysis** | `MedicalClassifierModel`, `CoreMLMedicalClassifierService`, `MedicalFeatureExtractor`, `MedicalDocumentClassifierService`, `MedicalAnalysisService`, `MedicalAnalysisViewModel`, `MedicalReportView`, `MedicalTestTable` | ✅ Complete | Hardware-accelerated Apple Core ML neural document classifier trained on 138 real clinical lab reports + 12 synthetic reports with Softmax calibration, strict separation of high-level report Test Type (e.g. Complete Blood Count, Lipid Profile) from individual Test Names inside tabular results, and pathologist reasoning |
| **Document Library** | `DocumentStorageService`, `DocumentLibraryViewModel`, `DocumentLibraryView`, `DocumentRowCard` | ✅ Complete | Persistent storage with `documentStorageDidChange` observer updates & search |
| **Unit & Integration Test Suite** | `ScanMDTests` (`CoreMLMedicalClassifierTests`, `SpatialLayoutOCRTests`, `MedicalOCRParserTests`, `MedicalClassifierTests`, `PredictiveDiagnosticEngineTests`, `MedicalReportModelTests`, `EndToEndScanIntegrationTests`) | ✅ Complete | Automated XCTest suite wired to Xcode Project Navigator and Test Navigator (19/19 passing) |

---

## 5. Development Guidelines Checklist
- [x] Maximum 200 lines per file (Strict adherence).
- [x] Zero hardcoded strings (All strings in `Localizable.xcstrings` & `AppStrings`).
- [x] Zero hardcoded colors, fonts, margins, or radii.
- [x] Brief 1–2 line docstring header on all types/components.
- [x] `#Preview` block present in all SwiftUI Views.
- [x] Keep `PROJECT_SUMMARY.md` updated after every major file/feature change.
- [x] Strict Git Workflow & Branching Strategy: No direct commits/pushes to `main`; use `feature/` or `fix/` branches, no auto-pushing.

