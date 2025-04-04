Below is a revised work plan that incorporates dbt for transformations, includes a Makefile to streamline setup and deployment, and still uses Airflow (for batch orchestration), BigQuery (as Data Warehouse), GCS (as Data Lake), and Looker Studio (for the dashboard).

⸻

1. High-Level Architecture
	1.	Data Source
	•	Monthly AIS CSV files in ZIP archives (e.g., aisdk-2006-03.zip).
	2.	Data Lake
	•	GCS bucket to store the raw CSV files once extracted from ZIP.
	3.	Data Warehouse
	•	BigQuery as the central analytics database.
	•	You’ll load data first into a staging table and then transform it into a curated table using dbt.
	4.	Orchestration
	•	Airflow DAG runs steps to download, extract, load to GCS, load to staging in BigQuery, and finally invokes dbt for transformations.
	5.	Transformations
	•	dbt for cleaning, partitioning, and shaping data into curated tables (with simple tests).
	6.	Dashboard
	•	Looker Studio with two required tiles: a categorical distribution and a temporal distribution.
	7.	Infrastructure as Code
	•	Terraform to provision GCS buckets, BigQuery datasets, and (optionally) a Cloud Composer environment or other GCP resources for Airflow.
	8.	Reproducibility
	•	A Makefile to manage environment setup, run Terraform, build local Airflow environment (if self-hosted), run dbt commands, etc.
	•	GitHub Actions for CI/CD (optional extra points) – could validate your Airflow DAGs and dbt models on each commit.

⸻

2. Proposed Repository Structure

your-project/
├── README.md
├── Makefile
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── ...
├── airflow/
│   ├── dags/
│   │   └── ais_ingestion_dag.py
│   └── docker-compose.yml   # If running Airflow locally
├── dbt/
│   ├── dbt_project.yml
│   ├── packages.yml
│   ├── models/
│   │   ├── staging/
│   │   │   └── stg_ais_raw.sql
│   │   └── curated/
│   │       └── ais_curated.sql
│   └── tests/
│       └── ...
├── .github/
│   └── workflows/
│       ├── terraform.yml    # or main.yml to run TF plan/apply
│       └── dbt.yml          # or main.yml to run dbt tests
└── ...

Feel free to adjust the folder names as you see fit.

⸻

3. Detailed Steps

3.1 Terraform for GCP Provisioning
	1.	Resources to Create:
	•	A GCS bucket for raw files, e.g., your-ais-raw-bucket.
	•	A BigQuery dataset, e.g., ais_data.
	•	Optionally, a Cloud Composer environment (if you want managed Airflow) or resources for a GCE/GKE-based Airflow deployment.
	2.	Terraform Workflow:
	•	main.tf: define providers (GCP), resources (bucket, dataset).
	•	variables.tf: define variable inputs (like project ID, region).
	•	outputs.tf: output the created resources (e.g., bucket name).
	3.	Makefile Targets:

.PHONY: tf-init tf-plan tf-apply

tf-init:
	cd terraform && terraform init

tf-plan: tf-init
	cd terraform && terraform plan -var="project_id=$(PROJECT_ID)" -out=tfplan

tf-apply:
	cd terraform && terraform apply "tfplan"

	•	Adjust variables/paths as needed.

3.2 Airflow DAG

Goal: Download data → extract CSV → store in GCS → load to BigQuery staging → run dbt.
	1.	Tasks (conceptual):
	•	download_zip: Downloads aisdk-YYYY-MM.zip from the external URL to a local path.
	•	extract_csv: Extracts the CSV from the zip.
	•	upload_to_gcs: Uploads the CSV to GCS (raw zone).
	•	bq_load_staging: Loads the CSV from GCS into ais_data.staging_ais_raw. Possibly uses GCSToBigQueryOperator or a custom Python operator.
	•	dbt_run: Executes a shell command that runs dbt run (and optionally dbt test) against the loaded data, producing a curated table.
	2.	Local vs. Cloud:
	•	If using Cloud Composer, your DAG code just references the operators.
	•	If self-hosting with Docker Compose, you’ll have a docker-compose.yml in airflow/; you can mount your DAGs + dbt project.
	3.	Makefile Targets (conceptual):

.PHONY: airflow-up airflow-down

airflow-up:
	cd airflow && docker-compose up -d

airflow-down:
	cd airflow && docker-compose down

	•	Then you’d open the Airflow UI, trigger the DAG, or schedule it.

3.3 dbt Transformations
	1.	Project Setup:
	•	In dbt_project.yml, specify profile, target, etc.
	•	In your profiles.yml (placed in a safe location or environment variable-based approach), configure the BigQuery connection.
	2.	Models:
	•	stg_ais_raw.sql (optional staging model if you want to rename columns).
	•	ais_curated.sql for main curated table. Example:

select
  cast(timestamp as timestamp) as event_ts,
  type_of_mobile,
  mmsi,
  latitude,
  longitude,
  navigational_status,
  rot,
  sog,
  ... -- other fields
from {{ source('ais_data', 'staging_ais_raw') }}

	•	Then configure partitioning by event_ts in the dbt_project.yml or in a config block in the model:

models:
  your_project:
    curated:
      +materialized: table
      +partition_by: { field: "event_ts", data_type: "timestamp" }
      +cluster_by: ["mmsi"]


	3.	Tests:
	•	In tests/ or your model .yml files, add basic dbt tests:

version: 2
models:
  - name: ais_curated
    tests:
      - dbt_utils.unique:
          column_name: mmsi
      - not_null:
          column_name: event_ts


	4.	dbt & Makefile:

.PHONY: dbt-run dbt-test

dbt-run:
	cd dbt && dbt run --profiles-dir . --target prod

dbt-test:
	cd dbt && dbt test --profiles-dir . --target prod

	•	You can call make dbt-run inside your Airflow dbt_run task or simply do it manually.

3.4 Dashboard in Looker Studio
	1.	Connect: Go to Looker Studio → BigQuery connector → select your ais_data dataset → curated table.
	2.	Create Two Tiles:
	1.	Categorical Distribution: e.g. count of rows grouped by ship_type or type_of_mobile.
	2.	Temporal Distribution: count of rows by day/month from event_ts.
	3.	Formatting:
	•	Add titles, legends, date filters if you like.
	•	Publish or share the dashboard link (if you want read-only public access, you can do that).

⸻

4. Putting It All Together with a Makefile

Below is a sample Makefile that shows how you might chain tasks. You’ll need to adapt it to your folder structure and environment:

PROJECT_ID := your-gcp-project-id

.PHONY: all init tf-plan tf-apply airflow-up airflow-down dbt-run dbt-test pipeline

# 'all' could run the entire pipeline end-to-end
all: tf-apply airflow-up dbt-run

init:
	@echo "Initializing local dev environment..."
	# e.g., install python deps, set up environment variables, etc.

tf-init:
	cd terraform && terraform init

tf-plan: tf-init
	cd terraform && terraform plan -var="project_id=$(PROJECT_ID)" -out=tfplan

tf-apply: tf-plan
	cd terraform && terraform apply "tfplan"

airflow-up:
	cd airflow && docker-compose up -d
	@echo "Airflow is starting up... Please allow ~1 minute for the webserver and scheduler to be ready."

airflow-down:
	cd airflow && docker-compose down

dbt-run:
	cd dbt && dbt run --profiles-dir . --target prod

dbt-test:
	cd dbt && dbt test --profiles-dir . --target prod

# 'pipeline' might do everything in sequence
pipeline: tf-apply airflow-up
	@echo "Triggering Airflow DAG to run ingestion..."
	# Possibly call an Airflow CLI command or just prompt user to trigger the DAG in UI

Notes:
	•	Some steps (like triggering the DAG) might be easier to do manually in Airflow UI, but you can automate using the Airflow CLI or the Airflow REST API.
	•	If using Cloud Composer, you might not need the docker-compose steps.

⸻

5. Final Deliverables
	1.	Repository with:
	•	Clear README explaining what the project does, how to set it up, and how to run it.
	•	Terraform code for provisioning.
	•	Airflow DAG for ingestion.
	•	dbt models/tests for transformations.
	•	Makefile to simplify repeated tasks.
	•	Optionally GitHub Actions or other CI/CD config.
	2.	Looker Studio Dashboard:
	•	At least two tiles showing:
	1.	Ship Type (or navigational status) distribution.
	2.	Count of AIS messages over time.
	•	Provide screenshots or a direct link in your README.
	3.	Bonus:
	•	Infrastructure diagram describing the flow (Source → GCS → BigQuery → dbt → Looker).
	•	Additional dbt tests, data checks, or partition/clustering rationale in the README.

⸻

6. Recommended Timeline (Given ~10 days, 1-2 hrs/day)
	1.	Days 1-2:
	•	Set up Terraform & GCP resources.
	•	Confirm GCS bucket & BigQuery dataset creation.
	2.	Days 3-4:
	•	Configure Airflow (local Docker Compose or Cloud Composer).
	•	Create the DAG with tasks to ingest AIS data.
	3.	Days 5-6:
	•	Implement dbt transformations, including minimal models & tests.
	•	Make sure “staging” → “curated” workflow works on sample data.
	4.	Days 7-8:
	•	Integrate Airflow DAG calling dbt run.
	•	Add or refine the Makefile so you can spin up/down quickly.
	5.	Days 9:
	•	Create Looker Studio dashboard with two tiles.
	•	Test everything end-to-end with an actual monthly ZIP file.
	6.	Day 10:
	•	Clean up & Document: finalize README, code comments, diagram.
	•	(Optional) set up GitHub Actions to test Terraform plan & dbt.

⸻

Key Takeaways
	•	You’ll demonstrate a batch data pipeline with Airflow orchestrating the steps.
	•	dbt handles your transformations, including simple tests and separate staging/curated models.
	•	BigQuery is partitioned by date/time for efficient queries.
	•	Looker Studio provides a user-friendly dashboard.
	•	Terraform ensures reproducible GCP infrastructure.
	•	The Makefile automates local tasks, making life easier and the project reproducible for others.

Good luck with your project! This setup should satisfy all major points (cloud usage, orchestrated batch pipeline, DWH with partitioning, dbt transformations, reproducibility with IaC, and a two-tile dashboard).