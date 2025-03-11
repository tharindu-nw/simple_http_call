import ballerina/http;
import ballerina/log;
import ballerina/lang.value;
import ballerina/os;
import ballerinax/redis;

const dogUrl = "https://dog.ceo/api";
configurable string authHeader = "Bearer " + os:getEnv("API_KEY");
configurable string redisHost = "redis-99131fcf-9c25-444d-b667-32595703bbb0-redissv2014260135-ch.e.aivencloud.com:22930";
configurable string redisPassword = os:getEnv("REDIS_PASSWORD");

redis:ConnectionConfig redisConfig = {
    host: redisHost,
    password: redisPassword,
    options: {
        connectionPooling: true,
        isClusterConnection: false,
        ssl: false,
        startTls: false,
        verifyPeer: false,
        connectionTimeout: 5000
    }
};

public final redis:Client conn = check new (redisConfig);

json depResult = {
    "version": "1.7.1",
    "dependencyGraph": [
        {
            "version": "1.6.0",
            "dependencies": [
                {
                    "org": "ballerina",
                    "name": "jballerina.java",
                    "version": "0.0.0"
                },
                {
                    "org": "ballerina",
                    "name": "io",
                    "version": "1.4.1"
                }
            ],
            "org": "ballerina",
            "name": "os"
        },
        {
            "version": "1.7.1",
            "dependencies": [
                {
                    "org": "ballerina",
                    "name": "os",
                    "version": "1.6.0"
                },
                {
                    "org": "ballerina",
                    "name": "time",
                    "version": "2.2.4"
                },
                {
                    "org": "ballerina",
                    "name": "jballerina.java",
                    "version": "0.0.0"
                },
                {
                    "org": "ballerina",
                    "name": "io",
                    "version": "1.4.1"
                }
            ],
            "org": "ballerina",
            "name": "file"
        },
        {
            "version": "2.2.4",
            "dependencies": [
                {
                    "org": "ballerina",
                    "name": "jballerina.java",
                    "version": "0.0.0"
                }
            ],
            "org": "ballerina",
            "name": "time"
        },
        {
            "version": "0.0.0",
            "dependencies": [
                {
                    "org": "ballerina",
                    "name": "jballerina.java",
                    "version": "0.0.0"
                }
            ],
            "org": "ballerina",
            "name": "lang.value"
        },
        {
            "version": "0.0.0",
            "dependencies": [],
            "org": "ballerina",
            "name": "jballerina.java"
        },
        {
            "version": "1.4.1",
            "dependencies": [
                {
                    "org": "ballerina",
                    "name": "lang.value",
                    "version": "0.0.0"
                },
                {
                    "org": "ballerina",
                    "name": "jballerina.java",
                    "version": "0.0.0"
                }
            ],
            "org": "ballerina",
            "name": "io"
        }
    ],
    "org": "ballerina",
    "name": "file",
    "isDeprecated": false,
    "deprecateMessage": ""
};

listener http:Listener apiListener = new(6060);

service / on apiListener {
    resource function get cacheTest() returns json|error? {
        string cacheKey = "ballerina_file_1.7.1";
        string putResult = check conn->set(cacheKey, depResult.cloneReadOnly().toJsonString());
        log:printDebug("cache key ballerina_file_1.7.1 added to redis: " + putResult);

        string?|error getResult = conn->get(cacheKey);
        if (getResult is error) {
            log:printError("error querying cache key " + cacheKey + " from redis while getting package resolution: "
            + getResult.message());
            return getResult;
        }
        if getResult is string {
            json jsonval = check value:fromJsonString(getResult);
            log:printInfo("cache key " + cacheKey + " found in redis ");
            return jsonval;
        }
        log:printInfo("cache key " + cacheKey + " not found in redis ");
    }
}

