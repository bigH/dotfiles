# TODO test
github_checks_clean() {
  local cleaned_checks="$(github_cleaned_checks)"
  echo "$cleaned_checks" > "$GITHUB_WATCHED_CHECKS"
}

# TODO test
github_checks_cleaned() {
  command cat "$GITHUB_WATCHED_CHECKS" |
    xargs -I\{\} -n1 bash -c '
      pr_url="{}"
      test -n "$pr_url" &&
        test "$(gh pr view "$pr_url" --json state --jq .state)" != "OPEN" &&
        echo "$pr_url"
    '
}

# TODO build out
github_checks_watch() {
  original_list="$(command cat "$GITHUB_WATCHED_CHECKS")"

  while true; do
    github_watched_checks_clean

    if diff -q <(echo "$original_list") "$GITHUB_WATCHED_CHECKS"; then
      echo "checks changed:"
      diff <(echo "$original_list") "$GITHUB_WATCHED_CHECKS"
    fi

    while read -r line
    command cat "$GITHUB_WATCHED_CHECKS" |
      xargs -I\{\} -n1 bash -c '
        pr_url="{}"
        checks="$(gh pr checks "$pr_url")"
        echo
      '

    sleep 10
  done
}

# TODO test
github_checks_add() {
  pr_url="${1:-$(gh pr view --json url --jq .url)}"
  if command grep -F "$1" "$GITHUB_WATCHED_CHECKS" > /dev/null; then
    return 0
  fi
  echo "$pr_url" >> "$GITHUB_WATCHED_CHECKS"
}

github_checks_show_for_url() {
  local check_repo="$(echo "$check_url" | sed -E 's:^.*//github\.com/(.*)/actions/runs/([0-9]+)/jobs/[0-9]+$:\1:')"
  local check_number="$(echo "$check_url" | sed -E 's:^.*//github\.com/(.*)/actions/runs/([0-9]+)/jobs/[0-9]+$:\2:')"
  local job_id="$(gh run view --repo "$check_repo" "$check_number" --json jobs --jq '.jobs[0].databaseId')"
  CLICOLOR_FORCE=1 PAGER=cat \
    gh run view --repo "$check_repo" --job "$job_id" |
    awk '/.*ANNOTATIONS.*/ { exit 0 } { print $0 }'
}

github_symbol_for_status() {
  if [ "$1" = 'pass' ]; then
    printf '%s%s%s%s' "$GREEN" "$BOLD" "✔︎" "$NORMAL"
  elif [ "$1" = 'pending' ]; then
    printf '%s%s%s%s' "$YELLOW" "$BOLD" "*" "$NORMAL"
  elif [ "$1" = 'fail' ]; then
    printf '%s%s%s%s' "$RED" "$BOLD" "X" "$NORMAL"
  else
    printf '%s%s%s%s' "$YELLOW" "$BOLD" "?" "$NORMAL"
  fi
}

github_checks_show_for_pr_checks_line() {
  local check_url="$(echo "$1" | awk 'BEGIN { FS="\t" } { print $4 }')"
  local check_status="$(echo "$1" | awk 'BEGIN { FS="\t" } { print $2 }')"
  if [[ "$check_url" = *"//github.com/"* ]]; then
    github_checks_show_for_url "$check_url"
  else
    echo
    echo "$(github_symbol_for_status "$check_status") $check_url ${GRAY}(unknown check type)${NORMAL}"
    echo
  fi

  if [ "$check_status" = 'pass' ] || [ "$check_status" = 'pending' ]; then
    return 0
  else
    return 1
  fi
}

github_checks_show_for_pr() {
  local report_on_fail=0
  local report_on_success=0
  local failed=0

  if [ "$#" -gt 0 ]; then
    # consume first parameter for reporting
    case "$1" in
      --report)
        report_on_fail=1
        report_on_success=1
        shift
        ;;
      --report-f*)
        report_on_fail=1
        shift
        ;;
      --report-p*|--report-s*)
        report_on_success=1
        shift
        ;;
    esac
  fi

  PAGER=cat gh pr checks "$@" --required
  echo
  echo

  while read -r line; do
    if [ -n "$line" ]; then
      github_checks_show_for_pr_checks_line "$line" || failed=1
    fi
  done < <(gh pr checks "$@" --required)

  if [ "$report_on_fail" = 1 ] && [ "$failed" = 1 ]; then
    say --voice "Bad News" "p r checks failed"
  fi

  if [ "$report_on_success" = 1 ] && [ "$failed" = 0 ]; then
    say --voice Bells "p r checks passed"
  fi
}
