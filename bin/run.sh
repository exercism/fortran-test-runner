#!/usr/bin/env sh

# Synopsis:
# Run the test runner on a solution.

# Arguments:
# $1: exercise slug
# $2: absolute path to solution folder
# $3: absolute path to output directory

# Output:
# Writes the test results to a results.json file in the passed-in output directory.
# The test results are formatted according to the specifications at https://github.com/exercism/docs/blob/main/building/tooling/test-runners/interface.md

# Example:
# ./bin/run.sh two-fer /absolute/path/to/two-fer/solution/folder/ /absolute/path/to/output/directory/

# If any required arguments is missing, print the usage and exit
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "usage: ./bin/run.sh exercise-slug /absolute/path/to/two-fer/solution/folder/ /absolute/path/to/output/directory/"
    exit 1
fi

slug="$1"
input_dir="${2%/}"
output_dir="${3%/}"
build_dir="/tmp/${slug}"
root_dir=$(realpath $(dirname "$0")/..)
testlib_dir="${root_dir}/testlib"
root_cmakelist_file="${root_dir}/CMakeLists.txt"
compilation_errors_file_name="compilation-errors"
compilation_stdout_file_name="compilation-output"
results_file="${output_dir}/results.json"
build_results_file="${build_dir}/results.json"
binary_file="${build_dir}/${slug}"

# Create the output directory if it doesn't exist
mkdir -p "${output_dir}"

echo "${slug}: testing..."

# Copy the solution to a directory which names matches the slug as
# the makefile uses the directory name to determine the files
cp -R "${input_dir}/" "${build_dir}"

# If testlib or CMakeLists.txt file not available, download
# This should happen in Dockerfile setup but this is usefull for testing
if [ ! -f "${root_cmakelist_file}" ] ; then    
    curl -R -O https://raw.githubusercontent.com/exercism/fortran/main/config/CMakeLists.txt
fi
if [ ! -d "${testlib_dir}" ] ; then
    mkdir "${testlib_dir}"
    cd "${testlib_dir}"
    curl -R -O https://raw.githubusercontent.com/exercism/fortran/main/testlib/CMakeLists.txt
    curl -R -O https://raw.githubusercontent.com/exercism/fortran/main/testlib/TesterMain.f90
    cd -
fi
cp "${root_dir}/CMakeLists.txt" "${build_dir}/CMakeLists.txt"

cd "${build_dir}"

# Copy the testlib which outputs a results.json file when running the tests
cp -R "${testlib_dir}" .

cmake . 1> "${compilation_stdout_file_name}"
cmake --build . 2> "${compilation_errors_file_name}" 1>> "${compilation_stdout_file_name}"
ret=$?

if [ $ret -ne 0 ]; then
    message=$(cat "${compilation_errors_file_name}" | tr \\n \; | sed 's/;/\\\\n/g')
    jq -n --arg m "${message}" '{version: 2, status: "error", tests: [], message: $m}' > "${results_file}"
else
    # build successful, now run test
    export EXERCISM_FORTRAN_JSON=1
    ctest -V
    jq '.' "${build_results_file}" > "${results_file}"
fi

cd -

echo "${slug}: done"
