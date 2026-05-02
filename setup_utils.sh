#!/usr/bin/env bash

export DOT_FILES_DIR=$HOME/.hiren

source "$DOT_FILES_DIR/sh_utils.sh"

touch "$DOT_FILES_DIR/env-context"

if [ $# -eq 1 ]; then
  echo "$1" > $DOT_FILES_DIR/env-context
fi

export DOT_FILES_ENV="$(cat "$DOT_FILES_DIR/env-context")"
if [ -z "$DOT_FILES_ENV" ]; then
  export DOT_FILES_ENV_DISPLAY="[${WHITE}context: ${BOLD}default${NORMAL}]"
else
  DOT_FILES_ENV_CAPITALIZED="$(echo "$DOT_FILES_ENV" | tr '[:lower:]' '[:upper:]')"
  export DOT_FILES_ENV_DISPLAY="[${WHITE}context: ${MAGENTA}${BOLD}${DOT_FILES_ENV}${NORMAL}]"
fi

function mk_or_clean_dir {
  if [ $# -eq 1 ]; then
    if [ ! -d "$1" ]; then
      echo "${GREEN}Creating${NORMAL}: $1 ..."
      mkdir -p "$1"
    else
      echo "${GREEN}Cleaning${NORMAL}: $1 ..."
      rm -rf "$1/*"
    fi
  else
    echo "${RED}${BOLD}ERROR${NORMAL}: \`clean_dir\` requires 1 arguments"
    exit 1
  fi
}

function mk_expected_dir {
  if [ $# -eq 1 ]; then
    if [ ! -d "$1" ]; then
      echo "${GREEN}Creating${NORMAL}: $1 ..."
      mkdir -p $1
    else
      echo "${GREEN}Directory already present${NORMAL}: $1 ..."
    fi
  else
    echo "${RED}${BOLD}ERROR${NORMAL}: \`mk_expected_dir\` requires 1 arguments"
    exit 1
  fi
}

function link_if_possible {
  if [ $# -eq 2 ]; then
    if [ -L "$2" ]; then
      printf "%bWARN%b: Skipping linking %s -> %s [%balready linked: ✔%b]\n" \
        "${BOLD}${YELLOW}" "$NORMAL" "$1" "$2" "$GREEN" "$NORMAL"
    elif [ -e "$2" ]; then
      echo "File/Directory present at $2 ..."
      echo "${BOLD}${YELLOW}WARN${NORMAL}: Skipping linking $1 -> $2 ..."
    else
      echo "${GREEN}Linking${NORMAL}: $1 -> $2 ..."
      ln -s "$1" "$2"
    fi
  else
    echo "${RED}${BOLD}ERROR${NORMAL}: \`link_if_possible\` requires 2 arguments"
    exit 1
  fi
}

function shell_command_in_dir {
  if [ $# -ge 2 ]; then
    local dir="$1"
    local quoted_dir

    shift
    printf -v quoted_dir "%q" "$dir"

    printf "( cd %s &&" "$quoted_dir"
    printf " %q" "$@"
    printf " )"
  else
    echo "${RED}${BOLD}ERROR${NORMAL}: \`shell_command_in_dir\` requires at least 2 arguments"
    return 1
  fi
}

function git_pull_ff_only_command {
  if [ $# -eq 1 ]; then
    local repo_dir="$1"
    local quoted_repo_dir

    printf -v quoted_repo_dir "%q" "$repo_dir"

    printf "git -C %s pull --ff-only" "$quoted_repo_dir"
  else
    echo "${RED}${BOLD}ERROR${NORMAL}: \`git_pull_ff_only_command\` requires 1 argument"
    return 1
  fi
}

function git_clone_command {
  if [ $# -eq 3 ]; then
    local repo_url="$1"
    local repo_dir="$2"
    local clone_args="$3"
    local quoted_repo_url quoted_repo_dir

    printf -v quoted_repo_url "%q" "$repo_url"
    printf -v quoted_repo_dir "%q" "$repo_dir"

    if [ -n "$clone_args" ]; then
      printf 'git clone %s %s %s' "$clone_args" "$quoted_repo_url" "$quoted_repo_dir"
    else
      printf 'git clone %s %s' "$quoted_repo_url" "$quoted_repo_dir"
    fi
  else
    echo "${RED}${BOLD}ERROR${NORMAL}: \`git_clone_command\` requires 3 arguments"
    return 1
  fi
}

function normalize_git_remote_url {
  if [ $# -eq 1 ]; then
    local url="${1%/}"
    local host path rest

    url="${url%.git}"

    case "$url" in
      git@*:*)
        rest="${url#git@}"
        host="${rest%%:*}"
        path="${rest#*:}"
        ;;
      ssh://git@*/*)
        rest="${url#ssh://git@}"
        host="${rest%%/*}"
        path="${rest#*/}"
        ;;
      https://*/*)
        rest="${url#https://}"
        host="${rest%%/*}"
        path="${rest#*/}"
        ;;
      http://*/*)
        rest="${url#http://}"
        host="${rest%%/*}"
        path="${rest#*/}"
        ;;
      *)
        printf "%s" "$url"
        return 0
        ;;
    esac

    host="$(printf "%s" "$host" | tr "[:upper:]" "[:lower:]")"
    printf "%s/%s" "$host" "$path"
  else
    echo "${RED}${BOLD}ERROR${NORMAL}: \`normalize_git_remote_url\` requires 1 argument"
    return 1
  fi
}

function verify_existing_git_repo {
  if [ $# -eq 3 ]; then
    local repo_dir="$1"
    local expected_branch="$2"
    local expected_repo_url="$3"
    local repo_root repo_physical_path actual_branch status
    local origin_url normalized_origin normalized_expected

    if ! repo_root="$(git -C "$repo_dir" rev-parse --show-toplevel 2>/dev/null)"; then
      echo "not a git worktree"
      return 1
    fi

    if ! repo_physical_path="$(cd "$repo_dir" && pwd -P)"; then
      echo "cannot resolve repo path"
      return 1
    fi

    if [ "$repo_physical_path" != "$repo_root" ]; then
      echo "not the git worktree root: expected $repo_root"
      return 1
    fi

    actual_branch="$(git -C "$repo_dir" rev-parse --abbrev-ref HEAD 2>/dev/null)"
    if [ "$actual_branch" != "$expected_branch" ]; then
      echo "wrong branch: expected $expected_branch, found $actual_branch"
      return 1
    fi

    status="$(git -C "$repo_dir" status --short 2>/dev/null)"
    if [ -n "$status" ]; then
      echo "worktree is dirty"
      return 1
    fi

    if ! origin_url="$(git -C "$repo_dir" config --get remote.origin.url 2>/dev/null)"; then
      echo "missing remote.origin.url"
      return 1
    fi

    normalized_origin="$(normalize_git_remote_url "$origin_url")"
    normalized_expected="$(normalize_git_remote_url "$expected_repo_url")"
    if [ "$normalized_origin" != "$normalized_expected" ]; then
      echo "origin mismatch: expected $expected_repo_url, found $origin_url"
      return 1
    fi
  else
    echo "${RED}${BOLD}ERROR${NORMAL}: \`verify_existing_git_repo\` requires 3 arguments"
    return 1
  fi
}

function hhighlighter_plugin_setup_command {
  if [ $# -eq 1 ]; then
    local repo_dir="$1"
    local quoted_repo_dir

    printf -v quoted_repo_dir "%q" "$repo_dir"
    printf "( cd %s && if [ -e h.plugin.zsh ] && [ ! -L h.plugin.zsh ]; then echo 'Refusing to replace existing non-symlink h.plugin.zsh' >&2; exit 1; fi && { grep -qxF h.plugin.zsh .git/info/exclude || printf '\\nh.plugin.zsh\\n' >> .git/info/exclude; } && ln -sfn h.sh h.plugin.zsh )" "$quoted_repo_dir"
  else
    echo "${RED}${BOLD}ERROR${NORMAL}: \`hhighlighter_plugin_setup_command\` requires 1 argument"
    return 1
  fi
}

function install_or_update_git_repo {
  if [ $# -ge 4 ] && [ $# -le 5 ]; then
    local repo_name="$1"
    local repo_url="$2"
    local repo_dir="$3"
    local expected_branch="$4"
    local clone_args="${5:-}"
    local verify_error

    if [ -d "$repo_dir" ]; then
      printf "  - %bFound \`%s\` ...%b" "$BLUE" "$repo_name" "$NORMAL"
      if ! verify_error="$(verify_existing_git_repo "$repo_dir" "$expected_branch" "$repo_url")"; then
        print_status_symbol 1 "check"
        printf "\n      %b%s%b\n" "$GRAY" "$verify_error" "$NORMAL"
        exit 1
      fi
      run_and_print_status_symbol "pull" "$(git_pull_ff_only_command "$repo_dir")" || exit 1
    else
      printf "  - %bInstalling \`%s\` ...%b" "$BLUE" "$repo_name" "$NORMAL"
      run_and_print_status_symbol "clone" "$(git_clone_command "$repo_url" "$repo_dir" "$clone_args")" || exit 1
    fi
  else
    echo "${RED}${BOLD}ERROR${NORMAL}: \`install_or_update_git_repo\` requires 4 or 5 arguments"
    return 1
  fi
}
