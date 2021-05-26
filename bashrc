export DOT_FILES_DIR=$HOME/.hiren

source "$DOT_FILES_DIR/auto_sourcer.sh"
auto_source "$DOT_FILES_DIR/profile"
auto_source_initialize

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/home/.sdkman"
[[ -s "/home/home/.sdkman/bin/sdkman-init.sh" ]] && source "/home/home/.sdkman/bin/sdkman-init.sh"
