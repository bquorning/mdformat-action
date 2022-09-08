#!/bin/bash

parse_inputs() {
  file_or_dir=""
  if [ "${INPUT_FILE_OR_DIR}" != "" ]; then
    file_or_dir="${INPUT_FILE_OR_DIR}"
  fi

  number=''
  if [ "${INPUT_NUMBER}" == "1" ] || [ "${INPUT_NUMBER}" == "true" ]; then
    number="--number"
  fi

  wrap=''
  if [ -n "${INPUT_WRAP}" ]; then
    wrap="--wrap ${INPUT_WRAP}"
  fi

  end_of_line=''
  if [ -n "${INPUT_END_OF_LINE}" ]; then
    end_of_line="--end-of-line ${INPUT_END_OF_LINE}"
  fi
}

run_mdformat() {
  echo "lint: info: mdformat on ${file_or_dir}."
  lint_output=$(mdformat --check ${number} ${wrap} ${end_of_line} ${file_or_dir})
  lint_exit_code=${?}

  if [ ${lint_exit_code} -eq 0 ]; then
    echo "### Linting successful! :rocket:" >>$GITHUB_STEP_SUMMARY
    echo "${lint_output}"
    echo
  fi

  if [ ${lint_exit_code} -ne 0 ]; then
    echo "### Linting failed! :astonished:" >>$GITHUB_STEP_SUMMARY
    echo "Please fix the following changes or format with mdformat:" >>$GITHUB_STEP_SUMMARY
    mdformat ${number} ${wrap} ${end_of_line} ${file_or_dir}
    format_diff=$(git diff)
    echo '```diff' >>$GITHUB_STEP_SUMMARY
    echo "${format_diff}" >>$GITHUB_STEP_SUMMARY
    echo '```' >>$GITHUB_STEP_SUMMARY
    echo
  fi

  echo ::set-output name=mdformat_output::"${lint_output}"
  exit ${lint_exit_code}
}

main() {
  parse_inputs
  run_mdformat
}

main "${*}"
