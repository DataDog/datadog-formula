***************
datadog-formula
***************

What this is: a saltstack formula for Datadog.

Available States
================

``datadog``
-----------

Installs, configures, and runs the Datadog agent.

This formula uses the Salt pillar to configure Datadog and Datadog checks. Since
both Salt and Datadog use YAML for configuration, it's simple to essentially copy
pillar data directly into Datadog check configuration files. Use the same syntax
specified in any <check>.yaml.example. Your current configs can be copied
verbatim into the Salt pillar (see ``pillar.example``).

**NOTE:** In order to split a single check type's configuration among multiple
pillar files (eg. to configure different check instances on different machines),
the `pillar_merge_lists` option must be set to `True` in the Salt master config
(or the salt minion config if running masterless) (see 
https://docs.saltstack.com/en/latest/ref/configuration/master.html#pillar-merge-lists).
