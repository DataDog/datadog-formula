Datadog Formula
===============

SaltStack Formula to install the Datadog Agent and the Agent based integrations,
also called Checks. See the full `Salt Formulas installation and usage instructions <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available States
================

.. contents::
    :local:

``datadog``
-----------

Installs, configures and starts the Datadog Agent service.

``datadog.install``
------------------

Configure the right repo and installs the Agent.

``datadog.config``
------------------

Configures Agent and Integrations using pillar data. See `pillar.example`.

**NOTE:** in order to split a single check type's configuration among multiple
pillar files (eg. to configure different check instances on different machines),
the `pillar_merge_lists` option must be set to `True` in the Salt master config
(or the salt minion config if running masterless) (see
https://docs.saltstack.com/en/latest/ref/configuration/master.html#pillar-merge-lists).

``datadog.service``
------------------

Runs the Datadog Agent service, watching for changes to the config files for the
Agent itself and the checks.

``datadog.uninstall``
------------------

Stops the service and uninstall Datadog Agent.

Development
===========

To ease the development of the formula, you can use Docker and Docker Compose with
the compose file in `test/docker-compose.yaml`.

First build and run a Docker container to create a masterless SaltStack minion. You have the option of choosing either a
Debian- or Redhat-based minion:
```shell
    $ cd test/
    $ TEST_DIST=debian docker-compose run masterless /bin/bash
```

Once you've built the container and have a shell running, you need to apply the SaltStack state on your minion:
```shell
    $ # On your SaltStack minion
    $ salt-call --local state.highstate -l debug
```

Testing
=========

A proper integration test suite is still a Work in Progress, in the meantime you
can use the Docker Compose file provided in the `test` directory to easily check
out the formula in action.

Requirements
------------

* Docker
* Docker Compose

Run the formula
---------------

.. code-block::

    # cd test/
    # TEST_DIST=debian docker-compose up

You should be able to see from the logs if all the states completed successfully.
