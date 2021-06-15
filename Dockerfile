FROM alpine:3.11

RUN apk add --no-cache coreutils curl jq gfortran libc-dev cmake make python3 git

WORKDIR /opt/test-runner/testlib
RUN curl -R -O https://raw.githubusercontent.com/pclausen/fortran/main/testlib/CMakeLists.txt
RUN curl -R -O https://raw.githubusercontent.com/pclausen/fortran/main/testlib/TesterMain.f90

WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
