#!/bin/bash
# Downloads Salesforce app analytics data within a date range, saves it locally as download.csv.
# Defaults to yesterday's data.
# Requirements:
# - sfdx CLI installed and configured, assumes an org aliased "devhub" but you can change that below
# - Common command line tools: jq, curl

START_TIME=$(date "+%Y-%m-%dT00:00:00" -d "2 days ago")
END_TIME=$(date "+%Y-%m-%dT00:00:00" -d "yesterday")
#START_TIME="2020-04-01T00:00:00"
REQUEST_PARAMS="StartTime=$START_TIME EndTime=$END_TIME DataType=PackageUsageLog"
sfdx force:data:record:create -u devhub -s AppAnalyticsQueryRequest -v "$REQUEST_PARAMS" --json > out.json
EXECUTION_SUCCESS=`cat out.json | jq -r .result.success`
if [[ "$EXECUTION_SUCCESS" != "true" ]]
then
    echo "Creation of AppAnalyticsQueryRequest was not successful"
    cat out.json
    exit 1
fi
JOB_ID=`cat out.json | jq -r .result.id`

attempts="0"
i="0"
while [ $attempts -lt 200 ]
do
    echo "Checking job status, attempt $attempts"
    attempts=$[$attempts+1]
    sfdx force:data:soql:query -u devhub -q "Select Id, DownloadUrl, RequestState, ErrorMessage from AppAnalyticsQueryRequest where ID='$JOB_ID'" --json > out.json
    JOB_STATUS=`cat out.json | jq -r .result.records[0].RequestState`
    if [ "$JOB_STATUS" == "Complete" ]; then
        echo "Job complete"
        break
    fi
    sleep 10
done
if [ $attempts -eq 200 ]; then
    cat out.json
    echo "Job did not complete in time"
    exit 1
fi
DOWNLOAD_URL=`cat out.json | jq -r .result.records[0].DownloadUrl`
curl $DOWNLOAD_URL -o download.csv
head download.csv
