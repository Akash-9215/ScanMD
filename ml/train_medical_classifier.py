"""
train_medical_classifier.py
Trains PyTorch medical document neural classifier and exports to Core ML (.mlpackage).
"""

import os
import numpy as np
import torch
import torch.nn as nn
from torch.utils.data import DataLoader, TensorDataset
import coremltools as ct
from model_def import CLASSES, extract_features, MedicalClassifierNet

TRAINING_DATA = [
    # Class 0: Non-Medical
    ("Starbucks Coffee #1289\n1 Caramel Macchiato $5.75\n1 Blueberry Muffin $3.50\nSubtotal $9.25\nTax: $0.74\nTotal: $9.99\nVisa Ending 4012\nThank you!", 0),
    ("Supermarket Grocery Mart\nMilk 1 Gal $3.99\nEggs 12ct $2.49\nBread Sliced $2.99\nItem Count: 3\nTotal: $9.47\nCash: $10.00\nChange: $0.53", 0),
    ("import React, { useState } from 'react';\nexport default function App() {\n  const [count, setCount] = useState(0);\n  return <button onClick={() => setCount(count + 1)}>{count}</button>;\n}", 0),
    ("BOARDING PASS\nPassenger: John Smith\nFlight: AA104 Gate: B22 Seat: 14B\nOrigin: JFK Destination: LAX\nDep: 08:30 AM Arr: 11:45 AM", 0),
    ("Italian Bistro Menu\nSpaghetti Bolognese $16.00\nPenne all Arrabbiata $14.50\nTiramisu $8.00\nTable 4 Guests: 2 Server: Marco\nCheck Total: $38.50", 0),
    ("INVOICE #9821\nClient: Acme Corp\nConsulting Hours: 40 hrs @ $150/hr\nSubtotal: $6000.00\nTax: 0%\nAmount Due: $6000.00\nPayment Terms: Net 30", 0),
    ("def calculate_fibonacci(n):\n    if n <= 1:\n        return n\n    return calculate_fibonacci(n-1) + calculate_fibonacci(n-2)\nprint(calculate_fibonacci(10))", 0),
    ("Shell Gas Station\nPump 04 Regular Unleaded\n12.450 Gal @ $3.499/Gal\nFuel Total: $43.56\nApproved Debit Card\nVisit Again!", 0),

    # Class 1: Lipid Profile
    ("METRO HEALTH PATHOLOGY\nPatient Name: Rajesh Patel Age: 52 Gender: Male\nRef By: Dr. Mehta\nPATHOLOGY — LIPID PROFILE\nTotal Cholesterol 245.0 mg/dL (Desirable: <200)\nTriglycerides 210.0 mg/dL (Normal: <150)\nHDL Cholesterol 38.0 mg/dL (Normal: >40)\nLDL Cholesterol 165.0 mg/dL (Optimal: <100)\nVLDL 42.0 mg/dL (Normal: 10-30)\nImpression: Hypercholesterolemia with elevated atherogenic risk.", 1),
    ("CLINICAL BIOCHEMISTRY LAB\nPatient Name: Sunita Rao Age: 48 Gender: Female\nLIPID PANEL\nSerum Cholesterol: 185 mg/dL (125-200)\nTriglycerides: 130 mg/dL (<150)\nHDL: 54 mg/dL (>50)\nLDL: 105 mg/dL (<100)\nChol / HDL Ratio: 3.4\nSpecimen: Serum Collected: 08:00 AM\nPathologist Signature: Dr. Sen, MD", 1),
    ("APEX DIAGNOSTICS\nLIPID PROFILE TEST REPORT\nTotal Cholesterol 278 mg/dL\nTriglycerides 280 mg/dL\nHDL Cholesterol 35 mg/dL\nLDL Cholesterol 187 mg/dL\nRisk Factor: High atherogenic index\nPathologist Advice: Lifestyle intervention and Statin therapy evaluation.", 1),
    ("CENTRAL PATHOLOGY CLINIC\nPatient: David Miller\nSERUM LIPIDS\nCholesterol Total: 215 mg/dL (150-200)\nTriglyceride: 175 mg/dL (50-150)\nHDL: 42 mg/dL (40-60)\nLDL Direct: 138 mg/dL (0-100)\nSpecimen: Fasting Serum\nDoctor: Dr. K. Verma", 1),

    # Class 2: Complete Blood Count
    ("CITY HEALTH CARE LABORATORY\nDepartment of Hematology\nCOMPLETE BLOOD COUNT (CBC)\nPatient Name: John Doe Age: 35 Gender: Male\nHemoglobin 14.8 g/dL (13.0-17.0)\nRBC Count 4.90 mill/cumm (4.5-5.5)\nWBC Total Count 7200 cells/cumm (4000-11000)\nPlatelet Count 240000 /cumm (150000-450000)\nNeutrophils 62 % (40-75)\nLymphocytes 30 % (20-45)\nEosinophils 3 % (1-6)\nMonocytes 5 % (2-10)\nPCV Hematocrit 44 % (40-50)\nMCV 88 fl (80-100)\nSpecimen: EDTA Whole Blood", 2),
    ("GLOBAL LABS & PATHOLOGY\nHEMOGRAM / COMPLETE BLOOD COUNT\nPatient Name: Priya Sharma Age: 29 Gender: Female\nHemoglobin: 9.2 g/dL (12.0-15.0)\nTotal Leucocyte Count: 12500 /cumm (4000-11000)\nPlatelets: 180000 /cumm (150000-410000)\nImpression: Microcytic hypochromic anemia with mild leukocytosis.", 2),
    ("ST. JUDE HOSPITAL CLINICAL LAB\nHAEMATOLOGY REPORT (CBC)\nHb: 15.2 g/dL\nTotal WBC: 6500 cells/cumm\nRBC: 5.1 mill/cumm\nPlatelet Count: 280000 /cumm\nESR: 8 mm/hr\nSpecimen: Whole Blood EDTA\nConsultant Pathologist: Dr. R. Iyer, MD", 2),

    # Class 3: Liver Function
    ("ROYAL CLINICAL DIAGNOSTICS\nDepartment of Biochemistry\nLIVER FUNCTION TEST (LFT)\nPatient Name: Anita Roy Age: 42 Gender: Female\nBilirubin Total 0.9 mg/dL (0.2-1.2)\nBilirubin Direct 0.2 mg/dL (0.0-0.3)\nSGOT / AST 28 U/L (10-40)\nSGPT / ALT 32 U/L (7-56)\nAlkaline Phosphatase (ALP) 85 U/L (44-147)\nTotal Protein 7.2 g/dL (6.0-8.3)\nSerum Albumin 4.1 g/dL (3.5-5.0)\nSerum Globulin 3.1 g/dL (2.0-3.5)\nA/G Ratio: 1.32\nSpecimen: Fasting Serum", 3),
    ("PREMIER PATHOLOGY SERVICES\nHEPATIC PROFILE / LFT REPORT\nTotal Bilirubin: 2.8 mg/dL (High)\nDirect Bilirubin: 1.4 mg/dL (High)\nAST (SGOT): 95 U/L (Elevated)\nALT (SGPT): 120 U/L (Elevated)\nALP: 210 U/L\nImpression: Hepatocellular injury pattern, clinical correlation advised.", 3),

    # Class 4: Renal Function
    ("MEDILIFE DIAGNOSTIC CENTRE\nKIDNEY FUNCTION TEST (KFT / RFT)\nPatient Name: Vikram Singhania Age: 61 Gender: Male\nBlood Urea 34 mg/dL (15-45)\nSerum Creatinine 1.05 mg/dL (0.7-1.3)\nBlood Urea Nitrogen (BUN) 16 mg/dL (7-20)\nSerum Uric Acid 5.8 mg/dL (3.5-7.2)\neGFR: 82 mL/min/1.73m2\nSodium: 139 mmol/L (135-145)\nPotassium: 4.2 mmol/L (3.5-5.1)\nSpecimen: Serum", 4),
    ("ADVANCED RENAL LAB\nRENAL PROFILE REPORT\nSerum Creatinine: 2.4 mg/dL (0.6-1.2)\nBlood Urea: 68 mg/dL (10-50)\nBUN / Creatinine Ratio: 28.3\nImpression: Impaired glomerular filtration, Nephrology consult recommended.", 4),

    # Class 5: General Medical / Prescription
    ("CARE CLINIC & MULTISPECIALTY HOSPITAL\nPatient Name: Robert Taylor Age: 45 Date: 12-Oct-2026\nDr. Marcus Vance, MD Cardiology\nDiagnosis: Essential Hypertension\nRx Prescription:\n1. Tab. Telmisartan 40mg OD Morning after food\n2. Tab. Amlodipine 5mg OD Night\nAdvice: Restrict sodium intake, daily aerobic exercise, review BP in 2 weeks.\nDoctor Signature & Seal", 5),
    ("CARDIAC CARE INSTITUTE\nELECTROCARDIOGRAM (ECG) REPORT\nPatient Name: Suresh Nair Age: 58\nHeart Rate: 72 bpm\nPR Interval: 160 ms\nQRS Duration: 88 ms\nQT / QTc: 390 / 410 ms\nImpression: Normal Sinus Rhythm, No ST-T segment elevation or acute ischemic changes.", 5)
]

def train_and_export():
    print(f"Extracting features for {len(TRAINING_DATA)} samples...")
    X_list, y_list = [], []
    # Augment data with slight feature perturbations for generalization
    for text, label in TRAINING_DATA:
        feat = extract_features(text)
        X_list.append(feat)
        y_list.append(label)
        for _ in range(5):
            noise = np.random.normal(0, 0.02, size=feat.shape).astype(np.float32)
            X_list.append(np.clip(feat + noise, 0.0, 1.0))
            y_list.append(label)

    X = torch.tensor(np.array(X_list), dtype=torch.float32)
    y = torch.tensor(np.array(y_list), dtype=torch.long)

    dataset = TensorDataset(X, y)
    loader = DataLoader(dataset, batch_size=8, shuffle=True)

    model = MedicalClassifierNet()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.01)
    criterion = nn.CrossEntropyLoss()

    print("Training PyTorch Medical Classifier Network...")
    model.train()
    for epoch in range(120):
        total_loss = 0.0
        for batch_x, batch_y in loader:
            optimizer.zero_grad()
            out = model(batch_x)
            loss = criterion(out, batch_y)
            loss.backward()
            optimizer.step()
            total_loss += loss.item()

    model.eval()
    with torch.no_grad():
        preds = model(X).argmax(dim=1)
        acc = (preds == y).float().mean().item()
        print(f"Training completed! Model accuracy: {acc * 100:.2f}%")

    # Export to Core ML
    example_input = torch.rand(1, 20)
    traced_model = torch.jit.trace(model, example_input)
    classifier_config = ct.ClassifierConfig(class_labels=CLASSES)

    print("Converting to Apple Core ML (.mlpackage)...")
    mlmodel = ct.convert(
        traced_model,
        inputs=[ct.TensorType(name="features", shape=(1, 20))],
        classifier_config=classifier_config,
        minimum_deployment_target=ct.target.iOS16
    )

    out_dir = os.path.join(os.path.dirname(__file__), "..", "ScanMD", "Features", "MedicalAnalysis", "Models")
    os.makedirs(out_dir, exist_ok=True)
    pkg_path = os.path.join(out_dir, "MedicalClassifierModel.mlpackage")
    mlmodel.save(pkg_path)
    print(f"Core ML package saved successfully to: {pkg_path}")

if __name__ == "__main__":
    train_and_export()
