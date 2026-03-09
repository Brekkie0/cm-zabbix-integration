#!/bin/bash
# This script logs into the CM-Test-API and deploys a file into your chosen container via zabbix macros.

set -o pipefail

# Defined by Zabbix Macros.
CM_SERVER_URL="$1"
CM_USERNAME="$2"
CM_PASSWORD="$3"


if [ -z "$CM_SERVER_URL" ] || [ -z "$CM_USERNAME" ] || [ -z "$CM_PASSWORD" ]; then
  echo "Error: You either have the wrong password, username or server url. check and try again."
  exit 1
fi


START_TIME=$(date +%s%N)


TEMP_DIR="/tmp/cm-zabbix=$$"
mkdir -p "$TEMP_DIR"
trap "rm -rf $TEMP_DIR" EXIT


#Keberos auth (ew)
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Acquiring Kerberos ticket..." >&2
printf '%s\n' "$CM_PASSWORD" | kinit $CM_USERNAME
if [[ $? -ne 0 ]]; then
  ERROR_MSG="Failed to acquire Kerberos ticket"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $ERROR_MSG" >&2
  exit 1
fi
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Kerberos ticket acquired" >&2

SUCCESS=0
ERROR_MSG=""
CREATE_TIME=0
UPLOAD_TIME=0
TEST_RECORD_URI=""

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Authenticating..." >&2

AUTH_START=$(date +%s%N)


AUTH_RESPONSE=$(curl -s -I \
  --connect-timeout 10 \
  --max-time 30 \
  --negotiate \
  -u "$CM_USERNAME:" \
  "$CM_SERVER_URL/" 2>&1)

AUTH_CODE=$?
if [[ $AUTH_CODE -ne 0 ]]; then
  ERROR_MSG="Authentication failed (curl error $AUTH_CODE)"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $ERROR_MSG" >&2
  CREATE_TIME=0
else
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] Authentication successful" >&2
  SUCCESS=1
fi

#UPLOAD PART 

TEST_RECORD_URI="$4"
CM_RECORD_NUMBER="$5"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Uploading test file to record $CM_RECORD_NUMBER..." >&2
  
UPLOAD_START=$(date +%s%N)
  
# Create Test File
TEST_FILE="$TEMP_DIR/test.txt"
echo "INSERT TEXT FOR TEST FILE" >>/$TEMP_DIR/test.txt
  
# Upload file to record (HTTP/2)
UPLOAD_RESPONSE=$(curl -s --http1.1 \
  --location "$CM_SERVER_URL" \
  --connect-timeout 5 \
  --max-time 15 \
  --negotiate \
  --header 'Accept: application/json' \
  --header "Cookie: ss-id=YOURCOOKIE; ss-YOURCOOKIE" \
  --form "Files=@$TEMP_DIR/test.txt" \
  --form "RecordContainer=$CM_RECORD_NUMBER" \
  --form 'RecordTitle=Test?' \
  --form 'RecordRecordType=2' 2>&1
)

if echo "$UPLOAD_RESPONSE" | grep -q '"DocumentUpdated":true'; then
 echo "1"
else
  echo "0"
fi