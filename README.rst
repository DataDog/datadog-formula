***************
datadog-formula
***************

What this is: a saltstack formula for Datadog.

Available States
================

``datadog``
-----------

Installs and runs the Datadog agent.

This formula uses pillar data to store the Datadog API key for your account (see ``pillar.example``).
