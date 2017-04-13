***************
datadog-formula
***************

What this is: a saltstack formula for Datadog.

Available States
================

``datadog``
-----------

Installs, configures, and runs the Datadog agent.

This formula uses the Salt pillar to configure Datadog checks. Since both
Salt and Datadog use YAML for configuration, it's simple to essentially copy
pillar data directly into Datadog check configuration files. Use the same
syntax specified in any <check>.yaml.example. Your current configs can be 
copied verbatim into the Salt pillar (see ``pillar.example``).
