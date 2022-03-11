FROM gitpod/workspace-full

# Install custom tools, runtime, etc.
RUN apt-get update && apt-get install -y coreutils curl jq gfortran libc-dev cmake make python3 git

WORKDIR /opt/test-runner/testlib
RUN curl -R -O https://raw.githubusercontent.com/exercism/fortran/main/testlib/CMakeLists.txt
RUN curl -R -O https://raw.githubusercontent.com/exercism/fortran/main/testlib/TesterMain.f90

WORKDIR /opt/test-runner
RUN curl -R -O https://raw.githubusercontent.com/exercism/fortran/main/config/CMakeLists.txt


COPY . .
