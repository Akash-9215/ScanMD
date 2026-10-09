# ScanMD AI Development Rules & Architectural Guidelines

Every AI agent and developer working on this project MUST strictly adhere to the following rules at all times.

---

## 1. Feature-First MVVM Architecture
- Project structure must strictly follow **Feature-First MVVM**:
  - `ScanMD/Core/DesignSystem/` (`AppColors`, `AppTypography`, `AppSpacing`, `AppRadius`, `AppIcons`, `AppComponents`)
  - `ScanMD/Core/Localization/` (`Localizable.xcstrings`, `AppStrings`)
  - `ScanMD/Core/Utilities/`
  - `ScanMD/Core/Network/`
  - `ScanMD/Features/<FeatureName>/`
    - `Views/` (SwiftUI views - layout & rendering only)
    - `ViewModels/` (Presentation logic, `@Observable` / `ObservableObject`, state management)
    - `Models/` (Data structures, DTOs)
    - `Services/` (Feature specific services / repositories)
- **Separation of Concerns**: SwiftUI Views must contain ZERO business logic. All logic belongs in ViewModels or Services.

---

## 2. Reusable Components & Zero Code Duplication
- **Reusable Components First**: Always create modular, generic components for repeating UI patterns (e.g., buttons, cards, text fields, headers).
- **Minimum Component Footprint**: Design highly configurable components with well-arranged props rather than creating multiple similar single-use components.
- **No Duplicate Code or Logic**: NEVER write duplicate UI code or business logic. Extract shared functionality into reusable components, view modifiers, helpers, or services.

---

## 3. Strict Theming & Design Tokens (Zero Hardcoding)
- **AppColors Only**:
  - Color styling must use colors defined ONLY in `AppColors`.
  - NEVER use raw color initializers or system defaults inline (e.g. NO `Color.red`, `Color.blue`, `#FF0000`, `rgb(...)`, etc.).
- **AppTypography Only**:
  - All typography must come strictly from `AppTypography`.
  - NEVER specify raw inline font sizes or custom font modifiers outside predefined tokens.
- **Fixed Gutter / Spacing System (`AppSpacing` & `AppRadius`)**:
  - All padding, margins, spacing, frame dimensions, and corner radii MUST use predefined values from `AppSpacing` (e.g. `AppSpacing.xs`, `AppSpacing.sm`, `AppSpacing.md`, `AppSpacing.lg`, `AppSpacing.xl`) or `AppRadius`.
  - NEVER use raw numeric literals (e.g. `.padding(16)`, `.frame(height: 44)`, `.cornerRadius(10)`) inside UI blocks.
- **Icons**:
  - Always use SF Symbols via `AppIcons` enum or `Image(systemName: AppIcons...)`.

---

## 4. Centralized Localization & String Catalogs (`Localizable.xcstrings`)
- ALL user-facing text and raw strings MUST use Xcode String Catalogs (`Localizable.xcstrings`) accessed via `AppStrings`.
- ABSOLUTELY NO hardcoded string literals in UI or logic files (e.g. NO `"Submit"`, `"Welcome"`, `"##"`, `"Error"` inside View or ViewModel files).
- Keep all UI text organized logically within `Localizable.xcstrings` and `AppStrings`.

---

## 5. Concise & Purposeful Documentation (Brief Component & Class Headers)
- **Reusable Components, Classes & Shared Logic**: Must include a **subtle, brief docstring header** (1–2 lines) explaining its **purpose and primary usage**.
- **No Heavy Documentation Bloat**: Keep descriptions short, clean, and to the point. Avoid heavy documentation or redundant comments on self-explanatory properties and initializers.
- **Selective & Informative**: Provide quick context for reusable units and non-obvious business logic without cluttering the codebase.

---

## 6. Architecture & Logic Documentation (`.md` Artifacts)
- **Complex Features & Workflows**: For complex system architectures, state machines, or intricate business logic flows, create a dedicated `.md` file (e.g., `ScanWorkflowArchitecture.md`) detailing the logical flows, sequence diagrams, or Mermaid graphs.
- **Selective Application**: Create `.md` logic documents **ONLY when necessary** for complex or non-trivial implementations. Simple or straightforward features do NOT require extra markdown files.

---

## 7. Premium Visual Excellence, Animations & Interactive UI
- **Artist-Grade Aesthetics**: UI components must look professionally designed with rich visual flair—incorporating sleek dark/light mode palettes, vibrant gradient accents, glassmorphic surfaces (`.ultraThinMaterial`), subtle shadows, and elevated card depths.
- **Micro-Animations & Dynamic Interactions**: Interactive elements MUST feature smooth animations (e.g., `.spring()`, scale-on-press gesture effects, dynamic state changes, shimmer loading indicators).
- **Innovative UI Patterns**: Avoid flat, basic, or cookie-cutter template designs. Experiment with modern, fluid, state-of-the-art layout patterns while preserving usability and clean MVVM architecture.

---

## 8. Mandatory SwiftUI Xcode Canvas Previews (`#Preview`)
- ALL SwiftUI Views and reusable UI components MUST include Xcode Canvas `#Preview` blocks at the bottom of the file.
- Provide clear preview states (e.g. default, dark mode, loading, error, or custom variants) so components can be visually verified inside Xcode Canvas without running the full app.

---

## 9. File Limits & Class Constraints
- **Maximum 200 Lines Per File**: NO file is allowed to exceed 200 lines of code.
- **No Extension Hacks to Bypass Line Limits**: NEVER split a class or struct into separate extension files solely to bypass the 200-line limit. If a file approaches 200 lines, decompose the responsibility into distinct, well-defined helper classes, child views, or services.
- **Clean Class & Struct Definitions**:
  - Do not bloat a single class or struct with excess state variables unless it is strictly a Data Class / DTO.
  - Keep ViewModels and Views focused on a single responsibility.

---

## 10. Naming Conventions
- **Types / Protocols / Structs / Classes**: `PascalCase` (e.g., `HomeViewModel`, `PrimaryButton`, `UserAuthService`).
- **Variables / Functions / Properties**: `camelCase` (e.g., `fetchUserData()`, `isLoading`, `buttonTitle`).
- **Constants / Tokens**: `camelCase` or `PascalCase` under namespaces (e.g., `AppColors.primaryText`, `AppSpacing.md`).
- **Views**: Must end with `View` suffix (e.g., `DocumentScannerView`).
- **ViewModels**: Must end with `ViewModel` suffix (e.g., `DocumentScannerViewModel`).
- **Services / Protocols**: Must end with `Service`, `Repository`, or `Protocol` suffix.
- **File Names**: Must match the primary type defined inside (e.g., `DocumentScannerView.swift`).

---

## 11. Mandatory Project Summary Maintenance (`PROJECT_SUMMARY.md`)
- All AI agents and developers MUST maintain and continuously update `PROJECT_SUMMARY.md` in the root directory whenever files, features, architecture, models, services, or design system tokens are created, modified, or removed.
- Read `PROJECT_SUMMARY.md` at the start of tasks to rapidly understand project architecture and state without performing repetitive full-codebase analysis.

