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

    /**
     * obtain access token for api key
     * @param {string} iamTokenURL iam token url
     * @param {string} apiKey an api key to get token for
     * @return {string} the access token
     */
    async function obtainAccessToken(iamTokenURL, apiKey) {

        const config = {
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Accept': 'application/json'
            }
        }
        let body = `grant_type=urn%3Aibm%3Aparams%3Aoauth%3Agrant-type%3Aapikey&apikey=${apiKey}&response_type=cloud_iam`;
        try {
            let response = await axios.post(iamTokenURL, body, config)
            return response.data
        }
        catch (error) {
            return Promise.reject({
                code: error.response.status,
                message: error.response.data
            })
        }
    }
   
    return {
        obtainAccessToken: obtainAccessToken
    }
};