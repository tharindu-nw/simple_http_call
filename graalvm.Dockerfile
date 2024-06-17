ARG BALLERINA_VERSION=2201.9.1
FROM ballerina/ballerina:${BALLERINA_VERSION} AS ballerina-tools-build

USER root
COPY . /home/work-dir/simple_http_call
WORKDIR /home/work-dir/simple_http_call

RUN bal push resources/ballerina-http-java17-2.10.14.bala --repository=local

RUN bal build --dump-raw-graphs

FROM ghcr.io/graalvm/native-image-community:17-ol8 as build

WORKDIR /home/work-dir/

COPY --from=ballerina-tools-build /home/work-dir/simple_http_call/target/bin/simple_http_call.jar /home/work-dir/
COPY --from=ballerina-tools-build /home/work-dir/simple_http_call/resources /home/work-dir/resources
RUN native-image -jar simple_http_call.jar --no-fallback -H:Name="simple_http_call" 

FROM debian:stable-slim

WORKDIR /home/ballerina

EXPOSE 6060

COPY --from=ballerina-tools-build /home/work-dir/simple_http_call/resources ./resources
COPY --from=build /home/work-dir/simple_http_call .
USER 10500
CMD ["./simple_http_call", "-Djavax.net.debug=all"]
