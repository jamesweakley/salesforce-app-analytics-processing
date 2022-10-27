# salesforce-app-analytics-processing
Basic scripts to download Salesforce app analytics data and upload to Snowflake

## You will need
- sfdx CLI installed and configured, and connected to your Dev Hub
- Common command line tools: jq, curl
- Python 3

## Step 1: Create Snowflake tables
Create the table using the SQL script in APP_ANALYTICS.sql

## Step 2: Download the app analytics to a local CSV
The extract_app_analytics_data.sh script downloads app analytics data within a given date range, saves it locally as "download.csv"

## Step 3: Load it into the Snowflake table
The upload_app_analytics.py script upload records from the local "download.csv" file into the Snowflake table you created in Step 1


## (Optional) Step 4: Create views over the raw data
The APP_ANALYTICS table is just raw string values, deliberately so that uploads tend to work and any data issues can be dealt with in the views.
APP_USAGE.sql contains a script for a view which casts the columns into appropriate Snowflake data types.
APP_USAGE_MONTHLY_USERS.sql further aggregates this data by showing unique (anonymous) user counts grouped by month.
