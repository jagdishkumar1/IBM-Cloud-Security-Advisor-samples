/*******************************************************************************

* IBM Confidential

* OCO Source Materials

* (C) Copyright IBM Corp  2018 All Rights Reserved.

* The source code for this program is not published or otherwise divested of

* its trade secrets, * irrespective of what has been deposited with

* the U.S. Copyright Office.

******************************************************************************/

"use strict";
const fs = require('fs');
const log4js = require('log4js');
const findingTemplate = require('./utils/findingTemplate').metadata
var logger = log4js.getLogger('postSAFindings');
logger.level = "debug";
var iamapi = require('./utils/iamUtils')(logger)
var findingsApi = require('./utils/findingsAPI')(logger)

async function postFinding() {
    if (process.argv.length < 6) {
        logger.error("Required arguments missing!\n \
            Usage : node src/postFindings.js <audit_file_path> <region> <account_id> <api_key>\n \
            <audit_file_path> Path of the generated npm audit report json file\n \
            <region> Targeted IBM Cloud Security Advisor region (us-south or eu-gb)\n \
            <account_id> IBM Cloud account id\n \
            <api_key> IBM Cloud IAM api key with Manager access to IBM Cloud Security Advisor service\n"
        );
        process.exit(1);
    }
    const auditFile = process.argv[2]
    const region = process.argv[3]
    const accountId = process.argv[4]
    const apiKey = process.argv[5]
    const findingsEndpoint = `https://${region}.secadvisor.cloud.ibm.com/findings/v1`

    var accessToken;

    /** get access token */
    try {
        var response = await iamapi.obtainAccessToken("https://iam.cloud.ibm.com/identity/token", apiKey);
        accessToken = response.access_token
    } catch (err) {
        logger.error(`Error in obtaining access token : ${JSON.stringify(err)}`)
        throw err
    }

    fs.readFile(auditFile, async (err, data) => {
        if (err) {
            logger.error(`Error while reading the audit file ${auditFile}. Reason is ${err}`)
            throw err;
        }
        let auditReport = JSON.parse(data);
        let advisories = auditReport.advisories
        for(var key in advisories) {
            var body = findingTemplate
            body.id = `npm-${key}`
            body.note_name = `${accountId}/providers/npm-provider/notes/npm-finding`
            body.finding.severity = advisories[key].severity.toUpperCase()
            body.context = {
                resource_id: key,
                resource_name: advisories[key].module_name
            }
            body.finding.next_steps= [
                {
                    "title": "Check the npm advisory for the vulnerable package.",
                    "url": advisories[key].url
                },
                {
                    "title": "Update the vulnerable npm lib version or find an alternative for the same."
                }
            ]
            body.short_description = advisories[key].title
            body.long_description = advisories[key].overview

            try {
                response = await findingsApi.createFinding(findingsEndpoint, accountId, JSON.stringify(body), accessToken, "npm-provider");
                logger.info(`Successfully posted finding ${body.id} to Security Advisor.`)
            } catch (err) {
                logger.error(`Error in posting finding ${body.id} to Security Advisor. Reason is ${err.response.data}`)
            }
        }     
    });
}

postFinding()
