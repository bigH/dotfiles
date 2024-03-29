prs_clean() {
  local cleaned_checks="$(prs_cleaned)"
  echo "$cleaned_checks" > "$GITHUB_WATCHED_PRS_URLS"
}

prs_cleaned() {
  command cat "$GITHUB_WATCHED_PRS_URLS" |
    xargs -I\{\} -n1 bash -c '
      pr_url="{}"
      test -n "$pr_url" &&
        test "$(gh pr view "$pr_url" --json state --jq .state)" == "OPEN" &&
        echo "$pr_url"
    '
}

prs_add() {
  pr_url="${1:-$(gh pr view --json url --jq .url)}"
  if command grep -F "$1" "$GITHUB_WATCHED_PRS_URLS" > /dev/null; then
    return 0
  fi
  echo "$pr_url" >> "$GITHUB_WATCHED_PRS_URLS"
}

prs_scan() {
  log_error NOT IMPLEMENTED
}

__github_display_single_check_without_annotations() {
  local check_url="$1"
  local check_repo="$(echo "$check_url" | sed -E 's:^.*//github\.com/(.*)/actions/runs/([0-9]+)/jobs/[0-9]+$:\1:')"
  local check_number="$(echo "$check_url" | sed -E 's:^.*//github\.com/(.*)/actions/runs/([0-9]+)/jobs/[0-9]+$:\2:')"
  local job_id="$(gh run view --repo "$check_repo" "$check_number" --json jobs --jq '.jobs[0].databaseId')"
  CLICOLOR_FORCE=1 PAGER=cat \
    gh run view --repo "$check_repo" --job "$job_id" |
    awk_with_color_codes "$GITHUB_AWK_PROGRAM_FOR_SINGLE_CHECK_VIEW"
}

__github_status_to_colorized_symbol() {
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

__github_display_all_pr_checks_details() {
  local check_url="$(echo "$1" | awk 'BEGIN { FS="\t" } { print $4 }')"
  local check_status="$(echo "$1" | awk 'BEGIN { FS="\t" } { print $2 }')"
  if [[ "$check_url" = *"//github.com/"* ]]; then
    __github_display_single_check_without_annotations "$check_url"
  else
    echo
    echo "$(__github_status_to_colorized_symbol "$check_status") $check_url ${GRAY}(unknown check type)${NORMAL}"
    echo
  fi

  if [ "$check_status" = 'pass' ] || [ "$check_status" = 'pending' ]; then
    return 0
  else
    return 1
  fi
}

pr_checks_watch() {
  local command_to_watch=
  if [ "$#" -gt 0 ]; then
    command_to_watch="pr_checks --report-failure $(printf ' %q' "$@")"
  else
    local pr_url
    pr_url="$(gh pr view --json url --jq .url)"
    command_to_watch="pr_checks --report-failure $pr_url"
  fi
  shmon --stop-on-status --interval=60 "$command_to_watch"
}

pr_checks() {
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

  PAGER=cat gh pr checks "$@"
  echo
  echo

  while read -r line; do
    if [ -n "$line" ]; then
      __github_display_all_pr_checks_details "$line" || failed=1
    fi
  done < <(gh pr checks "$@" --required)

  if [ "$report_on_fail" = 1 ] && [ "$failed" = 1 ]; then
    say --voice "Bad News" "p r checks failed"
  fi

  if [ "$report_on_success" = 1 ] && [ "$failed" = 0 ]; then
    say --voice Bells "p r checks passed"
  fi

  return $failed
}

pr_checks_view_logs() {
  vim -u NONE $(pr_checks_logs)
  # TODO maybe better
  # vim -u NONE $(pr_checks_logs | tee >(cat 1>&2))
}

pr_checks_logs() {
  local directory="$HOME/dev/random/check-logs/on-$(date +'%Y.%m.%d-%H.%M.%S')"
  local current_dir="$HOME/dev/random/check-logs/latest"

  mkdir -p "$directory"
  unlink "$current_dir"
  ln -s "$directory" "$current_dir"
  echo "$directory" >&2

  while read -r line; do
    if [ -n "$line" ]; then
      local check_status="$(echo "$line" | awk 'BEGIN { FS="\t" } { print $2 }')"
      if [[ "$check_status" = "fail" ]]; then
        local check_name="$(echo "$line" | awk 'BEGIN { FS="\t" } { print $1 }')"
        local check_file_path="$directory/$(echo "$check_name" | awk '{ gsub(/ /, "-"); print }').log"
        local check_url="$(echo "$line" | awk 'BEGIN { FS="\t" } { print $4 }')"
        local check_repo="$(echo "$check_url" | sed -E 's:^.*//github\.com/(.*)/actions/runs/([0-9]+)/jobs/[0-9]+$:\1:')"
        local check_number="$(echo "$check_url" | sed -E 's:^.*//github\.com/(.*)/actions/runs/([0-9]+)/jobs/[0-9]+$:\2:')"
        local job_id="$(gh run view --repo "$check_repo" "$check_number" --json jobs --jq '.jobs[0].databaseId')"
        echo "$check_file_path"
        gh run view --repo "$check_repo" --job "$job_id" --log > "$check_file_path"
      fi
    fi
  done < <(gh pr checks "$@" --required)
}

