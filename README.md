# Business Intelligence – WS 2025 (Group 061)

Collection repository for the three deliverables of the course
**188.429 Business Intelligence (VU 4,0), TU Wien, WS 2025**. It covers the full
BI stack of the course: from dimensional data-warehouse design through OLAP/MDX
to a data-mining project following CRISP-DM, including automatic provenance
documentation.

**Authors (Group 061):** Tim Greß and Stefan Merdian
**Student IDs:** 12412672, 12433732

---

## Overview

The repository consists of three self-contained parts:

| Directory      | Topic                                              | Core technologies                        |
| -------------- | -------------------------------------------------- | ---------------------------------------- |
| `DWH1/`        | Data Warehouse Part 1 – star schema & SQL ETL      | PostgreSQL, SQLAlchemy, Pandas, PROV-O   |
| `DWH2/`        | Data Warehouse Part 2 – OLAP cube & MDX analytics  | PostgreSQL, Atoti, MDX                    |
| `Assignment3/` | Data Analytics following CRISP-DM (NBA dataset)    | scikit-learn, Pandas, PROV-O, StarVers   |

Each part is driven by an orchestrating Jupyter notebook that runs the
individual steps (DDL, ETL, checks, analytics) in order.

---

## Project structure

```
BusinessIntelligence/
├── DWH1/                       # Air-Quality Data Warehouse – Part 1
│   ├── AirQ_Part1_061.ipynb    # Orchestration notebook (steps 1–10)
│   ├── student_bootstrap_061.sql  # One-time setup: DB 'airq' + role grp_061
│   ├── ddl/                    # CREATE/RESET scripts for stg, ext and dwh schemas
│   ├── csv/ , data/            # Source data (sensors, cities, alerts, emissions …)
│   ├── etl/                    # SQL ETL: 9 dimensions + 2 fact tables
│   ├── post/                   # Post-ETL quality / integrity checks
│   ├── sqldump/                # Exported dump of the finished warehouse
│   ├── prov/                   # PROV-O provenance (JSON-LD)
│   ├── AIRQ_ERD_dhw_diagram.png   # ER diagram of the star schema
│   └── environment-dwh.yaml    # Conda environment for the DWH parts
│
├── DWH2/                       # Air-Quality Data Warehouse – Part 2 (OLAP)
│   ├── AirQ_Part2_061.ipynb    # Orchestration notebook (steps 1–13)
│   ├── ddl/                    # CREATE/RESET for stg2 and dwh2 schemas
│   ├── csv/                    # Source data
│   ├── etl/                    # ETL for aggregated fact table param_city_month
│   ├── sql/                    # SQL variants of the business questions
│   ├── mdx/                    # MDX queries (Q03–Q29) against the Atoti cube
│   ├── mdx_out/                # Result CSVs + mdx_index.csv (runtime/rows)
│   ├── pdf/                    # Exported results of individual questions
│   ├── sqldump/                # Dump of the Part 2 warehouse
│   └── Report_Part2_Group_061.pdf
│
├── Assignment3/                # Data Analytics following CRISP-DM
│   ├── Ass3.ipynb              # End-to-end notebook (CRISP-DM + PROV-O)
│   ├── data/all_seasons.csv    # NBA player dataset (all seasons)
│   ├── diagrams/               # Generated plots (distributions, correlation,
│   │                           #   outliers, tuning, residuals, RMSE baselines)
│   └── BI-report.pdf           # Final report
│
├── requirements.txt            # Python dependencies (Assignment 3)
└── README.md
```

---

## Prerequisites

- **Python 3.12**
- **PostgreSQL** (local, for `DWH1` and `DWH2`)
- **Jupyter Lab / Notebook**
- For the data-warehouse parts a **Conda environment** (see
  `environment-dwh.yaml`); for Assignment 3 `requirements.txt` is sufficient.

---

## Setup

### Data-warehouse parts (DWH1 / DWH2)

```bash
# Create and activate the Conda environment
conda env create -f DWH1/environment-dwh.yaml
conda activate dwh
```

The environment includes `pandas`, `sqlalchemy`, `psycopg2-binary`,
`sqlparse`, `jupyterlab` and `atoti` (for the OLAP cube in DWH2), among others.

**One-time database setup** (creates the `airq` database and the `grp_061`
role – must be run as a PostgreSQL superuser):

```bash
psql -U postgres -f DWH1/student_bootstrap_061.sql
```

> Afterwards do **not** work as the `postgres` role anymore; connect via the
> `grp_061` role instead. The connection parameters are set in each notebook
> (section *Configuration & preflight*).

### Assignment 3 (Data Analytics)

```bash
python -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

Besides `scikit-learn`, `pandas`, `seaborn`, `matplotlib` and `plotly`,
`requirements.txt` also contains
[`starvers`](https://github.com/AllStarsAT/starvers) for versioned provenance
documentation in the knowledge graph.

---

## DWH1 – Air-Quality Data Warehouse (Part 1)

Builds a classic **star schema** for air-quality sensor data. The notebook
`AirQ_Part1_061.ipynb` walks through:

1. Configuration & preflight checks
2. Database connection
3. Reset & create the schemas (`stg_061`, `ext_061`, `dwh_061`)
4. Load the CSV source data into staging via Pandas `.to_sql()`
5. Create the warehouse from the DDL files
6. **SQL-first ETL** – all scripts in `etl/` in order
7. **Post-ETL checks** – scripts in `post/` (value ranges, date consistency,
   row counts, no NULLs in keys, integrity)
8. Export the `sqldump/`
9. Generate the PROV-O provenance (JSON-LD)
10. Submission checklist

**Model:** 9 dimensions (`dim_timeday`, `dim_servicetype`, `dim_parameter`,
`dim_sensortype`, `dim_technician`, `dim_device`, `dim_readingmode`,
`dim_alert`, `dim_emissionsource`) and 2 fact tables (`ft_SensorData`,
`ft_service_event`). The ER diagram is in `AIRQ_ERD_dhw_diagram.png`.

---

## DWH2 – OLAP cube & MDX analytics (Part 2)

Condenses the data into an aggregated fact table `ft_param_city_month`
(dimensions `dim_timemonth`, `dim_city`, `dim_param`, `dim_alertpeak`) and
builds an **OLAP cube with Atoti** on top of it. The notebook
`AirQ_Part2_061.ipynb` covers:

1.–6. Configuration, DB connection, staging/warehouse setup and ETL
   (analogous to Part 1, schema `stg2_061` / `dwh2_061`)
7. SQL variants of the business questions (`sql/`)
8.–9. Build the Atoti cube, define hierarchies and measures
10. **MDX queries** for ten business questions (Q03–Q29)
11. Batch executor: runs all `.mdx` files, writes result CSVs to `mdx_out/`
    and produces an overview `mdx_index.csv`
12. Export the `sqldump/`
13. Submission checklist

The finished query results are stored as CSV in `mdx_out/` and as PDF in
`pdf/`; a summary can be found in `Report_Part2_Group_061.pdf`.

---

## Assignment 3 – Data Analytics (CRISP-DM)

Regression project on the **NBA player dataset** (`all_seasons.csv`, all
seasons). The goal is to predict a player's **`net_rating`** in order to support
acquisition decisions with data. The notebook `Ass3.ipynb` follows the
**CRISP-DM process**:

- **Business Understanding** – goal definition & success criteria
- **Data Understanding** – distributions, correlations, outliers, plausibility
- **Data Preparation** – imputation (median / most frequent), encoding
- **Modeling** – `RandomForestRegressor` (scikit-learn) within a pipeline
- **Evaluation** – RMSE / MAE / R² against simple baselines, hyperparameter
  tuning (`max_depth`), residual analysis, fairness considerations
  (e.g. USA vs. non-USA, drafted vs. undrafted)
- **Deployment** – conceptual (out of scope within the course)

All experiments are automatically documented in a provenance knowledge graph
via **PROV-O** (roles *code-writer* / *code-executor*); at the end a LaTeX
report can be generated from the provenance logs. The generated figures are in
`diagrams/`, the final report in `BI-report.pdf`.

---

## Running

Open the notebook in the respective directory and run the cells in order:

```bash
jupyter lab DWH1/AirQ_Part1_061.ipynb
jupyter lab DWH2/AirQ_Part2_061.ipynb
jupyter lab Assignment3/Ass3.ipynb
```

> Before running the DWH notebooks, the one-time database setup
> (`student_bootstrap_061.sql`) must have been executed. In Assignment 3, set
> your own student ID as the *code-executor* before running so that the
> provenance is attributed correctly.

---

## License

MIT License – Copyright (c) 2025 Tim Greß, Stefan Merdian.

```
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
