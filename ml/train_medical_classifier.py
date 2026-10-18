"""
train_medical_classifier.py
Trains PyTorch medical document classifier on 177 sample reports + clinical + synthetic data and exports to Core ML.
"""

import os
import json
import numpy as np
import torch
import torch.nn as nn
from torch.utils.data import DataLoader, TensorDataset
import coremltools as ct
from model_def import CLASSES, extract_features, MedicalClassifierNet

NON_MEDICAL_SAMPLES = [
    "Starbucks Coffee #1289\n1 Caramel Macchiato $5.75\n1 Blueberry Muffin $3.50\nSubtotal $9.25\nTax: $0.74\nTotal: $9.99\nVisa Ending 4012\nThank you!",
    "Supermarket Grocery Mart\nMilk 1 Gal $3.99\nEggs 12ct $2.49\nBread Sliced $2.99\nItem Count: 3\nTotal: $9.47\nCash: $10.00\nChange: $0.53",
    "import React, { useState } from 'react';\nexport default function App() {\n  const [count, setCount] = useState(0);\n  return <button onClick={() => setCount(count + 1)}>{count}</button>;\n}",
    "BOARDING PASS\nPassenger: John Smith\nFlight: AA104 Gate: B22 Seat: 14B\nOrigin: JFK Destination: LAX\nDep: 08:30 AM Arr: 11:45 AM",
    "Italian Bistro Menu\nSpaghetti Bolognese $16.00\nPenne all Arrabbiata $14.50\nTiramisu $8.00\nTable 4 Guests: 2 Server: Marco\nCheck Total: $38.50",
    "INVOICE #9821\nClient: Acme Corp\nConsulting Hours: 40 hrs @ $150/hr\nSubtotal: $6000.00\nTax: 0%\nAmount Due: $6000.00\nPayment Terms: Net 30",
    "def calculate_fibonacci(n):\n    if n <= 1:\n        return n\n    return calculate_fibonacci(n-1) + calculate_fibonacci(n-2)\nprint(calculate_fibonacci(10))",
    "Shell Gas Station\nPump 04 Regular Unleaded\n12.450 Gal @ $3.499/Gal\nFuel Total: $43.56\nApproved Debit Card\nVisit Again!",
    "Target Store #0281\nShampoo 16oz $7.99\nConditioner 16oz $7.99\nToothpaste 2pk $5.49\nSubtotal $21.47\nTax $1.72\nTotal $23.19\nMastercard 8821",
    "Home Depot Order Confirmation\nOrder #WD-99128\nItem: Cordless Drill 20V $89.00\nHardware Screws $6.50\nShipping: Free Standard\nTotal: $95.50\nThank you for shopping!",
    "Uber Ride Receipt\nTrip Fare $18.20\nSurge $4.50\nTolls $2.75\nTip $4.00\nTotal Charged: $29.45 to Visa ending in 1948\nDriver: Alex 5 Stars",
    "Amazon Logistics Shipment\nTracking: 1Z999AA101234\nPackage 1 of 1 Delivered\nDelivery address: 742 Evergreen Terrace\nPackage left at front door",
    "git commit -m 'fix: resolve race condition in network thread'\nAuthor: dev@company.com\nBranch: main -> origin/main\n3 files changed, 45 insertions(+), 12 deletions(-)",
    "McDonald's Restaurant #4412\n1 Big Mac Meal $8.99\n1 Large Fries $2.99\n1 Coca Cola $1.50\nSubtotal $13.48\nSales Tax: $1.08\nTotal: $14.56\nCash Tendered $20.00",
    "Electric Utility Bill\nAccount: 489-102-11\nBilling Period: Sep 01 - Oct 01\nUsage: 640 kWh @ $0.14/kWh\nElectric Charges: $89.60\nTotal Amount Due: $89.60\nDue Date: Oct 25",
    "public class NetworkManager {\n    private URLSession session;\n    public void fetchData(String url) {\n        System.out.println('Fetching: ' + url);\n    }\n}",
    "Parking Ticket & Receipt\nLot C Garage Level 2\nEntry: 14:15 Exit: 18:30\nDuration: 4h 15m\nRate: $5/hr\nFee: $25.00\nPaid via Apple Pay",
    "Best Buy Customer Receipt\nItem: USB-C Cable 2m $19.99\nItem: Wireless Mouse $29.99\nSubtotal: $49.98\nTax: $4.00\nTotal: $53.98\nReturn Policy: 15 Days",
    "Coffee Bean & Tea Leaf\nOrder #812\nIced Vanilla Latte $5.25\nCroissant Butter $3.75\nTotal $9.00\nTip $1.50\nTotal Paid: $10.50\nTerminal: Register 01",
    "SELECT users.id, users.email, orders.total FROM users JOIN orders ON users.id = orders.user_id WHERE orders.created_at >= '2026-01-01';",
    "FedEx Express Tracking Details\nTracking No: 7894-1120-8910\nStatus: In Transit to Local Facility\nSigned for by: Front Desk\nEstimated Delivery: Tomorrow 10:30 AM",
    "Hertz Car Rental Agreement #99281\nVehicle: Toyota RAV4 AWD\nRental Rate: $45.00/day x 3 days\nCollision Damage Waiver: $36.00\nTotal Estimated: $171.00\nFuel Policy: Full to Full",
    "Grand Hyatt Hotel Room Invoice\nGuest: Robert Davis\nRoom: 412 - Deluxe King\nRoom Charge 2 Nights: $420.00\nCity Occupancy Tax: $42.00\nBalance Due: $0.00 (Paid Amex 1002)",
    "Movie Theater Box Office\nCinema 8 - Screen 4\n2x Adult Standard Evening $28.00\n1x Large Popcorn Combo $14.50\nTotal Purchase: $42.50\nEnjoy the show!",
    "Python Developer Resume\nSummary: 6 years building distributed systems and high-throughput microservices using FastAPI, Redis, Docker, and AWS Kubernetes."
]

SYNTHETIC_LABELS = {
    "ScanMD_Report_01.pdf": 1,  # Complete Blood Count
    "ScanMD_Report_02.pdf": 2,  # Lipid Profile
    "ScanMD_Report_03.pdf": 5,  # Diabetology & Endocrine (TFT)
    "ScanMD_Report_04.pdf": 3,  # Liver Function
    "ScanMD_Report_05.pdf": 4,  # Renal Function
    "ScanMD_Report_06.pdf": 9,  # Radiology & Imaging (Spine)
    "ScanMD_Report_07.pdf": 11, # General Clinical (Discharge)
    "ScanMD_Report_08.pdf": 10, # Cardiology & Functional Diagnostics (ECG)
    "ScanMD_Report_09.pdf": 9,  # Radiology & Imaging (Chest X-Ray)
    "ScanMD_Report_10.pdf": 6,  # Urinalysis & Body Fluids
    "ScanMD_Report_11.pdf": 5,  # Diabetology & Endocrine (Vit D & B12)
    "ScanMD_Report_12.pdf": 5   # Diabetology & Endocrine (HbA1c)
}

def classify_sample_report(category: str, report_type: str) -> int:
    """Maps 177 sample reports across 7 major clinical categories to class indices."""
    if category == "01_Hematology":
        return 1 # Complete Blood Count
    elif category == "02_Clinical_Biochemistry":
        if "Lipid" in report_type:
            return 2 # Lipid Profile
        elif "Liver" in report_type or "LFT" in report_type:
            return 3 # Liver Function
        elif "Kidney" in report_type or "Renal" in report_type or "KFT" in report_type or "RFT" in report_type:
            return 4 # Renal Function
        return 5 # Diabetology & Endocrine (Glucose, TFT, Hormones, Bone/Nutritional)
    elif category == "03_Microbiology_Serology_Immunology":
        return 7 # Microbiology & Serology
    elif category == "04_Urinalysis_Body_Fluids":
        return 6 # Urinalysis & Body Fluids
    elif category == "05_Histopathology_Cytopathology":
        return 8 # Histopathology & Cytology
    elif category == "06_Radiology_Imaging":
        return 9 # Radiology & Imaging
    elif category == "07_Functional_Diagnostics":
        return 10 # Cardiology & Functional Diagnostics
    return 11 # General Clinical Report

def classify_clinic_sample(text: str) -> int:
    """Assigns ground truth category to real clinic reports."""
    l = text.lower()
    if any(k in l for k in ["lipid", "cholesterol", "triglyceride", "hdl", "ldl"]):
        return 2 # Lipid Profile
    if any(k in l for k in ["liver", "bilirubin", "sgot", "sgpt", "alt", "ast", "alp", "hepatic", "albumin"]):
        return 3 # Liver Function
    if any(k in l for k in ["creatinine", "urea", "bun", "uric acid", "kidney", "renal"]):
        return 4 # Renal Function
    if any(k in l for k in ["glucose", "sugar", "hba1c", "tsh", "thyroid", "t3", "t4", "insulin", "diabet"]):
        return 5 # Diabetology & Endocrine
    if any(k in l for k in ["urine", "pus cells", "epithelial", "urinalysis", "stool", "culture"]):
        return 6 # Urinalysis & Body Fluids
    if any(k in l for k in ["hemoglobin", "haemoglobin", "wbc", "platelet", "hematocrit", "haematocrit", "cbc", "blood picture", "esr"]):
        return 1 # Complete Blood Count
    return 11 # General Clinical

def build_dataset():
    texts, labels = [], []
    for txt in NON_MEDICAL_SAMPLES:
        texts.append(txt)
        labels.append(0)

    sample_rep_path = os.path.join(os.path.dirname(__file__), "sample_reports_extracted.json")
    if os.path.exists(sample_rep_path):
        with open(sample_rep_path, "r") as f:
            for item in json.load(f):
                texts.append(item.get("text", ""))
                labels.append(classify_sample_report(item.get("category", ""), item.get("report_type", "")))

    clinic_path = os.path.join(os.path.dirname(__file__), "real_clinic_samples.json")
    if os.path.exists(clinic_path):
        with open(clinic_path, "r") as f:
            for item in json.load(f):
                txt = item.get("text", "")
                texts.append(txt)
                labels.append(classify_clinic_sample(txt))

    synth_path = os.path.join(os.path.dirname(__file__), "synthetic_reports.json")
    if os.path.exists(synth_path):
        with open(synth_path, "r") as f:
            for item in json.load(f):
                texts.append(item.get("text", ""))
                labels.append(SYNTHETIC_LABELS.get(item.get("filename", ""), 11))

    print(f"Total compiled dataset: {len(texts)} samples (Non-Medical: {labels.count(0)}, Medical: {len(labels) - labels.count(0)})")
    return texts, labels

def train_and_export():
    texts, labels = build_dataset()
    X_list, y_list = [], []

    for text, label in zip(texts, labels):
        feat = extract_features(text)
        X_list.append(feat)
        y_list.append(label)
        for _ in range(4):
            noise = np.random.normal(0, 0.012, size=feat.shape).astype(np.float32)
            X_list.append(np.clip(feat + noise, 0.0, 1.0))
            y_list.append(label)

    X = torch.tensor(np.array(X_list), dtype=torch.float32)
    y = torch.tensor(np.array(y_list), dtype=torch.long)

    loader = DataLoader(TensorDataset(X, y), batch_size=16, shuffle=True)
    model = MedicalClassifierNet(input_dim=28, num_classes=len(CLASSES))
    optimizer = torch.optim.Adam(model.parameters(), lr=0.007)
    criterion = nn.CrossEntropyLoss()

    model.train()
    for epoch in range(130):
        for bx, by in loader:
            optimizer.zero_grad()
            out = model(bx)
            loss = criterion(out, by)
            loss.backward()
            optimizer.step()

    model.eval()
    with torch.no_grad():
        preds = model(X).argmax(dim=1)
        acc = (preds == y).float().mean().item()
        print(f"PyTorch training completed! Dataset Accuracy: {acc * 100:.2f}%")

    example_input = torch.rand(1, 28)
    traced_model = torch.jit.trace(model, example_input)
    cfg = ct.ClassifierConfig(class_labels=CLASSES)

    print("Converting to Apple Core ML (.mlpackage)...")
    mlmodel = ct.convert(
        traced_model,
        inputs=[ct.TensorType(name="features", shape=(1, 28))],
        classifier_config=cfg,
        minimum_deployment_target=ct.target.iOS16
    )

    out_dir = os.path.join(os.path.dirname(__file__), "..", "ScanMD", "Features", "MedicalAnalysis", "Models")
    pkg_path = os.path.join(out_dir, "MedicalClassifierModel.mlpackage")
    mlmodel.save(pkg_path)
    print(f"Saved optimized Core ML package to: {pkg_path}")

if __name__ == "__main__":
    train_and_export()
