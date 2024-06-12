ARG BALLERINA_VERSION=2201.8.5
FROM ballerina/ballerina:${BALLERINA_VERSION} AS ballerina-tools-build

USER root
COPY . /home/work-dir/simple_http_call
COPY resources/2.10.14 /root/.ballerina/repositories/central.ballerina.io/bala/ballerina/http/2.10.14
WORKDIR /home/work-dir/simple_http_call

RUN bal build --dump-raw-graphs

FROM ghcr.io/graalvm/native-image-community:17-ol8 as build

WORKDIR /home/work-dir/

COPY --from=ballerina-tools-build /home/work-dir/simple_http_call/target/bin/simple_http_call.jar /home/work-dir/
RUN native-image -jar simple_http_call.jar --no-fallback -H:Name="simple_http_call" 

FROM debian:stable-slim

WORKDIR /home/ballerina

EXPOSE 6060

COPY --from=build /home/work-dir/simple_http_call .
USER 10500
CMD ["./simple_http_call"]