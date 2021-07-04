FROM alpine:3.11

RUN apk add --no-cache apt-get install -y coreutils curl jq gfortran libc-dev cmake make python3 git

WORKDIR /opt/test-runner/testlib
RUN curl -R -O https://raw.githubusercontent.com/exercism/fortran/main/testlib/CMakeLists.txt
RUN curl -R -O https://raw.githubusercontent.com/exercism/fortran/main/testlib/TesterMain.f90

WORKDIR /opt/test-runner
RUN curl -R -O https://raw.githubusercontent.com/exercism/fortran/main/config/CMakeLists.txt


COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
