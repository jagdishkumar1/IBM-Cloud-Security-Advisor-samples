/*******************************************************************************

* IBM Confidential

* OCO Source Materials

* (C) Copyright IBM Corp  2018 All Rights Reserved.

* The source code for this program is not published or otherwise divested of

* its trade secrets, * irrespective of what has been deposited with

* the U.S. Copyright Office.

******************************************************************************/

const axios = require('axios')
var exports = module.exports = exportedFunction

function exportedFunction(logger) {
    logger = logger || console

    function getHeaders(accessToken) {
        var content_type = "application/json"
        return {
            "Accept": "application/json",
            "Content-Type": content_type,
            "Authorization": 'Bearer ' + accessToken,
            "Replace-If-Exists": true
        }
    }

    async function createFinding(baseEndpoint, accountId, body, accessToken, providerId) {
        let url = baseEndpoint + "/" + accountId + "/providers/" + providerId + "/occurrences";
        let config = {
            headers: getHeaders(accessToken)
        }

        try {
            return await axios.post(url, body, config)
        }
        catch (error) {
            return Promise.reject(error)
        }
    }

    return {
        createFinding: createFinding
    }
}
