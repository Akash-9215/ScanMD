"""
model_def.py
ScanMD - 24-dimensional feature extractor and PyTorch neural network definition.
"""

import re
import numpy as np
import torch
import torch.nn as nn

CLASSES = [
    "Non-Medical",
    "Complete Blood Count",
    "Lipid Profile",
    "Liver Function",
    "Renal Function",
    "Diabetology & Endocrine",
    "Urinalysis & Body Fluids",
    "Microbiology & Serology",
    "Histopathology & Cytology",
    "Radiology & Imaging",
    "Cardiology & Functional Diagnostics",
    "General Clinical Report"
]

FEATURE_NAMES = [
    "med_keywords_ratio", "non_med_keywords_ratio", "lab_units_density",
    "ref_range_pattern_density", "has_patient_header", "cbc_signals",
    "lipid_signals", "liver_signals", "renal_signals", "diabetic_signals",
    "urinalysis_signals", "endocrine_signals", "microbiology_signals",
    "histopathology_signals", "body_fluids_signals", "radiology_signals",
    "cardio_functional_signals", "discharge_signals", "code_signals",
    "currency_signals", "numeric_density", "uppercase_ratio", "total_lines",
    "total_word_count", "table_structure_density", "pathologist_signals",
    "lab_facility_signals", "impression_signals"
]

def extract_features(text: str) -> np.ndarray:
    """Extracts 28 normalized structural, lexical, and clinical signals from document text."""
    lower = text.lower()
    words = re.findall(r"\b[a-z]{2,}\b", lower)
    total_w = max(1, len(words))
    lines = [l.strip() for l in text.splitlines() if l.strip()]
    total_l = max(1, len(lines))

    med_kw = {
        "medicine", "doctor", "patient", "hospital", "pathology", "specimen",
        "laboratory", "diagnosis", "clinical", "reference", "serum", "blood",
        "report", "test", "profile", "count", "biopsy", "examination", "impression",
        "advice", "haemoglobin", "hemoglobin", "glucose", "urea", "creatinine",
        "bilirubin", "cholesterol", "urine", "plasma", "platelet", "hematology",
        "biochemistry", "unit", "result", "normal", "abnormal", "interval", "investigation",
        "microbiology", "radiology", "imaging", "ultrasound", "culture", "sensitivity",
        "histopathology", "cytology", "findings", "radiograph", "scan", "organism"
    }
    non_med_kw = {
        "coffee", "receipt", "invoice", "subtotal", "tax", "price", "menu",
        "checkout", "bill", "item", "qty", "payment", "visa", "mastercard",
        "total", "store", "customer", "cashier", "discount", "terminal",
        "shipping", "order", "delivery", "espresso", "latte", "burger", "pizza",
        "flight", "airline", "gate", "boarding", "pass", "ticket", "parking", "hotel"
    }

    med_matches = sum(1 for w in words if w in med_kw)
    non_med_matches = sum(1 for w in words if w in non_med_kw)

    units_pat = r"(?:mg/dl|g/dl|mmol/l|u/l|%|pg/ml|ng/dl|ng/ml|µiu/ml|uiu/ml|fl|pg|cells|mill|cumm|bpm|ms|mm/hr|eu/dl|cfu/ml|iu/l|x10\^3|x10\^6)"
    has_units = len(re.findall(units_pat, lower))
    has_range = len(re.findall(r"\d+(?:\.\d+)?\s*(?:-|–|to)\s*\d+(?:\.\d+)?", lower))
    has_hdr = 1.0 if any(k in lower for k in ["patient name", "age:", "gender:", "ref by:", "ref. by:", "specimen:", "collected:", "lab no", "lab id", "patient id", "visit no", "registered"]) else 0.0

    cbc = sum(1 for k in ["hemoglobin", "haemoglobin", "wbc", "rbc", "platelet", "hematocrit", "haematocrit", "neutrophil", "lymphocyte", "monocyte", "eosinophil", "basophil", "mcv", "mch", "mchc", "esr", "blood picture", "blood grouping", "coagulation", "prothrombin", "inr"] if k in lower)
    lipid = sum(1 for k in ["cholesterol", "triglycerides", "triglyceride", "hdl", "ldl", "vldl", "lipid", "apolipoprotein"] if k in lower)
    liver = sum(1 for k in ["bilirubin", "sgot", "sgpt", "alt", "ast", "alp", "alkaline phosphatase", "protein", "albumin", "globulin", "hepatic", "ggt"] if k in lower)
    renal = sum(1 for k in ["creatinine", "urea", "bun", "uric acid", "egfr", "kidney", "renal", "microalbumin"] if k in lower)
    diabetic = sum(1 for k in ["glucose", "hba1c", "sugar", "fasting", "post prandial", "insulin", "diabetology", "eag", "glycated", "c-peptide"] if k in lower)
    urinalysis = sum(1 for k in ["urine routine", "urinalysis", "pus cells", "epithelial", "specific gravity", "urobilinogen", "nitrite", "casts", "crystals", "24-hour urine"] if k in lower)
    endocrine = sum(1 for k in ["tsh", "thyroid", "t3", "t4", "ft3", "ft4", "hormone", "vitamin", "b12", "folate", "ferritin", "psa", "ca-125", "cea", "afp", "testosterone", "cortisol"] if k in lower)

    microbiology = sum(1 for k in ["culture & sensitivity", "culture", "sensitivity", "organism", "colony count", "cfu/ml", "sterile", "resistant", "susceptible", "gram stain", "dengue", "malaria", "hiv", "hepatitis", "hbsag", "vdrl", "rpr", "widal", "typhoid", "serology", "swab", "isolate"] if k in lower)
    histopathology = sum(1 for k in ["biopsy", "histopathology", "cytology", "pap smear", "fnac", "fine needle", "malignant", "benign", "microscopic examination", "gross examination", "carcinoma", "dysplasia", "atypical cells", "lymph node", "bone marrow examination", "tissue section"] if k in lower)
    body_fluids = sum(1 for k in ["cerebrospinal", "csf", "synovial", "pleural", "ascitic", "peritoneal", "stool routine", "occult blood", "stool analysis", "fluid analysis"] if k in lower)
    radiology = sum(1 for k in ["x-ray", "radiograph", "radiology", "chest pa", "pa view", "ap view", "lung fields", "spine", "mri", "ct scan", "ultrasound", "usg", "sonography", "echocardiogram", "doppler", "vertebra", "fracture", "computed tomography", "visualized"] if k in lower)
    cardio_functional = sum(1 for k in ["ecg", "ekg", "eeg", "emg", "ncs", "holter", "treadmill test", "tmt", "stress test", "spirometry", "pft", "sinus rhythm", "pr interval", "qrs", "qtc", "ventricular rate", "nerve conduction", "electromyography", "electroencephalogram", "fev1", "fvc"] if k in lower)

    discharge = sum(1 for k in ["discharge summary", "discharge", "admission date", "hospital course", "clinical course", "emergency department", "discharge vitals"] if k in lower)
    code = sum(1 for k in ["import ", "export ", "function", "const ", "let ", "var ", "return ", "class ", "def ", "println", "interface "] if k in lower)
    currency = sum(1 for k in ["$", "€", "£", "₹", "usd", "tax:", "subtotal", "change:", "cash:", "total due", "visa ending", "mastercard"] if k in lower)

    digits = sum(1 for c in text if c.isdigit())
    uppers = sum(1 for c in text if c.isupper())
    tbl_lines = sum(1 for l in lines if re.search(r"\d+\.?\d*\s+[a-zA-Z/%]+", l))

    pathologist = 1.0 if any(k in lower for k in ["pathologist", "biochemist", "radiologist", "microbiologist", "dr.", "consultant", "attending", "signature", "reported by", "verified by", "technologist"]) else 0.0
    facility = 1.0 if any(k in lower for k in ["laboratory", "laboratories", "lab", "diagnostics", "hospital", "centre", "center", "clinic", "mediscan", "citycare", "arya", "sample diagnostics"]) else 0.0
    impression = 1.0 if any(k in lower for k in ["impression:", "diagnostic impression", "clinical impression", "advice:", "findings:", "clinical correlation", "interpretation:", "conclusion:"]) else 0.0

    return np.array([
        min(1.0, med_matches / total_w),
        min(1.0, non_med_matches / total_w),
        min(1.0, has_units / 5.0),
        min(1.0, has_range / 5.0),
        has_hdr,
        min(1.0, cbc / 4.0),
        min(1.0, lipid / 3.0),
        min(1.0, liver / 4.0),
        min(1.0, renal / 3.0),
        min(1.0, diabetic / 3.0),
        min(1.0, urinalysis / 3.0),
        min(1.0, endocrine / 3.0),
        min(1.0, microbiology / 3.0),
        min(1.0, histopathology / 3.0),
        min(1.0, body_fluids / 2.0),
        min(1.0, radiology / 3.0),
        min(1.0, cardio_functional / 3.0),
        min(1.0, discharge / 2.0),
        min(1.0, code / 4.0),
        min(1.0, currency / 3.0),
        min(1.0, digits / max(1, len(text))),
        min(1.0, uppers / max(1, len(text))),
        min(1.0, total_l / 40.0),
        min(1.0, total_w / 200.0),
        min(1.0, tbl_lines / max(1, total_l)),
        pathologist,
        facility,
        impression
    ], dtype=np.float32)

class MedicalClassifierNet(nn.Module):
    """Deep Neural Network with Softmax probability output classifying medical documents."""
    def __init__(self, input_dim=28, num_classes=12):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(input_dim, 64),
            nn.ReLU(),
            nn.Linear(64, 32),
            nn.ReLU(),
            nn.Linear(32, num_classes),
            nn.Softmax(dim=-1)
        )

    def forward(self, x):
        return self.net(x)
