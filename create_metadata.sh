#!/bin/bash

# *******************************************************************************

# IBM Confidential

# OCO Source Materials

# (C) Copyright IBM Corp  2018 All Rights Reserved.

# The source code for this program is not published or otherwise divested of

# its trade secrets, * irrespective of what has been deposited with

# the U.S. Copyright Office.

# ******************************************************************************

if [ "$#" -lt 3 ] ; then
    echo "Required arguments missing!"
    echo "Usage : ./create_metadata.sh <api_key> <region> <account_id>"
    echo "<api_key> IBM Cloud IAM api key with Manager access to IBM Cloud Security Advisor service"
    echo "<region> Targeted IBM Cloud Security Advisor region (us-south or eu-gb)"
    echo "<account_id> IBM Cloud account id"
    exit 1
fi

api_key=$1
region=$2
account_id=$3
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

card_response=$(curl -s -w "%{http_code}\\n" -o /dev/null -X POST "https://$region.secadvisor.cloud.ibm.com/findings/v1/$account_id/providers/$provider_id/notes" -H 'accept: application/json' -H "Authorization: Bearer $iam_token" -H 'Content-Type: application/json' -d '{
    "kind": "CARD",
    "id": "npm-card",
    "short_description": "NPM audit issues",
    "long_description": "NPM audit issues",
    "reported_by": {
        "id": "npm",
        "title": "NPM Scan"
    },
    "card": {
        "section": "Audit",
        "title": "NPM Audit",
        "subtitle": "NPM",
        "finding_note_names": [
            "'providers/$provider_id/notes/npm-finding'"
        ],
        "elements": [
            {
                "kind": "NUMERIC",
                "text": "Number of NPM issues detected",
                "value_type": {
                    "kind": "FINDING_COUNT",
                    "finding_note_names": [
                        "'providers/$provider_id/notes/npm-finding'"
                    ]
                }
            },
            {
                "kind": "TIME_SERIES",
                "text": "NPM issues detected in the last 5 days",
                "default_interval": "d",
                "default_time_range": "4d",
                "value_types": [{
                    "kind": "FINDING_COUNT",
                    "finding_note_names": [
                        "'providers/$provider_id/notes/npm-finding'"
                    ],
                    "text": "NPM"
                }]
            }
        ]
    }
}')

if [[ $card_response == 200 ]]; then
    echo "\nMetadata card created successfully."
elif [[ $card_response == 409 ]]; then
    echo "\nMetadata card already exists. Continuing.."
else 
   echo "\nMetadata card creation failed."
   exit 1
fi
 
finding_response=$(curl -s -w "%{http_code}\\n" -o /dev/null -X POST "https://$region.secadvisor.cloud.ibm.com/findings/v1/$account_id/providers/$provider_id/notes" -H 'accept: application/json' -H "Authorization: Bearer $iam_token" -H 'Content-Type: application/json' -d '{
    "kind": "FINDING",
    "id": "npm-finding",
    "short_description": "NPM issue detected",
    "long_description": "NPM issue detected in the targeted repo",
    "reported_by": {
        "id": "npm",
        "title": "NPM Scan"
    },
    "finding": {
        "severity": "HIGH",
        "next_steps": [
            {
                "title": "Check the npm advisory for the vulnerable package.",
                "url": "https://www.npmjs.com/advisories"
            },
            {
                "title": "Update the vulnerable npm lib version or find an alternative for the same."
            }
        ]
    }
}')
if [[ $finding_response == 200 ]]; then
    echo "\nMetadata finding created successfully."
elif [[ $finding_response == 409 ]]; then
    echo "\nMetadata finding already exists. Continuing.."
else 
    echo "\nMetadata finding creation failed."
    exit 1
fi

echo "\nPlease verify and see if the card with name 'NPM Audit' exists here https://cloud.ibm.com/security-advisor#/dashboard in $region region.\n"
