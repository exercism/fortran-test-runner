FROM alpine:3.11

RUN apk add --no-cache coreutils gfortran libc-dev cmake make python3 git

WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
