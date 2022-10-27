import snowflake.connector
import os

# environment variables for Snowflake connection
snowflake_user=os.environ['SNOWFLAKE_USER']
snowflake_password=os.environ['SNOWFLAKE_PASSWORD']
snowflake_role=os.environ['SNOWFLAKE_ROLE']
snowflake_account=os.environ['SNOWFLAKE_ACCOUNT']
snowflake_region_part=os.environ['SNOWFLAKE_REGION_PART']
snowflake_warehouse='COMPUTE_WH'
# set these to the location where the APP_ANALYTICS table was created
snowflake_database='MY_DATABASE'
snowflake_schema='MY_SCHEMA'

# connect to Snowflake
con = snowflake.connector.connect(
    user=snowflake_user,
    password=snowflake_password,
    account=snowflake_account+snowflake_region_part,
    warehouse=snowflake_warehouse,
    database=snowflake_database,
    schema=snowflake_schema
)

# upload the CSV to the table's stage
results = con.cursor().execute("PUT file://download.csv @%APP_ANALYTICS OVERWRITE = TRUE")
for rec in results:
    print('%s' % (rec[0]))

# load the CSV from the table stage into the table
results = con.cursor().execute("COPY INTO APP_ANALYTICS "
    "FILE_FORMAT = ( TYPE = CSV FIELD_OPTIONALLY_ENCLOSED_BY = '\"' SKIP_HEADER = 1)")
for rec in results:
    print('%s' % (rec[0]))
