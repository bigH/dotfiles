#!/usr/env/bin bash
# meant to be sourced; the above is simply to get most useful shellcheck linting

# NB: get the absolute path to the directory containing this script
# https://stackoverflow.com/a/246128

script_source="${BASH_SOURCE[0]}"

while [ -h "$script_source" ]; do
  target="$(readlink "$script_source")"
  if [[ $target == /* ]]; then
    script_source="$target"
  else
    script_dir="$( dirname "$script_source" )"
    script_source="$script_dir/$target"
  fi
done

__command_exists() {
    [ -n "$1" ] && type "$1" >/dev/null 2>&1
}

if __command_exists bat; then
    export SUPER_CTRL_P_PREVIEW_DEFAULT_FOR_FILE=bat
else
    export SUPER_CTRL_P_PREVIEW_DEFAULT_FOR_FILE=cat
fi

if __command_exists eza; then
    export SUPER_CTRL_P_PREVIEW_DEFAULT_FOR_DIRECTORY=eza
else
    export SUPER_CTRL_P_PREVIEW_DEFAULT_FOR_DIRECTORY=ls
fi

if __command_exists delta; then
    export SUPER_CTRL_P_PAGER_DEFAULT_FOR_DIFFS=delta
else
    export SUPER_CTRL_P_PAGER_DEFAULT_FOR_DIFFS=cat -
fi

export SUPER_CTRL_P_STARTING_SEARCH_STYLE=files
export SUPER_CTRL_P_STARTING_PREVIEW_STATE=contents

__calculate_search_states() {
  echo ""
}

__calculate_preview_states() {
  echo ""
}

__emit_default_configs() {
  echo "SEARCH_STATES=$(__calculate_search_states)"
  echo "PREVIEW_STATES=$(__calculate_preview_states)"
  echo "ACTION_CHOICES=$(__calculate_action_choices)"
  echo "SEARCH_STATE=$SUPER_CTRL_P_STARTING_SEARCH_STYLE"
  echo "PREVIEW_STATE=$SUPER_CTRL_P_STARTING_PREVIEW_STATE"
  echo "DEFAULT_ACTION=$SUPER_CTRL_P_DEFAULT_ACTION"
}

super_ctrl_p_file_selector() {
  scp_current_state_file="$(mktemp)"

  __emit_default_configs > "$scp_current_state_file"

  scp_search_style="$SUPER_CTRL_P_DEFAULT_SEARCH_STYLE"
  scp_search_style="$SUPER_CTRL_P_DEFAULT_PREVIEW_STATE"
}

unset -f __command_exists
