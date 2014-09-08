# test-runner.sh

Simple helper script to easily run tests for shell scripts or other languages.


## Test Files

For your test files to compatible with test-runner.sh they need to adhere to
three rules:

1. Be executable (`chmod +x`), and assume it is being executed from within the
   directory it resides in.
2. Have a file name matching `test/**/*.test.sh` (configurable).
3. Return a non-zero exit status on failure, and a `0` exit status on success.

Test frameworks, helpers, libraries or other things is up to the test writer,
and not something that test-runner.sh cares about.


## Setup

If you've already got a Makefile in your project, you could simply do
something like the following:

```Makefile
test: test-runner.sh
	./test-runner.sh

bootstrap: test-runner.sh
clean: remove_test-runner.sh
update: update_test-runner.sh

test-runner.sh:
	echo "fetching test-runner.sh..." && \
	curl -s -L -o test-runner.sh \
		https://github.com/jimeh/test-runner.sh/raw/master/test-runner.sh && \
	chmod +x test-runner.sh

remove_test-runner.sh:
	( \
		test -f "test-runner.sh" && rm "test-runner.sh" && \
		echo "removed test-runner.sh" \
	) || exit 0

update_test-runner.sh: remove_test-runner.sh test-runner.sh

.SILENT:
.PHONY: test bootstrap clean update \
	remove_test-runner.sh update_test-runner.sh
```

**Note:** To version lock `test-runner.sh` you will want to fetch it from a
specific release tag instead of the master branch.


## Usage

Without any arguments the `test` directory will be recursively searched for
any files who's filename ends in `.test.sh` and executed without any
arguments.

To run specific test files, simply pass them in as arguments:

    ./test-runner.sh test/foo.test.sh test/bar.test.sh

To pass custom arguments to test files, pass `--` followed by your arguments:

    ./test-runner.sh test/foo.test.sh test/bar.test.sh -- --verbose

This will execute `./foo.test.sh --verbose` and `./bar.test.sh --verbose` from
withing the `test` directory.

And to pass custom arguments too all test files:

    ./test-runner.sh -- --verbose


## Configuration

Configuration is done via environment variables:

- `TEST_DIR`: Name of directory to recursively look for test files
  in. (default: `test`)
- `TEST_RUNNER_PATTERN`: Test files' file name must end in specified
  pattern. (default: `.test.sh`)


## Real-World Examples

- [stub.sh](https://github.com/jimeh/stub.sh) - Helpers for bash script
  testing to stub/fake binaries and functions. Includes support for validating
  number of stub calls, and/or if stub has been called with specific
  arguments.


## License

(The MIT license)

Copyright (c) 2014 Jim Myhrberg.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
