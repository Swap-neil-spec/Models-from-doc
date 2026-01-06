Great — here is the **fully completed template**, filled using the PRD and product vision for the **Model-From-Docs AI Financial Forecaster** MVP.

---

# **AI App Factory — Master App Creation Template**

## 🏷 **App Identity**

**App Name:**
ModelFromDocs (MFD)

**One-line Value Proposition:**
Upload your startup documents and instantly generate an investor-ready financial model with cash runway, revenue forecast, and burn.

**Primary User Persona:**
Early-stage startup founder or fractional CFO who needs a fast baseline financial model.

**App Category / Domain:**
AI-powered Financial Modeling / Startup Tools

**Platform Focus:**
Mobile-first (Flutter) + Web-friendly layouts

**Monetization Intent:**
Hybrid (Free trial → Subscription for exports, sharing, and advanced features)

---

## 🧠 **Phase 1 — Product Definition (NotebookLM)**

### **1. Problem & Context**

**What problem does this app solve?**
Founders waste hours digging through P&Ls, investor decks, Stripe exports, and payroll sheets just to build a basic financial model and cash runway forecast.

**Why does this problem exist today?**
Financial data is scattered across multiple documents and tools, and existing templates are manual, generic, and error-prone.

**Who experiences it most intensely?**
Seed–Series A founders and fractional CFOs who must produce investor-ready models quickly.

---

### **2. Core Job-to-Be-Done (1 sentence)**

“When I need a financial model or cash runway forecast, I want to upload my existing documents and automatically generate a clean baseline model so that I save time and avoid spreadsheet mistakes.”

---

### **3. Target User Persona**

**Scenario of use:**
Founder preparing a board update, fundraise model, or cash runway plan.

**Motivation:**
Move fast, present credible numbers, avoid spreadsheet work.

**Frustrations:**
Manual copying, inconsistent data, broken formulas, time pressure.

**Environment / usage context:**
Laptop or phone, often near deadlines, sometimes in meetings or travel.

---

### **4. Success Outcomes**

**User Success (Top 3):**

1. Build a usable financial model in under 30 minutes.
2. Understand and trust where every assumption came from.
3. Share or export the model to an advisor or investor.

**Business Success (Top 3):**

1. 50%+ of first-time users generate at least one model.
2. At least 30% return to update or rebuild a model within two weeks.
3. Strong learning signal to validate PMF direction and wedge.

---

### **5. Non-Goals (V1 Will NOT Include)**

* Full GAAP three-statement accounting
* Deep scenario simulation or Monte Carlo
* Real-time integrations with accounting/HR tools
* Complex cap-table / valuation modeling
* Multi-company or enterprise workflows

---

### **6. Constraints & Risks**

**Technical**

* Document parsing variability
* Inconsistent tables and formats
* Extraction confidence gaps

**Ethical / Data**

* Sensitive financial data → privacy and encryption required

**UX / Adoption**

* Users must trust outputs but still review assumptions

**Unknowns Requiring Validation**

* Do founders prefer automation or manual control?
* Is SaaS-first focus strong enough as a wedge?

---

## 🧭 **Phase 2 — Screen Map & Flows (NotebookLM → Stitch)**

### **1. Screen Inventory**

* Welcome / Workspace Setup
* Document Upload
* Processing Status
* Assumptions Review
* Model Dashboard
* Export & Share
* Settings
* History / Versions

---

### **2. Purpose of Each Screen**

**Welcome / Workspace Setup**
Inputs: company name, currency, business type
Outputs: workspace created
Actions: continue → upload
Failure: validation messaging

**Document Upload**
Inputs: PDFs, CSVs, P&Ls, decks
Outputs: file list
Actions: upload more / continue
Empty state: drag-and-drop prompt

**Processing Status**
Outputs: progress steps (“Finding revenue… extracting burn…”)
Failure: show partial results & fallback to manual entry

**Assumptions Review**
Inputs: extracted metrics, user edits
Outputs: confirmed model assumptions
Actions: edit / view source snippet / approve

**Model Dashboard**
Outputs: revenue, burn, cash runway charts
Actions: adjust simple sliders, regenerate
Failure: show explanatory fallback chart

**Export & Share**
Outputs: PDF, Excel, shareable link
Actions: copy, download, invite
Failure: retry export guidance

**History / Versions**
Outputs: previous model builds
Actions: restore or duplicate

---

### **3. Primary User Flows**

**Flow 1 — First-time model creation**

1. Create workspace
2. Upload docs
3. Auto extraction runs
4. Review & edit assumptions
5. Generate model
6. View dashboard
7. Export / share

**Flow 2 — Returning user updating model**

1. Open workspace
2. Upload new docs
3. Re-extract updates
4. Confirm changes
5. Regenerate model

**Flow 3 — Edge case (missing data)**

1. Upload docs
2. Extraction finds gaps
3. App requests manual values
4. User inputs missing fields
5. Continue to model

---

## 🎨 **Phase 3 — Visual & Design System (Stitch)**

### **1. Visual Direction**

Tone: Professional, confident, calm
Brand Feel: Financial clarity, intelligence, trust
Accessibility: High contrast, clear numbers, readable charts

---

### **2. Generated Layouts (Links / References)**

(Home / Dashboard / Core Feature — to be generated during design pass)

---

### **3. Design System Definition**

* **Primary color:** Deep blue / navy

* **Secondary:** Slate gray

* **Accent:** Emerald green (positive finance states)

* **Light / Dark Mode:** Supported

* **Typography:** Inter / Roboto — numeric emphasis

* **Spacing:** 4 / 8 / 12 / 16 scale

* **Corner Radius:** 8–12px soft rounded

* **Components:** Card-first layout, bordered tables, pill chips, flat buttons

Must map cleanly to **Flutter ThemeData**.

---

## 🧩 **Phase 4 — AI Feature Definition (AI Studio)**

### **1. AI Features List**

| Feature               | Input             | Output                      | UI Trigger              |
| --------------------- | ----------------- | --------------------------- | ----------------------- |
| Metric Extraction     | Uploaded docs     | Structured metric JSON      | After upload            |
| Assumption Builder    | Extracted metrics | Normalized assumption set   | Before model generation |
| Source Explainability | Metric selection  | Source snippet + confidence | On assumption tap       |
| Trend Estimator       | Revenue history   | Base growth estimate        | During model build      |

---

### **2. JSON Output Contract**

**Feature: METRIC_EXTRACTION**

**Input**

```json
{
  "document_chunks": [],
  "metric_type": "revenue|cash|headcount"
}
```

**Output**

```json
{
  "metric": "",
  "value": 0,
  "unit": "",
  "as_of": "",
  "source_id": "",
  "snippet": "",
  "confidence": 0.0
}
```

---

### **3. Guardrails & Edge Cases**

* If ambiguous → request user confirmation
* If missing → prompt manual input
* Length limits → truncate long text snippets
* Always log extracted values + sources

---

## ⚙️ **Phase 5 — Project Scaffolding & Integration (Antigravity)**

### **1. Architecture Selections**

State management: Riverpod or Bloc
Data layer: Repository pattern
Backend: Lightweight API + local storage cache

---

### **2. Generated Project Structure**

* **Presentation:** Views, widgets, controllers
* **Domain:** Entities (Metric, Assumption, Model)
* **Data:** Parsers, storage, AI client
* **Routing:** GoRouter
* **Theme system:** Centralized

---

### **3. AI Integration Plan**

* API client bound to JSON schemas
* Timeout + retry strategy
* Offline persistence for assumptions
* Mock AI responses for test mode

---

## ✨ **Phase 6 — Flutter Experience & UX Crafting**

### **1. Interaction Style**

* Minimal cognitive load
* Immediate feedback after actions
* Micro-affirmations for progress

---

### **2. Animation Decisions**

* Smooth transitions between stages
* Subtle loading shimmer during extraction
* Avoid heavy animations for charts

---

### **3. UI Edge Cases**

* Empty models
* Partial extraction
* Missing time-series
* Conflicting values → flagged

---

## 🔁 **Phase 7 — Release & Improvement Loop**

### **1. Logging & Observation**

Log:

* Uploaded doc types
* Metrics successfully extracted
* Edits to assumptions
* Time to first model
* Export/share events
* Drop-off points

Use logs to refine extraction & UX.

---

### **2. Iteration Plan (v1.1)**

* Better headcount modeling
* More accurate growth estimation
* Shopify / Stripe parsing improvement

**Risks to monitor:**

* Over-trust vs under-trust behavior
* Parsing failures
* Confusion around assumptions

**Hypotheses to validate:**

* “Upload → model” is a strong wedge
* Users prefer explainability-first approach
* SaaS-first focus is sufficient to start

---

## 📦 **Final Checklist (Before Build Starts)**

PRD validated ✔
Screens & flows defined ✔
Design system defined ✔
AI contracts locked ✔
Project scaffold approved ✔
Error handling & guardrails planned ✔
Edge cases documented ✔
Iteration loop defined ✔

---



