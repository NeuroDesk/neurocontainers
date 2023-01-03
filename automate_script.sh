#!/usr/bin/bash
# Avoid duplicates
echo 'HISTCONTROL=ignoredups:erasedups' >> ~/.bashrc 

# After each command, append to the history file and reread it
echo 'PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"' >> ~/.bashrc 

source ~/.bashrc

# Combine history from multiple terminals
HISTFILE=~/.bash_history
set -o history

history | tee bash_history

python3 test.py
