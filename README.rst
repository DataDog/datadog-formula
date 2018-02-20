Datadog Formula
===============

SaltStack Formula to install the Datadog Agent. See the full
`Salt Formulas installation and usage instructions <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available States
================

.. contents::
    :local:

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

Testing
=========

A proper integration test suite is still a Work in Progress, in the meantime a
Docker Compose file is provided to easily check out the formula in action.

Requirements
------------

* Docker
* Docker Compose

Run the formula
---------------

.. code-block::

    # cd test/
    # docker-compose up
