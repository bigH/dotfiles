#!/bin/bash

export DOT_FILES_DIR=$HOME/.hiren

source $DOT_FILES_DIR/bash.colors.sh
touch $DOT_FILES_DIR/.env_context

if [ $# -eq 1 ]; then
  echo "$1" > $DOT_FILES_DIR/.env_context
fi

export DOT_FILES_ENV="$(cat $DOT_FILES_DIR/.env_context)"
if [ -z "$DOT_FILES_ENV" ]; then
  export DOT_FILES_ENV_DISPLAY="[${BLUE}${BOLD}DEFAULT${NORMAL}]"
else
  export DOT_FILES_ENV_DISPLAY="[${CYAN}${BOLD}$(echo "$DOT_FILES_ENV" | tr a-z A-Z)${NORMAL}]"
fi

function mk_expected_dir {
  if [ $# -eq 1 ]; then
    if [ ! -d "$1" ]; then
      echo "${GREEN}Creating${NORMAL}: $1 ..."
      mkdir -p $1
    else
      echo "${GREEN}Directory already present${NORMAL}: $1 ..."
    fi
  else
    echo "${BOLD}ERROR${NORMAL}: mk_expected_dir requires 1 arguments"
    exit 1
  fi
}

function mkdir_if_not_exists {
  if [ $# -eq 1 ]; then
    if [ ! -d "$1" ]; then
      echo "${GREEN}Creating${NORMAL}: $1 ..."
      mkdir -p $1
    else
      echo "Directory already present: $1 ..."
      echo "${BOLD}WARN${NORMAL}: Skipping directory creation $1..."
    fi
  else
    echo "${BOLD}ERROR${NORMAL}: mkdir_if_not_exists requires 1 arguments"
    exit 1
  fi
}

function link_if_possible {
  if [ $# -eq 2 ]; then
    if [ -L "$2" ]; then
      echo "Link already present: ?? -> $2 ..."
      echo "${BOLD}WARN${NORMAL}: Skipping linking $1 -> $2..."
    elif [ -e "$2" ]; then
      echo "File/Directory present at $2 ..."
      echo "${BOLD}WARN${NORMAL}: Skipping linking $1 -> $2..."
    else
      echo "${GREEN}Linking${NORMAL}: $1 -> $2..."
      ln -s "$1" "$2"
    fi
  else
    echo "${BOLD}ERROR${NORMAL}: link_if_possible requires 2 arguments"
    exit 1
  fi
}
