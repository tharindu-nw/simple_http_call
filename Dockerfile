ARG BALLERINA_VERSION=2201.8.5
FROM ballerina/ballerina:${BALLERINA_VERSION} AS ballerina-tools-build

USER root
COPY . /home/work-dir/simple_http_call
WORKDIR /home/work-dir/simple_http_call

RUN bal push resources/ballerina-http-java17-2.10.14.bala --repository=local

RUN bal build --dump-raw-graphs

FROM eclipse-temurin:17-jre-alpine

RUN mkdir -p /work-dir \
    && addgroup troupe \
    && adduser -S -s /bin/bash -g 'ballerina' -G troupe -D ballerina \
    && apk upgrade \
    && chown -R ballerina:troupe /work-dir

USER ballerina

WORKDIR /home/work-dir/

COPY --from=ballerina-tools-build /home/work-dir/simple_http_call/target/bin/simple_http_call.jar /home/work-dir/
EXPOSE 6060

ENV JAVA_TOOL_OPTIONS "-XX:+UseContainerSupport -XX:MaxRAMPercentage=80.0 -XX:TieredStopAtLevel=1"
USER 10500
CMD [ "java", "-jar", "simple_http_call.jar", "-Djavax.net.debug=all"]
