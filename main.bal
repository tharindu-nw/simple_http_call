import ballerina/http;
import ballerina/log;

const dogUrl = "https://dog.ceo/api";

final http:Client dogClient = check new (dogUrl, {
    httpVersion: "1.1",
    timeout: 120,
    retryConfig: {
        interval: 3,
        count: 3,
        backOffFactor: 2.0,
        maxWaitInterval: 20
    },
    secureSocket: {
        enable:false
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

        return <http:Ok>{};
    }
}

