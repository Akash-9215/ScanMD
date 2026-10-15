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
    "Urinalysis & Pathology",
    "General Clinical Report"
]

FEATURE_NAMES = [
    "med_keywords_ratio", "non_med_keywords_ratio", "lab_units_density",
    "ref_range_pattern_density", "has_patient_header", "cbc_signals",
    "lipid_signals", "liver_signals", "renal_signals", "diabetic_signals",
    "urinalysis_signals", "endocrine_signals", "cardio_signals", "radiology_signals",
    "discharge_signals", "code_signals", "currency_signals", "numeric_density",
    "uppercase_ratio", "total_lines", "total_word_count", "table_structure_density",
    "pathologist_signals", "lab_facility_signals"
]

def extract_features(text: str) -> np.ndarray:
    """Extracts 24 normalized structural, lexical, and clinical signals from document text."""
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
        "biochemistry", "unit", "result", "normal", "abnormal", "interval", "investigation"
    }
    non_med_kw = {
        "coffee", "receipt", "invoice", "subtotal", "tax", "price", "menu",
        "checkout", "bill", "item", "qty", "payment", "visa", "mastercard",
        "total", "store", "customer", "cashier", "discount", "terminal",
        "shipping", "order", "delivery", "espresso", "latte", "burger", "pizza"
    }

    med_matches = sum(1 for w in words if w in med_kw)
    non_med_matches = sum(1 for w in words if w in non_med_kw)

    units_pat = r"(?:mg/dl|g/dl|mmol/l|u/l|%|pg/ml|ng/dl|ng/ml|µiu/ml|uiu/ml|fl|pg|cells|mill|cumm|bpm|ms|mm/hr|eu/dl)"
    has_units = len(re.findall(units_pat, lower))
    has_range = len(re.findall(r"\d+(?:\.\d+)?\s*(?:-|–|to)\s*\d+(?:\.\d+)?", lower))
    has_hdr = 1.0 if any(k in lower for k in ["patient name", "age:", "gender:", "ref by:", "collected:", "lab no", "patient id", "visit no", "registered"]) else 0.0

    cbc = sum(1 for k in ["hemoglobin", "haemoglobin", "wbc", "rbc", "platelet", "hematocrit", "haematocrit", "neutrophil", "lymphocyte", "mcv", "mch", "mchc", "esr", "blood picture"] if k in lower)
    lipid = sum(1 for k in ["cholesterol", "triglycerides", "triglyceride", "hdl", "ldl", "vldl", "lipid"] if k in lower)
    liver = sum(1 for k in ["bilirubin", "sgot", "sgpt", "alt", "ast", "alp", "protein", "albumin", "globulin", "hepatic"] if k in lower)
    renal = sum(1 for k in ["creatinine", "urea", "bun", "uric acid", "egfr", "kidney", "renal"] if k in lower)
    diabetic = sum(1 for k in ["glucose", "hba1c", "sugar", "fasting", "post prandial", "insulin", "diabetology", "eag", "glycated"] if k in lower)
    urinalysis = sum(1 for k in ["urine", "pus cells", "epithelial", "specific gravity", "urobilinogen", "nitrite", "casts", "crystals", "urinalysis"] if k in lower)
    endocrine = sum(1 for k in ["tsh", "thyroid", "t3", "t4", "ft3", "ft4", "hormone", "vitamin", "b12", "folate", "ferritin"] if k in lower)
    cardio = sum(1 for k in ["ecg", "troponin", "bnp", "sinus", "rhythm", "ventricular", "pr interval", "qrs", "qtc", "lead"] if k in lower)
    radiology = sum(1 for k in ["x-ray", "radiograph", "radiology", "chest", "pa view", "lung", "spine", "mri", "bone", "fracture", "vertebra"] if k in lower)
    discharge = sum(1 for k in ["discharge", "admission", "hospital", "clinical course", "emergency", "vitals", "discharge summary"] if k in lower)

    code = sum(1 for k in ["import ", "export ", "function", "const ", "let ", "var ", "return ", "class ", "def ", "println"] if k in lower)
    currency = sum(1 for k in ["$", "€", "£", "₹", "usd", "tax:", "subtotal", "change:", "cash:"] if k in lower)

    digits = sum(1 for c in text if c.isdigit())
    uppers = sum(1 for c in text if c.isupper())
    tbl_lines = sum(1 for l in lines if re.search(r"\d+\.?\d*\s+[a-zA-Z/%]+", l))

    pathologist = 1.0 if any(k in lower for k in ["pathologist", "biochemist", "impression", "signature", "dr.", "consultant", "attending"]) else 0.0
    facility = 1.0 if any(k in lower for k in ["laboratory", "laboratories", "lab", "diagnostics", "hospital", "centre", "center", "clinic", "mokhtabar", "alfa"]) else 0.0

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
        min(1.0, cardio / 2.0),
        min(1.0, radiology / 2.0),
        min(1.0, discharge / 2.0),
        min(1.0, code / 4.0),
        min(1.0, currency / 3.0),
        min(1.0, digits / max(1, len(text))),
        min(1.0, uppers / max(1, len(text))),
        min(1.0, total_l / 40.0),
        min(1.0, total_w / 200.0),
        min(1.0, tbl_lines / max(1, total_l)),
        pathologist,
        facility
    ], dtype=np.float32)

class MedicalClassifierNet(nn.Module):
    """Deep Neural Network with Softmax probability output classifying medical documents."""
    def __init__(self, input_dim=24, num_classes=8):
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
