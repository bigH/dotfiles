#!/usr/bin/env bash

export M2_HOME="/opt/homebrew/Cellar/maven/3.8.6"
export M2="$M2_HOME/bin"
export PATH="$M2:$PATH" 

export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"
export JAVA_HOME="$(/usr/libexec/java_home)"

export LANG="en_US.UTF-8"
export LC_COLLATE="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

export SPOTNANA_BACKEND="$HOME/dev/spotnana/spotnana"
