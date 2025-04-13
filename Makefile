# AIS Data Engineering Project Makefile
# This Makefile automates common tasks for setting up and running the AIS data pipeline

# Environment variables (can be overridden)
PROJECT_DIR := $(shell pwd)
KESTRA_DIR := $(PROJECT_DIR)/kestra
METABASE_DIR := $(PROJECT_DIR)/metabase
TERRAFORM_DIR := $(PROJECT_DIR)/terraform
DBT_DIR := $(PROJECT_DIR)/dbt

# Default target
.PHONY: help
help:
	@echo "AIS Data Engineering Project"
	@echo ""
	@echo "Available commands:"
	@echo "  make help            - Show this help message"
	@echo "  make all             - Set up the complete environment"
	@echo "  make tf-init         - Initialize Terraform"
	@echo "  make tf-plan         - Create a Terraform execution plan"
	@echo "  make tf-apply        - Apply Terraform changes"
	@echo "  make tf-destroy      - Destroy Terraform-managed infrastructure"
	@echo "  make kestra-up       - Start Kestra"
	@echo "  make kestra-down     - Stop Kestra"
	@echo "  make import-flows    - Import Kestra flows"
	@echo "  make metabase-up     - Start Metabase"
	@echo "  make metabase-down   - Stop Metabase"
	@echo "  make clean           - Clean up temporary files"

# Full setup
.PHONY: all
all: tf-apply kestra-up import-flows metabase-up
	@echo "✅ All components have been set up successfully!"
	@echo "  - Kestra: http://localhost:8080"
	@echo "  - Metabase: http://localhost:3000"
	@echo ""
	@echo "Next steps:"
	@echo "1. Complete Metabase setup by following the setup wizard"
	@echo "2. Configure BigQuery connection in Metabase"
	@echo "3. Create dashboards following the implementation guides"

# Terraform commands
.PHONY: tf-init
tf-init:
	@echo "Initializing Terraform..."
	cd $(TERRAFORM_DIR) && terraform init

.PHONY: tf-plan
tf-plan: tf-init
	@echo "Creating Terraform plan..."
	cd $(TERRAFORM_DIR) && terraform plan -out=tfplan

.PHONY: tf-apply
tf-apply: tf-plan
	@echo "Applying Terraform changes..."
	cd $(TERRAFORM_DIR) && terraform apply "tfplan"
	@echo "✅ Infrastructure provisioned successfully"

.PHONY: tf-destroy
tf-destroy:
	@echo "⚠️ WARNING: This will destroy all resources managed by Terraform ⚠️"
	@echo "Are you sure you want to continue? (y/N)"
	@read -p "" CONFIRM; \
	if [ "$$CONFIRM" = "y" ]; then \
		cd $(TERRAFORM_DIR) && terraform destroy; \
		echo "✅ Infrastructure destroyed successfully"; \
	else \
		echo "Operation cancelled"; \
	fi

# Kestra commands
.PHONY: kestra-up
kestra-up:
	@echo "Starting Kestra..."
	cd $(KESTRA_DIR) && docker-compose up -d
	@echo "✅ Kestra is running at http://localhost:8080"

.PHONY: kestra-down
kestra-down:
	@echo "Stopping Kestra..."
	cd $(KESTRA_DIR) && docker-compose down
	@echo "✅ Kestra stopped"

.PHONY: import-flows
import-flows:
	@echo "Importing Kestra flows..."
	@echo "Waiting for Kestra to be ready..."
	@sleep 10
	curl -X POST http://localhost:8080/api/v1/flows/import -F fileUpload=@$(KESTRA_DIR)/flows/ais_data_extraction_and_load.yaml
	curl -X POST http://localhost:8080/api/v1/flows/import -F fileUpload=@$(KESTRA_DIR)/flows/ais_data_transformation.yaml
	@echo "✅ Kestra flows imported successfully"

# Metabase commands
.PHONY: metabase-up
metabase-up:
	@echo "Starting Metabase..."
	cd $(METABASE_DIR) && docker-compose up -d
	@echo "✅ Metabase is running at http://localhost:3000"
	@echo "⚠️ Note: First startup may take a few minutes while Metabase initializes"

.PHONY: metabase-down
metabase-down:
	@echo "Stopping Metabase..."
	cd $(METABASE_DIR) && docker-compose down
	@echo "✅ Metabase stopped"

# Utility commands
.PHONY: clean
clean:
	@echo "Cleaning up temporary files..."
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -delete
	rm -f $(TERRAFORM_DIR)/tfplan
	@echo "✅ Cleanup complete"

# Run dbt models manually (use only for development, Kestra handles this in production)
.PHONY: dbt-run
dbt-run:
	@echo "Running dbt models..."
	cd $(DBT_DIR)/ais_data_project && dbt run
	@echo "✅ dbt models executed"

.PHONY: dbt-test
dbt-test:
	@echo "Testing dbt models..."
	cd $(DBT_DIR)/ais_data_project && dbt test
	@echo "✅ dbt tests completed"
