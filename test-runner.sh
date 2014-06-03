#! /usr/bin/env bash
#
# test-runner.sh 0.2.0 - easily run generic self-executable test files.
# https://github.com/jimeh/test-runner.sh
#
# (The MIT License)
#
# Copyright (c) 2014 Jim Myhrberg.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
#


#
# Configuration.
#

if [ -z "$TEST_RUNNER_DIR" ]; then
  TEST_DIR="test"
fi

if [ -z "$TEST_RUNNER_PATTERN" ]; then
  TEST_RUNNER_PATTERN=".test.sh"
fi


#
# Helper functions.
#

resolve_link() {
  $(type -p greadlink readlink | head -1) $1
}

abs_dirname() {
  local cwd="$(pwd)"
  local path="$1"

  while [ -n "$path" ]; do
    cd "${path%/*}"
    local name="${path##*/}"
    path="$(resolve_link "$name" || true)"
  done

  pwd
  cd "$cwd"
}


#
# Argument parsing.
#

testfiles=()
testargs=""

if [ $# -gt 0 ]; then
  capture_args=0
  for arg in $@; do
    if [ "$arg" == "--" ]; then
      capture_args=1
    elif [ "$capture_args" == "0" ]; then
      testfiles+=("$arg")
    elif [ "$capture_args" == "1" ]; then
      if [ -n "$testargs" ]; then testargs+=" "; fi
      testargs+="$arg"
    fi
  done
fi


#
# Internal setup.
#

testdir="$(abs_dirname "$0")/${TEST_DIR}"

if [ -z "$testfiles" ]; then
  testfiles="$(find "$testdir" -name "*${TEST_RUNNER_PATTERN}")"
fi


#
# Run tests.
#

success_count=0
fail_count=0
failed_files=()

cwd="$(pwd)"
for testfile in ${testfiles[@]}; do
  testfile_relative="${testfile/#$(dirname "$testdir")\//}"

  echo ""
  echo -en "$(tput setaf 5)running: "
  echo -e "$(tput setaf 6)${testfile_relative}$(tput sgr0)"
  cd "$(dirname "$testfile")"
  "./$(basename "$testfile")" ${testargs[@]}
  if [ "$?" == "0" ]; then
    ((success_count++))
  else
    ((fail_count++))
    failed_files+=("$testfile_relative")
  fi
  cd "$cwd"
done
echo ""


#
# Print summary and exit.
#

if [ -n "$failed_files" ]; then
  echo "$(tput setaf 1)Failed test files:$(tput sgr0)"
  for file in ${failed_files[@]}; do
    echo "$(tput setaf 1) - ${file}$(tput sgr0)"
  done
  echo ""
fi

if [ "$fail_count" == "0" ]; then
  echo -n "$(tput setaf 2)PASSED:$(tput sgr0) "
else
  echo -n "$(tput setaf 1)FAILED:$(tput sgr0) "
fi

if [ "$fail_count" != "0" ]; then
  if [ "$fail_count" != "1" ]; then fail_plurar="s"; fi
  echo -n "$(tput setaf 1)${fail_count} test file${fail_plurar}" \
       "failed.$(tput sgr0) "
fi

if [ "$success_count" != "1" ]; then success_plurar="s"; fi
echo "$(tput setaf 2)${success_count} test file${success_plurar}" \
     "passed.$(tput sgr0)"
exit $fail_count
