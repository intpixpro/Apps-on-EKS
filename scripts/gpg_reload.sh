#!/bin/bash

#to reload gpg agent to be able decode secrets

if [ -f "${HOME}/.gpg-agent-info" ]; then
  . "${HOME}/.gpg-agent-info"
  export GPG_AGENT_INFO
fi

GPG_TTY=$(tty)
export GPG_TTY
