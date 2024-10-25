import ballerina/http;
import ballerina/log;
import ballerina/data.jsondata;
import ballerina/os;

const dogUrl = "https://dog.ceo/api";
configurable string authHeader = "Bearer " + os:getEnv("API_KEY");

final http:Client dogClient = check new (dogUrl, {
    httpVersion: "1.1",
    timeout: 120,
    secureSocket: {
        cert: "resources/dog.ceo.cer"
    }
});

final http:Client pkgClient = check new ("http://package-api-488229713:9090", {
    httpVersion: "1.1",
    timeout: 120
});

listener http:Listener apiListener = new(6060, {
    secureSocket: {
        key: {
            path: "resources/ballerinaKeystore.p12",
            password: os:getEnv("KEYSTORE_PASSWORD")
        }
    }
});

service / on apiListener {
    resource function get makeHttpCalls() returns json|http:Response|error? {
        json payload = check dogClient->/breeds/list/all;
        log:printInfo(jsondata:prettify(payload));
        http:Response|error pkgResponse = pkgClient->/index\-packages\-bulk.post({}, {Authorization: authHeader});
        if pkgResponse is error {
            log:printError("Error occurred while calling the package API: ", pkgResponse);
            return pkgResponse;
        }
        return pkgResponse;
    }
}

