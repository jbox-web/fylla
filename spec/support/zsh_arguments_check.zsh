#!/usr/bin/env zsh
#
# Feed one _arguments optspec to a real zsh completion system and report whether
# comparguments accepts it. A script can be syntactically valid — `zsh -n` says
# nothing — and still be rejected at completion time, which kills completion for
# the whole command.
#
# $1: file holding the optspec, verbatim, as it appears in a generated script.
# Prints the comparguments error on stdout, or nothing when the spec is valid.

zmodload zsh/zpty

local body chunk
local buf=""
integer i=0

body="$(<$1)"

zpty z 'zsh -f'
zpty -w z 'PROMPT=""; RPROMPT=""'
zpty -w z 'autoload -Uz compinit && compinit -u -D'
zpty -w z "_probe_fn() { _arguments $body }"
zpty -w z 'compdef _probe_fn probecmd'
zpty -w z 'print READY'

while (( i < 60 )); do
  if zpty -r -t z chunk 2>/dev/null; then buf+="$chunk"; fi
  [[ $buf == *READY* ]] && break
  sleep 0.05
  (( i++ ))
done

zpty -w -n z 'probecmd -'
zpty -w -n z $'\t'
sleep 1.5

buf=""
i=0
while (( i < 40 )); do
  if zpty -r -t z chunk 2>/dev/null; then buf+="$chunk"; else sleep 0.05; fi
  (( i++ ))
done

zpty -d z

print -r -- "$buf" | tr -d '\r' | grep -o 'invalid option definition.*' | head -1
