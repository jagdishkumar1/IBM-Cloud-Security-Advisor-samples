# Intro
IBM Cloud™ Security Advisor is a security dashboard that provides centralized security management. The dashboard unifies vulnerability and network data as well as application and system findings from IBM Services, partners and user-defined sources.
As part of this repo, we are covering end to end scenario of defining a custom source(NPM) and configuring alert for the same.


# Prerequisites
- Install [jq CLI](https://stedolan.github.io/jq/download/)
- IBM Cloud account id and API key 
![IBM Cloud API Key](https://github.com/jagdishkumar1/IBM-Cloud-Security-Advisor-samples/blob/master/images/ibm_cloud.png)

# Steps
1. Clone the repo `git clone git@github.ibm.com:jagdishkumar1/IBM-Cloud-Security-Advisor-samples.git`.
2. Change in to the IBM-Cloud-Security-Advisor-samples directory `cd IBM-Cloud-Security-Advisor-samples`.
3. Create metadata that will be displayed in [IBM Cloud™ Security Advisor dashboard page](https://cloud.ibm.com/security-advisor#/dashboard).
    - `/bin/sh create_metadata.sh <api_key> <region> <account_id>`
        - <api_key> IBM Cloud IAM api key with Manager access to IBM Cloud Security Advisor service
        - <region> Targeted IBM Cloud Security Advisor region (us-south or eu-gb)
        - <account_id> IBM Cloud account id
4. Creating a webhook to be used a notification channel where the alert will be send. [Sample code](https://github.com/ibm-cloud-security/security-advisor-notification-webhook) for creating a webhook for Security Advisor notification service using IBM Cloud Functions.
5. Create notification channel that will be displayed in [IBM Cloud™ Security Advisor alerts page](https://cloud.ibm.com/security-advisor#/notifications).
    - `/bin/sh create_metadata.sh <api_key> <region> <account_id> <channel_url>`
        - <api_key> IBM Cloud IAM api key with Manager access to IBM Cloud Security Advisor service
        - <region> Targeted IBM Cloud Security Advisor region (us-south or eu-gb)
        - <account_id> IBM Cloud account id
        - <channel_url> URL obtained from step 4.
6. Install the node packages `npm install`.
7. Run the npm audit `npm audit --json > audit.json`.
8. Post the findings to Security Advisor based on npm audit result.
    - `node src/postFindings.js <audit_file_path> <region> <account_id> <api_key>`
        - <audit_file_path> Path of the generated npm audit report json file (audit.json) as part of step 7.
        - <region> Targeted IBM Cloud Security Advisor region (us-south or eu-gb)
        - <account_id> IBM Cloud account id
        - <api_key> IBM Cloud IAM api key with Manager access to IBM Cloud Security Advisor service
9. Please verify and see if the card with name 'NPM Audit' has the data populated in [IBM Cloud Security Advisor dashboard](https://cloud.ibm.com/security-advisor#/dashboard) in selected region. Click `View related findings` to get more details.

![IBM Cloud Security Advisor card](https://github.com/jagdishkumar1/IBM-Cloud-Security-Advisor-samples/blob/master/images/card.png)
![IBM Cloud Security Advisor finding](https://github.com/jagdishkumar1/IBM-Cloud-Security-Advisor-samples/blob/master/images/finding.png)

10. Please verify whether you are receiving events in the notification webhook configured as part of step 4.
