"""
train_medical_classifier.py
ScanMD - Train and export PyTorch Medical Classifier to Apple Core ML (.mlpackage).
"""

import os
import re
import numpy as np
import torch
import torch.nn as nn
from torch.utils.data import DataLoader, TensorDataset
import coremltools as ct

CLASSES = [
    "Non-Medical",
    "Lipid Profile",
    "Complete Blood Count",
    "Liver Function",
    "Renal Function",
    "General Medical"
]

FEATURE_NAMES = [
    "medical_density", "non_medical_density", "has_lab_units", "has_range_pattern",
    "has_header_pattern", "lipid_signals", "cbc_signals", "liver_signals",
    "renal_signals", "cardio_signals", "code_signals", "currency_signals",
    "numeric_density", "uppercase_ratio", "total_lines", "total_word_count",
    "table_structure_density", "pathologist_signals", "specimen_signals", "prescription_signals"
]

def extract_features(text: str) -> np.ndarray:
    """Extracts 20 normalized structural, lexical, and clinical signal features."""
    lower = text.lower()
    words = re.findall(r"\b[a-z]{2,}\b", lower)
    total_w = max(1, len(words))
    lines = [l.strip() for l in text.splitlines() if l.strip()]
    total_l = max(1, len(lines))

    med_kw = {"medicine", "doctor", "patient", "hospital", "pathology", "specimen",
              "laboratory", "diagnosis", "clinical", "reference", "serum", "blood",
              "report", "test", "profile", "count", "biopsy", "examination", "impression", "advice"}
    non_med_kw = {"coffee", "receipt", "invoice", "subtotal", "tax", "price", "menu",
                  "checkout", "bill", "item", "qty", "payment", "visa", "mastercard",
                  "total", "store", "customer", "cashier", "discount", "terminal"}

    med_matches = sum(1 for w in words if w in med_kw)
    non_med_matches = sum(1 for w in words if w in non_med_kw)

    has_units = len(re.findall(r"(?:mg/dl|g/dl|mmol/l|u/l|%|pg/ml|ng/dl|µiu/ml|fl|pg|cells)", lower))
    has_range = len(re.findall(r"\d+(?:\.\d+)?\s*(?:-|–|to)\s*\d+(?:\.\d+)?", lower))
    has_hdr = 1.0 if any(k in lower for k in ["patient name", "age:", "gender:", "ref by:", "collected:"]) else 0.0

    lipid = sum(1 for k in ["cholesterol", "triglycerides", "hdl", "ldl", "vldl", "lipid"] if k in lower)
    cbc = sum(1 for k in ["hemoglobin", "wbc", "rbc", "platelet", "hematocrit", "neutrophil", "lymphocyte"] if k in lower)
    liver = sum(1 for k in ["bilirubin", "sgot", "sgpt", "alt", "ast", "alp", "protein", "albumin"] if k in lower)
    renal = sum(1 for k in ["creatinine", "urea", "bun", "uric acid", "egfr", "kidney"] if k in lower)
    cardio = sum(1 for k in ["ecg", "troponin", "bnp", "sinus", "rhythm", "rate", "axis"] if k in lower)

    code = sum(1 for k in ["import ", "export ", "function", "const ", "let ", "var ", "return ", "class "] if k in lower)
    currency = sum(1 for k in ["$", "€", "£", "₹", "usd", "tax:"] if k in lower)

    digits = sum(1 for c in text if c.isdigit())
    uppers = sum(1 for c in text if c.isupper())
    tbl_lines = sum(1 for l in lines if re.search(r"\d+\.?\d*\s+[a-zA-Z/%]+", l))

    pathologist = 1.0 if any(k in lower for k in ["pathologist", "biochemist", "impression", "signature", "dr."]) else 0.0
    specimen = 1.0 if any(k in lower for k in ["serum", "whole blood", "edta", "plasma", "urine"]) else 0.0
    rx = 1.0 if any(k in lower for k in ["tab", "cap", "mg", "od", "bd", "tds", "hs", "dosage", "rx"]) else 0.0

    return np.array([
        min(1.0, med_matches / total_w),
        min(1.0, non_med_matches / total_w),
        min(1.0, has_units / 5.0),
        min(1.0, has_range / 5.0),
        has_hdr,
        min(1.0, lipid / 3.0),
        min(1.0, cbc / 4.0),
        min(1.0, liver / 4.0),
        min(1.0, renal / 3.0),
        min(1.0, cardio / 2.0),
        min(1.0, code / 4.0),
        min(1.0, currency / 3.0),
        min(1.0, digits / max(1, len(text))),
        min(1.0, uppers / max(1, len(text))),
        min(1.0, total_l / 30.0),
        min(1.0, total_w / 150.0),
        min(1.0, tbl_lines / max(1, total_l)),
        pathologist,
        specimen,
        rx
    ], dtype=np.float32)

class MedicalClassifierNet(nn.Module):
    """Deep Neural Network classifying medical document type and clinical confidence."""
    def __init__(self, input_dim=20, num_classes=6):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(input_dim, 64),
            nn.ReLU(),
            nn.Linear(64, 32),
            nn.ReLU(),
            nn.Linear(32, num_classes)
        )

    def forward(self, x):
        return self.net(x)
