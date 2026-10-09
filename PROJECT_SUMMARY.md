# ScanMD Project Summary & Architecture Blueprint

> **Notice for AI Agents**: This document is the single source of truth for ScanMD project structure, architecture, completed components, design system tokens, and upcoming feature roadmap. Always read and update this document when modifying or adding features to avoid unnecessary project re-analysis.

---

## 1. Project Overview & Tech Stack
- **App Name**: ScanMD
- **Platform**: iOS 17.0+ (SwiftUI)
- **Primary Goals**: High-performance document scanning (via VisionKit), image processing, OCR text recognition (via Vision & PDFKit), and instant multi-page PDF generation & storage management.
- **Tech Stack**:
  - **Framework**: SwiftUI (declarative UI with `@Observable` / `ObservableObject`)
  - **Scanning**: Full-Screen Camera Interface + VisionKit (`VNDocumentCameraViewController`)
  - **OCR Engine**: Vision Framework (`VNRecognizeTextRequest`) + `PDFKit` text extraction
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
    └── Scanner/
        ├── Models/
        │   ├── ScannedPageModel.swift      # Model for individual captured pages
        │   └── ScannedDocumentModel.swift  # Model for complete document & PDF URL
        ├── Services/
        │   ├── PDFGeneratorService.swift   # Service rendering pages into multi-page PDF files
        │   └── OCRService.swift            # Vision & PDFKit text recognition engine for images and PDF files
        ├── ViewModels/
        │   └── DocumentScannerViewModel.swift # Full-screen scanner workflow, auto-save & state management
        └── Views/
            ├── VNDocumentCameraRepresentable.swift # VisionKit camera controller wrapper
            ├── DocumentScannerView.swift   # Custom full-screen document scanner UI
            ├── PDFKitViewRepresentable.swift # PDFKit viewer wrapper
            ├── PDFPreviewView.swift        # Full-screen PDF previewer with Save status & OCR action
            └── OCRResultView.swift         # Recognized text viewer sheet with copy toast
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
- `GlassCard`, `PrimaryButton`, `AppHeaderView`, `StatBadgeView`, `IconButton`, `DocumentRowCard`

---

## 4. Feature Modules & Status

| Feature | Components / Files | Status | Description |
| :--- | :--- | :--- | :--- |
| **Design System** | `AppColors`, `AppTypography`, `AppSpacing`, `AppIcons`, `GlassCard`, `PrimaryButton`, `AppHeaderView`, `StatBadgeView`, `IconButton` | ✅ Complete | Reusable UI components & design system tokens |
| **Localization** | `AppStrings`, `Localizable.xcstrings` | ✅ Complete | Centralized localized string catalog (Zero hardcoding) |
| **Home Dashboard** | `HomeView`, `HomeViewModel` | ✅ Complete | Redesigned artist-grade dashboard with hero card, stat counters, and recent scans |
| **Document Scanning** | `DocumentScannerView`, `VNDocumentCameraRepresentable`, `DocumentScannerViewModel` | ✅ Complete | Full-screen camera scanner interface with VisionKit, temporary preview rendering & explicit user saving |
| **PDF Generation** | `PDFGeneratorService`, `PDFKitViewRepresentable`, `PDFPreviewView` | ✅ Complete | Multi-page PDF renderer & full-screen previewer with saved status badge |
| **OCR Text Recognition** | `OCRService`, `OCRResultView` | ✅ Complete | Vision & PDFKit accurate text extraction for live pages & saved PDF files |
| **Document Library** | `DocumentStorageService`, `DocumentLibraryViewModel`, `DocumentLibraryView`, `DocumentRowCard` | ✅ Complete | Persistent storage with `documentStorageDidChange` observer updates & search |

---

## 5. Development Guidelines Checklist
- [x] Maximum 200 lines per file (Strict adherence).
- [x] Zero hardcoded strings (All strings in `Localizable.xcstrings` & `AppStrings`).
- [x] Zero hardcoded colors, fonts, margins, or radii.
- [x] Brief 1–2 line docstring header on all types/components.
- [x] `#Preview` block present in all SwiftUI Views.
- [x] Keep `PROJECT_SUMMARY.md` updated after every major file/feature change.
