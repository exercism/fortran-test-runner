[![Gitpod Ready-to-Code](https://img.shields.io/badge/Gitpod-ready--to--code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/pclausen/fortran-test-runner)

# Exercism Fortran Test Runner

Docker image used for automatic testing of the Fortran track's exercises.

This test runner, much like the ones for other tracks, **must** respect the [specified interface][test-runner-interface].

Since the test runners are deployed as Docker images the [related specification][test-runner-docker] **must** be respected for the Dockerfile.

# Running tests

To run tests:

1. Open project's root in terminal
2. Run `./test.sh`

This will compile and run tests for all exercises in the `tests` folder, it will fail if the output file `result.json` is different from the expected one for the exercise.

If you want to run specific tests:

1. Open project's root in terminal
2. Run `./test.sh <EXERCISE_SLUG_1> <EXERCISE_SLUG_2>`

In both cases you can show more informations, like Docker output, by using the flag `-v` or `--verbose`.

# How it works

On the Fortran track we use CMake for building the exercises.

[test-runner-interface]: https://github.com/exercism/automated-tests/blob/master/docs/interface.md
[test-runner-docker]: https://github.com/exercism/automated-tests/blob/master/docs/docker.md
[cmake]: https://cmake.org/
[catch-lib]: https://github.com/catchorg/Catch2
[junit]: https://junit.org/junit5/
[junitparser-lib]: https://github.com/gastlygem/junitparser
