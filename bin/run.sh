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
compilation_errors_file_name="compilation-errors"
results_file="${output_dir}/results.json"
build_results_file="${build_dir}/results.json"
file=$(echo "${slug}" | tr '-' '_')

# The same compiler options as the track's CMakeLists.txt sets for a Debug
# build with GFortran.
fortran_flags="-g -std=f2008 -W -Wall -Wextra -pedantic -fbacktrace"

# Create the output directory if it doesn't exist
mkdir -p "${output_dir}"

echo "${slug}: testing..."

# Copy the solution to a directory named after the slug, as the track's
# CMake build does.
cp -R "${input_dir}/" "${build_dir}"
rm -rf "${build_results_file}"

cd "${build_dir}"

# Compile the solution and the tests with gfortran directly, and link them with
# the testlib object compiled at image build. This does what the track's
# CMakeLists.txt does, without CMake's configure step and make's dependency
# scanning, which took most of each run.
{
    gfortran ${fortran_flags} -I "${testlib_dir}" -c "${build_dir}/${file}.f90" &&
    gfortran ${fortran_flags} -I "${testlib_dir}" -c "${build_dir}/${file}_test.f90" &&
    gfortran -g "${file}.o" "${file}_test.o" "${testlib_dir}/TesterMain.o" -o "${slug}"
} 2> "${compilation_errors_file_name}"
ret=$?

if [ $ret -ne 0 ]; then
    # remove line numbers because they are diffrent in Docker build vs local build
    # also remove quotation marks (’‘ vs '') because they may be different on docker vs local linux
    message=$(cat "${compilation_errors_file_name}" | sed 's/[0-9]*//g' | sed -e 's/["'\''’‘]//g' | tr \\n \; | sed 's/;/\n/g')
    jq -n --arg m "${message}" '{version: 2, status: "error", tests: [], message: $m}' > "${build_results_file}"
else
    # build successful, now run test
    EXERCISM_FORTRAN_JSON=1 "./${slug}"
fi

cp "${build_results_file}"  "${results_file}"

cd -

echo "${slug}: done"
