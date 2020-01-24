#!/bin/bash

# Install & uninstall datadog-agent
salt-call --local state.highstate -l debug

echo "==== Done ===="
sleep infinity
