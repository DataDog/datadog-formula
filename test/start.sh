#!/bin/bash

# Start masterless minion
salt-call --local state.highstate -l debug
