import ballerina/http;
import ballerina/log;

const choreoOrgApiUrl = "https://apis.preview-dv.choreo.dev";
const dogUrl = "https://dog.ceo/api";
configurable string jwtToken = ?;

final http:Client choreoOrganizationAPIEndpoint = check new (choreoOrgApiUrl, {
    httpVersion: "1.1",
    timeout: 120,
    retryConfig: {
        interval: 3,
        count: 3,
        backOffFactor: 2.0,
        maxWaitInterval: 20
    }
});

final http:Client dogClient = check new (dogUrl, {
    httpVersion: "1.1",
    timeout: 120,
    retryConfig: {
        interval: 3,
        count: 3,
        backOffFactor: 2.0,
        maxWaitInterval: 20
    }
});

service / on new http:Listener(6060) {
    resource function get makeHttpCalls() returns http:Ok|error? {
        http:Response|error dogsResponse = dogClient->/breed/mountain/bernese/images/random;
        if dogsResponse is error {
            log:printError(string`error connecting to ${dogUrl}`, dogsResponse);
        } else {
            json payload = check dogsResponse.getJsonPayload();
            log:printInfo(payload.toString());
        }

        http:Response|error orgResponse = choreoOrganizationAPIEndpoint->get("/orgs/1.0.0/orgs?include=roles", headers = {
            "Authorization": "Bearer " + jwtToken
        });
        if orgResponse is error {
            log:printError(string`error connecting to ${choreoOrgApiUrl}`, orgResponse);
        } else {
            json payload = check orgResponse.getJsonPayload();
            log:printInfo(payload.toString());
        }

        return <http:Ok>{};
    }
}

