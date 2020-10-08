#!/bin/bash

# *******************************************************************************

# IBM Confidential

# OCO Source Materials

# (C) Copyright IBM Corp  2018 All Rights Reserved.

# The source code for this program is not published or otherwise divested of

# its trade secrets, * irrespective of what has been deposited with

# the U.S. Copyright Office.

# ******************************************************************************

if [ "$#" -lt 4 ] ; then
    echo "Required arguments missing!"
    echo "Usage : ./create_notification_channel.sh <api_key> <region> <account_id> <channel_url>"
    echo "<api_key> IBM Cloud IAM api key with Manager access to IBM Cloud Security Advisor service"
    echo "<region> Targeted IBM Cloud Security Advisor region (us-south or eu-gb)"
    echo "<account_id> IBM Cloud account id"
    echo "<channel_url> URL where the alert will be send"
    exit 1
fi

api_key=$1
region=$2
account_id=$3
channel_url=$4
provider_id="npm-provider"

#get the IAM token using api key
iam_response=$(curl -s -w "\n%{http_code}" -X POST \
  "https://iam.cloud.ibm.com/identity/token" \
  --header "Content-Type: application/x-www-form-urlencoded" \
  --header "Accept: application/json" \
  --data-urlencode "grant_type=urn:ibm:params:oauth:grant-type:apikey" \
  --data-urlencode "apikey=$api_key")

IFS=$'\n'
iam_response=($iam_response)
if [[ ${iam_response[1]} != 200 ]]; then
   echo "\nIAM token fetch failed."
   exit 1
fi
iam_token=$(echo ${iam_response[0]} | jq -r '.access_token')

notification_response=$(curl -s -w "%{http_code}\\n" -o /dev/null -X POST "https://$region.secadvisor.cloud.ibm.com/notifications/v1/$account_id/notifications/channels" -H 'accept: application/json' -H "Authorization: Bearer $iam_token" -H 'Content-Type: application/json' -d '{ 
    "name": "npm-channel", 
    "description": "channel for events related to npm audit issue", 
    "type": "Webhook", 
    "severity": [ "low", "high", "medium", "critical" ], 
    "endpoint": "'$channel_url'", 
    "enabled": true, 
    "alertSource": [ 
           { 
            "provider_name": "npm-provider", 
            "finding_types": [ "npm-finding" ] 
            } 
        ]
    }')

if [[ $notification_response == 200 ]]; then
    echo "\nNotification channel created successfully."
elif [[ $notification_response == 409 ]]; then
    echo "\nNotification channel with same name already exists. Continuing.."
else 
   echo "\nNotification channel create failed."
   exit 1
fi

echo "\nPlease verify and see if channel with name 'npm-channel' exists here https://cloud.ibm.com/security-advisor#/notifications in $region region.\n"
