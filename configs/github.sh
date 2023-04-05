export GITHUB_WATCHED_PRS="$DOT_FILES_DIR/github-watched-prs"
export GITHUB_WATCHED_PRS_URLS="$GITHUB_WATCHED_PRS/urls.list"
export GITHUB_AWK_PROGRAM_FOR_SINGLE_CHECK_VIEW_ORIGINAL='/.*ANNOTATIONS.*/ { exit 0 } { print $0 }'
export GITHUB_AWK_PROGRAM_FOR_SINGLE_CHECK_VIEW='
  function remove_color_codes(arg) {
    return gsub("(.\\[[0-9]+m|.\\(..\\[m)", "", arg)
  }
  
  /.*ANNOTATIONS.*/ {
    exit 0
  }

  {
    if ($0 ~ /^[^ ]/) {
      warn_indicator = BOLD "🟡  " NORMAL
      error_indicator = BOLD "🔴  " NORMAL
    } else {
      warn_indicator = YELLOW BOLD "~~  " NORMAL
      error_indicator = RED BOLD "~~  " NORMAL
    }

    if ($1 ~ /\*/) {
      print warn_indicator $0
    } else if ($1 ~ /X/) {
      print error_indicator $0
    } else {
      print "    " $0
    }
  }
'
