FROM gitpod/workspace-full

# Install custom tools, runtime, etc.
RUN sudo apt-get update && sudo apt-get install -y gfortran && sudo apt-get clean && sudo rm -rf /var/cache/apt/* && sudo rm -rf /var/lib/apt/lists/* && sudo rm -rf /tmp/*

WORKDIR /workspace/fortran-test-runner/testlib
RUN curl -R -O https://raw.githubusercontent.com/exercism/fortran/main/testlib/CMakeLists.txt
RUN curl -R -O https://raw.githubusercontent.com/exercism/fortran/main/testlib/TesterMain.f90

WORKDIR /workspace/fortran-test-runner
RUN curl -R -O https://raw.githubusercontent.com/exercism/fortran/main/config/CMakeLists.txt
