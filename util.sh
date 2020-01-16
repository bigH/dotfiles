#!/bin/bash

export DOT_FILES_DIR=$HOME/.hiren

source $DOT_FILES_DIR/bash.colors.sh
touch $DOT_FILES_DIR/env-context

if [ $# -eq 1 ]; then
  echo "$1" > $DOT_FILES_DIR/env-context
fi

export DOT_FILES_ENV="$(cat "$DOT_FILES_DIR/env-context")"
if [ -z "$DOT_FILES_ENV" ]; then
  export DOT_FILES_ENV_DISPLAY="[${NORMAL}${BOLD}DEFAULT${NORMAL}]"
else
  DOT_FILES_ENV_CAPITALIZED="$(echo "$DOT_FILES_ENV" | tr '[:lower:]' '[:upper:]')"
  export DOT_FILES_ENV_DISPLAY="[${BLUE}${BOLD}${DOT_FILES_ENV_CAPITALIZED}${NORMAL}]"
fi

function print_symbol_for_status {
  PRINT_PREFIX=""
  if [ $# -eq 0 ]; then
    echo ""
    echo "${RED}${BOLD}ERROR${NORMAL}: \`print_symbol_for_status\` requires 1 or 2 parameters, 0 provided"
  elif [ $# -ge 3 ]; then
    echo ""
    echo "${RED}${BOLD}ERROR${NORMAL}: \`print_symbol_for_status\` requires 1 or 2 parameters, $# provided"
  else
    if [ $# -eq 1 ]; then
      COMMAND_TO_EXECUTE="$1"
    elif [ $# -eq 2 ]; then
      PRINT_PREFIX="$1: "
      COMMAND_TO_EXECUTE="$2"
    fi

    bash -c "$COMMAND_TO_EXECUTE" > /dev/null 2>&1
    STATUS="$?"

    if [ $STATUS -eq 0 ]; then
      printf " [${PRINT_PREFIX}${GREEN}${BOLD}\xE2\x9C\x94${NORMAL}]"
    else
      printf " [${RED}${BOLD}${PRINT_PREFIX}\xE2\x9C\x98${NORMAL}]"
    fi
  fi
}

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

function mkdir_if_not_exists {
  if [ $# -eq 1 ]; then
    if [ ! -d "$1" ]; then
      echo "${GREEN}Creating${NORMAL}: $1 ..."
      mkdir -p $1
    else
      echo "${GREEN}Directory already present${NORMAL}: $1 ..."
      echo "${BOLD}${YELLOW}WARN${NORMAL}: Skipping directory creation $1 ..."
    fi
  else
    echo "${RED}${BOLD}ERROR${NORMAL}: \`mkdir_if_not_exists\` requires 1 arguments"
    exit 1
  fi
}

function link_if_possible {
  if [ $# -eq 2 ]; then
    if [ -L "$2" ]; then
      echo "Link already present: ?? -> $2 ..."
      echo "${BOLD}${YELLOW}WARN${NORMAL}: Skipping linking $1 -> $2 ..."
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
