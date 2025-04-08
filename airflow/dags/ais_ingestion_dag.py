"""
AIS Data Ingestion DAG
This DAG orchestrates the ETL process for AIS (Automatic Identification System) data:
1. Downloads ZIP files containing AIS data
2. Extracts CSV files from the ZIP archives
3. Uploads extracted files to Google Cloud Storage (GCS)
4. Loads data from GCS to BigQuery staging tables
5. Triggers dbt transformations for data modeling
"""

import os
from datetime import datetime, timedelta
from pathlib import Path
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator
from airflow.providers.google.cloud.hooks.gcs import GCSHook
from airflow.utils.dates import days_ago
import requests
import tempfile
import zipfile
import csv
import logging

# Configuration variables
# These could be moved to environment variables or Airflow Variables
PROJECT_ID = os.environ.get('GCP_PROJECT_ID', 'your-gcp-project-id')
BUCKET_NAME = os.environ.get('GCS_BUCKET_NAME', 'ais-data-lake')
STAGING_DATASET = os.environ.get('BQ_STAGING_DATASET', 'ais_staging')
RAW_TABLE_NAME = 'stg_ais_raw'
BASE_URL = "https://coast.noaa.gov/htdata/CMSP/AISDataHandler"  # Example URL, adjust as needed

# DAG parameters for date range selection (can be overridden with Airflow UI)
# Format: YYYY-MM-DD
DEFAULT_START_DATE = os.environ.get('AIS_START_DATE', '{{ macros.ds_add(ds, -30) }}')  # Default to 30 days before execution
DEFAULT_END_DATE = os.environ.get('AIS_END_DATE', '{{ ds }}')  # Default to execution date

# Schema definition for BigQuery loading
# This should match the expected structure of AIS CSV files
SCHEMA_FIELDS = [
    {"name": "timestamp", "type": "TIMESTAMP", "mode": "NULLABLE"},
    {"name": "mmsi", "type": "INTEGER", "mode": "NULLABLE"},
    {"name": "latitude", "type": "FLOAT", "mode": "NULLABLE"},
    {"name": "longitude", "type": "FLOAT", "mode": "NULLABLE"},
    {"name": "sog", "type": "FLOAT", "mode": "NULLABLE"},  # Speed Over Ground
    {"name": "cog", "type": "FLOAT", "mode": "NULLABLE"},  # Course Over Ground
    {"name": "heading", "type": "INTEGER", "mode": "NULLABLE"},
    {"name": "vessel_name", "type": "STRING", "mode": "NULLABLE"},
    {"name": "imo", "type": "STRING", "mode": "NULLABLE"},
    {"name": "call_sign", "type": "STRING", "mode": "NULLABLE"},
    {"name": "vessel_type", "type": "INTEGER", "mode": "NULLABLE"},
    {"name": "status", "type": "INTEGER", "mode": "NULLABLE"},
    {"name": "length", "type": "FLOAT", "mode": "NULLABLE"},
    {"name": "width", "type": "FLOAT", "mode": "NULLABLE"},
    {"name": "draft", "type": "FLOAT", "mode": "NULLABLE"},
    {"name": "cargo", "type": "INTEGER", "mode": "NULLABLE"}
]

# Default arguments for DAG
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
    'start_date': days_ago(1),
}

# Define DAG
dag = DAG(
    'ais_ingestion_dag',
    default_args=default_args,
    description='ETL DAG for AIS data',
    schedule_interval='@monthly',  # Run monthly to process monthly data dumps
    catchup=False,
    tags=['ais', 'etl', 'gcp'],
    params={
        'start_date': DEFAULT_START_DATE,
        'end_date': DEFAULT_END_DATE,
    },
)

# Function to generate a list of year-month combinations between two dates
def generate_year_month_list(**kwargs):
    """
    Generate a list of year-month combinations between start_date and end_date params.
    Returns a list of dictionaries with year and month values.
    """
    # Get start_date and end_date from DAG parameters or use defaults
    dag_run = kwargs.get('dag_run')
    
    if dag_run and dag_run.conf and 'start_date' in dag_run.conf and 'end_date' in dag_run.conf:
        start_date_str = dag_run.conf['start_date']
        end_date_str = dag_run.conf['end_date']
    else:
        # Get from params with Jinja template rendering
        task_instance = kwargs['ti']
        start_date_str = kwargs['params']['start_date'] 
        end_date_str = kwargs['params']['end_date']
        
        # If these are Jinja templates, we need the rendered values
        if "{{" in start_date_str:
            # If not rendered, use execution date as fallback
            execution_date = kwargs.get('execution_date', datetime.now())
            # Default to 30 days before execution date if not provided
            start_date = execution_date - timedelta(days=30)
        else:
            start_date = datetime.strptime(start_date_str, '%Y-%m-%d')
            
        if "{{" in end_date_str:
            # Default to execution date if not provided
            end_date = kwargs.get('execution_date', datetime.now())
        else:
            end_date = datetime.strptime(end_date_str, '%Y-%m-%d')
    
    # Format to first day of month for consistent processing
    start_date = datetime(start_date.year, start_date.month, 1)
    end_date = datetime(end_date.year, end_date.month, 1)
    
    # Generate list of all year-month combinations
    date_list = []
    current_date = start_date
    while current_date <= end_date:
        date_list.append({
            'year': current_date.strftime('%Y'),
            'month': current_date.strftime('%m'),
            'year_month': current_date.strftime('%Y-%m')
        })
        # Move to next month
        if current_date.month == 12:
            current_date = datetime(current_date.year + 1, 1, 1)
        else:
            current_date = datetime(current_date.year, current_date.month + 1, 1)
    
    logging.info(f"Generated date range: {date_list}")
    return date_list

# Generate the download URL for a specific year and month
def generate_download_url(**kwargs):
    """Generate the download URLs for AIS data based on the date range."""
    ti = kwargs['ti']
    date_list = ti.xcom_pull(task_ids='generate_date_range')
    
    download_urls = []
    for date_item in date_list:
        year = date_item['year']
        month = date_item['month']
        
        # Construct the URL for the specific month and year
        # Example: https://coast.noaa.gov/htdata/CMSP/AISDataHandler/2020/aisdk-2020-01.zip
        url = f"{BASE_URL}/{year}/aisdk-{year}-{month}.zip"
        download_urls.append({
            'url': url,
            'year': year,
            'month': month,
            'year_month': date_item['year_month']
        })
    
    logging.info(f"Generated {len(download_urls)} download URLs")
    return download_urls

# Download the ZIP files
def download_zip_file(**kwargs):
    """Download AIS ZIP files from the generated URLs."""
    ti = kwargs['ti']
    download_items = ti.xcom_pull(task_ids='generate_download_url')
    
    # Create temporary directory for downloads
    temp_dir = tempfile.mkdtemp(prefix='ais_')
    
    download_results = []
    for item in download_items:
        url = item['url']
        year_month = item['year_month']
        
        # Define the zip file path
        zip_path = os.path.join(temp_dir, f"ais-{year_month}.zip")
        
        try:
            logging.info(f"Downloading AIS data from {url} to {zip_path}")
            response = requests.get(url, stream=True)
            response.raise_for_status()  # Raise exception for HTTP errors
            
            with open(zip_path, 'wb') as f:
                for chunk in response.iter_content(chunk_size=8192):
                    f.write(chunk)
            
            logging.info(f"Download completed: {zip_path}")
            download_results.append({
                'zip_path': zip_path, 
                'year_month': year_month,
                'temp_dir': temp_dir
            })
        
        except Exception as e:
            logging.error(f"Error downloading ZIP file from {url}: {e}")
            # Continue with other files even if one fails
            continue
    
    if not download_results:
        raise Exception("All download attempts failed. No data to process.")
        
    return download_results

# Extract CSV files from the ZIP archives
def extract_csv_files(**kwargs):
    """Extract CSV files from multiple ZIP archives."""
    ti = kwargs['ti']
    download_results = ti.xcom_pull(task_ids='download_zip_file')
    
    if not download_results:
        raise Exception("No downloaded files to extract")
    
    # Will hold all extraction results
    extraction_results = []
    
    # Get the temp directory from the first result (should be the same for all)
    main_temp_dir = download_results[0]['temp_dir']
    
    for download_item in download_results:
        zip_path = download_item['zip_path']
        year_month = download_item['year_month']
        
        # Create a subdirectory for this specific year-month data
        extract_dir = os.path.join(main_temp_dir, 'extracted', year_month)
        os.makedirs(extract_dir, exist_ok=True)
        
        try:
            logging.info(f"Extracting ZIP file for {year_month}: {zip_path}")
            with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                zip_ref.extractall(extract_dir)
            
            # Get list of extracted CSV files
            csv_files = [os.path.join(extract_dir, f) for f in os.listdir(extract_dir) 
                      if f.lower().endswith('.csv')]
            
            logging.info(f"Extracted {len(csv_files)} CSV files for {year_month} to {extract_dir}")
            
            extraction_results.append({
                'csv_files': csv_files,
                'extract_dir': extract_dir,
                'temp_dir': main_temp_dir,
                'year_month': year_month
            })
        
        except Exception as e:
            logging.error(f"Error extracting ZIP file {zip_path}: {e}")
            # Continue with other files even if one fails
            continue
    
    if not extraction_results:
        raise Exception("All extraction attempts failed. No data to process.")
    
    return extraction_results

# Upload CSV files to GCS
def upload_to_gcs(**kwargs):
    """Upload extracted CSV files to Google Cloud Storage."""
    ti = kwargs['ti']
    extraction_results = ti.xcom_pull(task_ids='extract_csv_files')
    
    if not extraction_results:
        raise Exception("No extracted files to upload")
    
    # Initialize GCS hook
    gcs_hook = GCSHook(gcp_conn_id='google_cloud_default')
    
    uploaded_files = []
    for extract_info in extraction_results:
        csv_files = extract_info['csv_files']
        year_month = extract_info['year_month']
        
        for csv_file in csv_files:
            # Generate GCS object name based on original filename and year_month
            filename = os.path.basename(csv_file)
            gcs_object_name = f"raw/ais/{year_month}/{filename}"
            
            try:
                logging.info(f"Uploading {csv_file} to gs://{BUCKET_NAME}/{gcs_object_name}")
                gcs_hook.upload(
                    bucket_name=BUCKET_NAME,
                    object_name=gcs_object_name,
                    filename=csv_file
                )
                uploaded_files.append({
                    'uri': f"gs://{BUCKET_NAME}/{gcs_object_name}",
                    'year_month': year_month
                })
            
            except Exception as e:
                logging.error(f"Error uploading file to GCS: {e}")
                # Continue with other files even if one fails
                continue
    
    if not uploaded_files:
        raise Exception("All upload attempts failed. No files were uploaded to GCS.")
    
    logging.info(f"Uploaded {len(uploaded_files)} files to GCS")
    return uploaded_files

# Clean up temporary files
def cleanup_temp_files(**kwargs):
    """Clean up temporary files after processing."""
    ti = kwargs['ti']
    extraction_results = ti.xcom_pull(task_ids='extract_csv_files')
    
    if not extraction_results or not isinstance(extraction_results, list) or not extraction_results[0]:
        logging.warning("No extraction results found for cleanup")
        return
    
    # Get the main temp directory (should be the same for all extractions)
    main_temp_dir = extraction_results[0]['temp_dir']
    
    try:
        logging.info(f"Cleaning up temporary directory: {main_temp_dir}")
        import shutil
        shutil.rmtree(main_temp_dir)
        logging.info(f"Cleanup completed")
    
    except Exception as e:
        logging.warning(f"Warning during cleanup: {e}")
        # Don't raise exception here to avoid failing the DAG if cleanup fails

# Function to process GCS files and load to BigQuery
def process_gcs_to_bq(**kwargs):
    """Process uploaded files from GCS and load to BigQuery."""
    ti = kwargs['ti']
    uploaded_files = ti.xcom_pull(task_ids='upload_to_gcs')
    
    if not uploaded_files:
        logging.warning("No GCS files found to load to BigQuery")
        return
    
    # Load each file to BigQuery without partitioning
    for i, file_info in enumerate(uploaded_files):
        gcs_uri = file_info['uri']
        # Extract just the URI without gs:// prefix
        gcs_object = gcs_uri.replace(f"gs://{BUCKET_NAME}/", "")
        
        # Create a BQ load task for this specific file
        load_task_id = f'load_to_bq_{i}'
        task = GCSToBigQueryOperator(
            task_id=load_task_id,
            bucket=BUCKET_NAME,
            source_objects=[gcs_object],
            destination_project_dataset_table=f"{PROJECT_ID}.{STAGING_DATASET}.{RAW_TABLE_NAME}",
            schema_fields=SCHEMA_FIELDS,
            source_format='CSV',
            skip_leading_rows=1,
            write_disposition='WRITE_APPEND',
            create_disposition='CREATE_IF_NEEDED',
            dag=dag
        )
        
        # Execute the task
        task.execute(context=kwargs)
        logging.info(f"Loaded {gcs_object} to BigQuery")

# dbt transformations will be handled separately

# Create task instances
# Task to generate the date range list
generate_date_range_task = PythonOperator(
    task_id='generate_date_range',
    python_callable=generate_year_month_list,
    provide_context=True,
    dag=dag,
)

generate_url_task = PythonOperator(
    task_id='generate_download_url',
    python_callable=generate_download_url,
    provide_context=True,
    dag=dag,
)

download_task = PythonOperator(
    task_id='download_zip_file',
    python_callable=download_zip_file,
    provide_context=True,
    dag=dag,
)

extract_task = PythonOperator(
    task_id='extract_csv_files',
    python_callable=extract_csv_files,
    provide_context=True,
    dag=dag,
)

upload_task = PythonOperator(
    task_id='upload_to_gcs',
    python_callable=upload_to_gcs,
    provide_context=True,
    dag=dag,
)

cleanup_task = PythonOperator(
    task_id='cleanup_temp_files',
    python_callable=cleanup_temp_files,
    provide_context=True,
    dag=dag,
)

# Create a dedicated task for loading to BigQuery
load_to_bigquery_task = PythonOperator(
    task_id='load_to_bigquery',
    python_callable=process_gcs_to_bq,
    provide_context=True,
    dag=dag,
)

# Set task dependencies
generate_date_range_task >> generate_url_task >> download_task >> extract_task >> upload_task
upload_task >> load_to_bigquery_task
upload_task >> cleanup_task
