import ballerina/http;
import ballerina/log;
import ballerina/data.jsondata;

const dogUrl = "https://dog.ceo/api";

final http:Client dogClient = check new (dogUrl, {
    httpVersion: "1.1",
    timeout: 120
});

service / on new http:Listener(6060) {
    resource function get makeHttpCalls() returns json|error? {
        json payload = check dogClient->/breeds/list/all;
        log:printInfo(jsondata:prettify(payload));
        return payload;
    }
}

