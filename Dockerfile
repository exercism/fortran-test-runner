FROM alpine:3.24.3@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a AS build

RUN apk add --no-cache curl

WORKDIR /opt/test-runner
COPY bust_cache .

WORKDIR /opt/test-runner/testlib
RUN curl -R -O https://raw.githubusercontent.com/exercism/fortran/main/testlib/TesterMain.f90

FROM alpine:3.24.3@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a

RUN apk add --no-cache coreutils jq gfortran libc-dev

WORKDIR /opt/test-runner
COPY --from=build /opt/test-runner/ .

COPY . .

# Compile the testlib once, with the options set by the track's CMakeLists.txt,
# so each run only compiles the solution and its tests.
WORKDIR /opt/test-runner/testlib
RUN gfortran -g -std=f2008 -W -Wall -Wextra -pedantic -fbacktrace -c TesterMain.f90
WORKDIR /opt/test-runner

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
