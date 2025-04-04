# AIS Data Engineering Pipeline Makefile
# This Makefile provides targets for common operations in the project

# Variables
PROJECT_ID ?= your-gcp-project-id  # Set via command line or environment
REGION ?= us-central1              # Default GCP region
BUCKET_NAME ?= ais-data-lake       # GCS bucket name prefix

.PHONY: all init tf-init tf-plan tf-apply airflow-up airflow-down dbt-run dbt-test pipeline clean

# 'all' runs the entire pipeline end-to-end
all: tf-apply airflow-up dbt-run

# Initialize the project
init:
	@echo "Initializing project environment..."
	@echo "Installing Python dependencies..."
	pip install -r requirements.txt || (echo "No requirements.txt found, skipping"; exit 0)
	@echo "Project initialized successfully"

# Terraform targets
tf-init:
	@echo "Initializing Terraform..."
	cd terraform && terraform init

tf-plan: tf-init
	@echo "Creating Terraform plan..."
	cd terraform && terraform plan \
		-var="project_id=$(PROJECT_ID)" \
		-var="region=$(REGION)" \
		-var="bucket_name=$(BUCKET_NAME)" \
		-out=tfplan

tf-apply: tf-plan
	@echo "Applying Terraform changes..."
	cd terraform && terraform apply "tfplan"
	@echo "Infrastructure provisioned successfully"

# Airflow targets
airflow-up:
	@echo "Starting Airflow with Docker Compose..."
	cd airflow && docker-compose up -d
	@echo "Airflow is starting up... Please wait ~1 minute for services to be ready"
	@echo "Access the Airflow UI at http://localhost:8080"

airflow-down:
	@echo "Stopping Airflow containers..."
	cd airflow && docker-compose down
	@echo "Airflow has been stopped"

# dbt targets
dbt-run:
	@echo "Running dbt models..."
	cd dbt && dbt run --profiles-dir . --target prod

dbt-test:
	@echo "Running dbt tests..."
	cd dbt && dbt test --profiles-dir . --target prod

# Run the complete pipeline (may require manual Airflow DAG trigger)
pipeline: tf-apply airflow-up
	@echo "Infrastructure and Airflow are ready"
	@echo "Please trigger the 'ais_ingestion_dag' in the Airflow UI at http://localhost:8080"
	@echo "After the DAG completes, run 'make dbt-run' to apply transformations"

# Clean up local environment (does not affect cloud resources)
clean:
	@echo "Cleaning up local environment..."
	cd airflow && docker-compose down -v || true
	rm -rf terraform/.terraform terraform/tfplan || true
	@echo "Local environment cleaned"

# Helper message
help:
	@echo "AIS Data Engineering Pipeline Makefile"
	@echo "-------------------------------------"
	@echo "Available targets:"
	@echo "  init          Initialize the project"
	@echo "  tf-init       Initialize Terraform"
	@echo "  tf-plan       Create Terraform execution plan"
	@echo "  tf-apply      Apply Terraform changes"
	@echo "  airflow-up    Start Airflow with Docker Compose"
	@echo "  airflow-down  Stop Airflow containers"
	@echo "  dbt-run       Run dbt models"
	@echo "  dbt-test      Run dbt tests"
	@echo "  pipeline      Run the complete pipeline"
	@echo "  clean         Clean up local environment"
	@echo "  help          Display this help message"
	@echo ""
	@echo "Usage example:"
	@echo "  make tf-apply PROJECT_ID=my-gcp-project REGION=us-east1"
	@echo "  make airflow-up"
	@echo "  make dbt-run"
