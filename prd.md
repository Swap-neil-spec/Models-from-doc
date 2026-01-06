Here’s a clean V1 PRD you can actually build from and use to stress test PMF.

---

# PRD: V1 MVP – “Model from Docs” Financial Forecaster

## 1. Product summary

**Working name**
ModelFromDocs (MFD)

**One line**
Turn messy startup docs into a clean, investor ready financial model in under 30 minutes.

**What it does**
Founders and finance partners upload existing documents. The product reads those docs, extracts key metrics and assumptions, and builds a simple forward looking model with cash runway, revenue, and burn. Users can review and edit all assumptions before locking in the model.

This V1 is not trying to be a full FP&A platform. It is a fast wedge to test if:

* Founders actually want “upload docs → get a model”
* They trust the output enough to refine and share it
* They will use it again after the first model

---

## 2. Problem and goals

### 2.1 Problem

Early stage founders face three issues:

1. Building financial models is slow and painful

   * They dig through investor updates, Stripe exports, P&Ls and headcount sheets.
   * Then they spend hours in Excel or Google Sheets wiring formulas.

2. Existing templates are generic and hard to adapt

   * Most templates assume a “standard” SaaS or generic business.
   * They break when founders add new revenue streams or do not match their actual data.

3. Numbers are scattered across many files

   * Bank balances in statements, MRR in a deck, COGS in a P&L, headcount in payroll exports.
   * Founders copy and paste by hand, which is error prone.

### 2.2 V1 goals

1. **From docs to draft model in one sitting**
   User can go from “no model” to a basic 18 month forecast in under 30 minutes.

2. **Trust in assumptions**
   User can see exactly which document and snippet each input came from, and can edit it.

3. **Useful enough to share**
   User exports or shares the model with at least one teammate, advisor or investor.

4. **Learn what “must have” looks like**
   Through usage and interviews, identify which parts are core to PMF and which are nice to have.

### 2.3 Non goals for V1

* Full three statement GAAP modelling with detailed balance sheet and tax.
* Deep scenario simulation, Monte Carlo, complex capital structure.
* Live bi directional sync with accounting and HR systems.
* A full CFO analytics suite.

---

## 3. Target users and jobs to be done

### 3.1 Primary persona

**Early stage founder or COO**
Seed to Series A. Comfortable with numbers but not a finance pro.

Jobs they want to get done:

* “I need a forecast and runway view for a board deck next week.”
* “I want to know how much to raise and when.”
* “I want a clean model that matches our actuals, without doing all the grunt work.”

### 3.2 Secondary persona

**Fractional CFO / finance consultant**

Jobs:

* “I need to build a baseline model for a new client fast.”
* “I want to stop rebuilding the same model shell from scratch each time.”

For PMF stress test, focus V1 onboarding on:

* SaaS and SaaS-like products
* Some D2C and marketplace support, but SaaS is the main wedge

---

## 4. Scope of V1

### 4.1 In scope

1. **Upload and parse docs**

   * Support: PDF, PPTX, DOCX, CSV, basic XLSX.
   * Extract text and tables.

2. **Detect and extract core metrics**
   From the uploaded docs, extract:

   * Opening cash and latest date
   * Recent monthly revenue (at least last 6–12 months if present)
   * Current MRR and ARR (if present)
   * Gross margin (or revenue and COGS to compute it)
   * Headcount count and basic salary ranges or totals
   * Average monthly burn from P&L or bank data if possible

3. **Fill a simple base model schema**
   Build a minimal 18 month model with:

   * Revenue per month
   * Total operating costs per month
   * Net burn per month
   * Cash balance per month
   * Runway end date

4. **Assumption review screen**

   * Show each key assumption in a table.
   * Show where it came from (doc name and text snippet).
   * Allow user to edit any value before generating the full model.

5. **Basic templates by business type**
   Ask user to select one of:

   * SaaS / subscription
   * D2C / e-commerce
   * Marketplace
   * Other (simple “top line growth” template)

   Use this to pick a suitable revenue logic:

   * SaaS: grow MRR by rate derived from last few months, show churn if available.
   * D2C: grow monthly revenue based on recent average growth and seasonality hints.
   * Marketplace: grow GMV and apply a take rate.

6. **Simple dashboard**
   Show:

   * Cash line over time
   * Monthly revenue
   * Monthly burn
   * Runway summary (“Cash out in month X”)

7. **Export and share**

   * Export to CSV and simple Excel format.
   * Export a one page PDF summary.
   * Generate a shareable read only link for the dashboard and key tables.

8. **Event logging for learning**

   * Track: doc uploads, assumptions auto filled, edits made, model creation, exports, returns.

### 4.2 Out of scope V1

* Multi scenario comparison views.
* Detailed headcount by person and role with hiring plans on a timeline.
* Direct bank API connections.
* Real time sync to QuickBooks, Xero, HR tools.
* Multi company support in one workspace.
* Deep permissions and team roles.

---

## 5. Core concepts and data model (V1)

Keep the model simple and explicit.

### 5.1 Core entities

1. **Workspace**

   * One company per workspace for V1.
   * Fields: company name, currency, model start month.

2. **Document**

   * Metadata: id, name, type guess (deck, pnl, statement, kpi_email, csv), upload date.

3. **Metric**

   * A fact extracted from docs.
   * Fields: name, value, unit, as_of date, source document id, source snippet, confidence.

4. **Assumption**

   * Chosen input that will drive the model.
   * Fields: key (e.g. `opening_cash`), value, unit, origin (`user` or `extracted`), linked metric ids.

5. **Model**

   * Time series for revenue, costs, cash, plus summary metrics.
   * For V1, store as arrays per month.

---

## 6. User flows

### 6.1 Flow A: Founder builds first model from docs

1. **Create workspace**

   * User enters company name, picks currency, picks business type template.

2. **Upload docs**

   * User drags in: latest P&L, recent investor deck, Stripe/Shopify export, bank statement.
   * System shows upload progress and a simple list of docs detected.

3. **Auto extraction**

   * Backend parses docs and runs extraction for:

     * Opening cash
     * Latest monthly revenue
     * Recent monthly revenue history (if table)
     * Gross margin (or revenue and COGS)
     * Headcount and salary totals
   * While this happens, show a small status line like: “Looking for cash, revenue, headcount in your files.”

4. **Assumptions review screen**

   * Show table:

     * Field (Opening cash, Current MRR, Average monthly burn, Gross margin, Horizon months)
     * Value
     * As of date
     * Source snippet inline
     * Confidence indicator

   * User can click each row to:

     * See full source snippet and document.
     * Edit the value and date.

   * For any missing critical fields, show an empty row and a simple input box.

5. **Generate model**

   * User clicks “Build model”.
   * Backend builds 18 month forecast using:

     * Historical trend for revenue.
     * Burn and gross margin.
     * Simple rules such as “continue average growth, hold margins constant unless user changes.”

6. **View dashboard**

   * User sees:

     * Line chart: cash over next 18 months.
     * Bars: revenue and burn per month.
     * Text summary: “At current plan you run out of cash in Month/Year.”

   * User can tweak a few high level sliders:

     * Monthly revenue growth rate
     * Monthly opex growth
     * One time fundraise amount and month

   * Chart updates in real time.

7. **Export or share**

   * User can download:

     * Excel with monthly table.
     * PDF with charts and a table.
   * Or copy a shareable link.

8. **Feedback prompt**

   * After export or share, ask:

     * “Was this model useful?”
     * “What did you still have to fix by hand?”

### 6.2 Flow B: Fractional CFO starts a client model

Similar to Flow A but with an extra step:

* CFO may want to review metrics first and override more assumptions.
* Provide a “start from scratch with extracted hints” mode:

  * Show extracted metrics as suggestions alongside empty input fields.

---

## 7. Functional requirements

### 7.1 Upload and parsing

* Accept files up to a reasonable size per file (for V1, say 10–25 MB).
* Support multiple files per workspace.
* Extract text from PDFs, DOCX, PPTX.
* Extract tables from PDFs and spreadsheets into structured form.

### 7.2 Document classification

* Basic heuristic tagging of docs:

  * If text includes “Profit and Loss” or “Income Statement” → classify as P&L.
  * If there are many monthly columns and “Revenue” row → financial table.
  * If many slides, short texts → deck.

This improves targeted extraction later but does not need to be perfect.

### 7.3 Metric extraction

For V1 focus on a hard coded set of metric templates:

* Opening cash balance
* Monthly revenue (time series if a table is present)
* Latest MRR and ARR
* Gross margin or COGS and revenue
* Total headcount
* Total payroll or average salary
* Average monthly burn

Each metric extractor should:

* Search in the most likely documents first (P&L for revenue, bank statement for cash).
* Return structured data: value, currency, date, source doc, snippet, confidence.

If multiple candidates are found:

* Pick the latest by date.
* Keep others as alternates for later use or debugging.

### 7.4 Assumption builder

* Map metrics into a standard set of assumptions:

  * `opening_cash`
  * `start_month`
  * `revenue_history` (array of month/value)
  * `base_growth_rate`
  * `gross_margin`
  * `monthly_opex`
  * `headcount_now`

* If no metric is found for a required assumption:

  * Leave blank and mark as “required” for user input.

* Estimate base growth and margins from history if enough data exists.

### 7.5 Forecast engine

Implement simple, deterministic logic per template.

Example for SaaS:

* Use last 6–12 months revenue to compute average monthly growth.
* Use that as future growth rate, with a floor and a ceiling.
* Compute future revenue per month.
* Apply gross margin to get gross profit.
* Use current monthly opex and a simple opex growth rate (default a small percent or zero).
* Net burn = opex minus gross profit.
* Cash = previous cash minus burn, plus any fundraise events set by user.

For D2C and marketplace, same pattern but with minor tweaks in naming. For V1, all three can share the same underlying math; the difference is mostly copy and labels in the UI.

### 7.6 Dashboard and editing

* Chart library with three key views:

  * Cash balance over time.
  * Revenue and burn per month.
  * Summary cards: runway length, last month revenue, current burn.

* Simple controls:

  * Growth rate adjustment.
  * Opex growth adjustment.
  * One extra cash injection.

* Changes to controls should recalc forecast within a second.

### 7.7 Export and share

* Export:

  * CSV or Excel: columns by month, rows for revenue, gross profit, opex, net burn, cash.
  * PDF: snapshot of current dashboard and summary table.

* Share:

  * Create a public but unguessable URL for read only view.
  * Shared view shows charts and a summary, no editing.

---

## 8. Non functional requirements

* Simple and fast. First model build should complete within a minute after upload on typical files.
* Reliable parsing. If parsing fails on a doc, show a helpful message and let user proceed with partial data.
* Clear error states. Never silently ignore failures; always show what was not found or used.
* Data security basics:

  * Encrypted at rest and in transit.
  * Clear messaging that user can delete a workspace and its files.

---

## 9. PMF and experiment design

The main purpose of this V1 is to test:

* Is “upload docs → auto model” a strong wedge?
* Do founders trust and keep using it?

### 9.1 Key hypotheses

1. **Speed hypothesis**
   If we can give a decent first model in under 30 minutes, founders will use it instead of starting in Excel.

2. **Trust hypothesis**
   If we show clear links from assumptions to document snippets, users will trust the numbers and are more likely to adopt.

3. **Share value hypothesis**
   If the output is good enough to share with an investor or advisor, users will return and edit the model rather than discarding it.

### 9.2 Launch slice

* Target a small group of:

  * 10–20 SaaS founders in an accelerator or community.
  * 5–10 fractional CFOs who work with many early stage clients.

### 9.3 Core metrics

**Acquisition and activation**

* Number of workspaces created.
* Percent of users who:

  * Upload at least one doc.
  * Reach the assumptions review screen.
  * Generate at least one model.

**Time to first value**

* Median time from first upload to first model build.

**Trust and quality**

* Percent of assumptions edited by user (too many edits may mean bad extraction; zero edits may mean blind trust; look for healthy middle).
* Qualitative score from a quick survey after first export:

  * “How close was the model to what you needed?” (1–5)
  * “Would you use this again next month?” (Yes/No)

**Retention and depth**

* Percent of users who:

  * Return within 2 weeks.
  * Create a second model or update the first.
* Count of exports and share link creations per workspace.

### 9.4 Experiments

1. **Assumptions screen layout test**

   * Version A: plain table.
   * Version B: table plus a short natural language summary at top (“We think you have 12 months of runway, based on …”).
   * Measure edit rate and completion rate.

2. **Onboarding question order**

   * Ask for business type first vs ask for docs first.
   * See which order reduces drop off and clarifies expectations.

3. **Output usefulness interviews**

   * After users share or export, do short calls:

     * What did you still fix by hand in Excel?
     * Where did the tool guess wrong?
     * What would make this “your default” tool?

Those findings drive V2.

---

## 10. Open questions to validate with V1

You do not need to solve these now, but V1 should help answer:

* Do founders want a deeper headcount and hiring plan feature or is simple burn enough?
* Is people’s mental model “this replaces my Excel model” or “this helps me start and then I move to Excel”?
* Which file types are most common in the wild and should be prioritized for better extraction?
* Is “SaaS only” a strong enough wedge for PMF, or do we need better support for e-commerce and marketplaces earlier?

---

