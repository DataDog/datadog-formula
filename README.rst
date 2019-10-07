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

Stops the service and uninstalls Datadog Agent.

Pillar configuration
====================

The formula configuration must be written in the `datadog` key of the pillar file.

The formula configuration contains three parts: ``config``, ``install_settings``, and ``checks``.

``config``
----------
The ``config`` option contains the configuration options which will be written in the minions' Agent configuration file (``datadog.yaml`` for Agent 6, ``datadog.conf`` for Agent 5).

Depending on the Agent version installed, different options can be set:

- Agent 6: all options supported by the Agent's configuration file are supported.
- Agent 5: only the ``api_key`` option is supported.

Example: set the API key, and the site option to ``datadoghq.eu`` (Agent v6 only)

.. code::

  datadog:
    config:
      api_key: <your_api_key>
      site: datadoghq.eu

``install_settings``
--------------------
The ``install_settings`` option contains the Agent installation configuration options.
It has the following option:

- ``agent_version``: the version of the Agent which will be installed.

Example: install the Agent version ``6.14.1``

.. code::

  datadog:
    install_settings:
      agent_version: 6.14.1


``checks``
----------
The ``checks`` option contains configuration for the Agent Checks.

To add an Agent Check, add an entry in the ``checks`` option with the check's name as the key.

Each check has two options:

- ``config``: contains the check's configuration, which will be written to the check's configuration file (``<confd_path>/<check>.d/conf.yaml`` for Agent v6, ``<confd_path>/<check>.yaml`` for Agent v5).
- ``version``: the version of the check which will be installed (Agent v6 only).

Example: ``directory`` check version ``1.4.0``, monitoring the ``/srv/pillar`` directory

.. code::

  datadog:
    checks:
      directory:
        config:
          instances:
            - directory: "/srv/pillar"
              name: "pillars"
        version: 1.4.0

Development
===========

To ease the development of the formula, you can use Docker and Docker Compose with
the compose file in `test/docker-compose.yaml`.

First, build and run a Docker container to create a masterless SaltStack minion. You have the option of choosing either
a Debian- or Redhat-based minion. Then, get a shell running in the container.

.. code-block:: shell

    $ cd test/
    $ TEST_DIST=debian docker-compose run masterless /bin/bash

Once you've built the container and have a shell up and running, you need to apply the SaltStack state on your minion:

.. code-block:: shell

    $ # On your SaltStack minion
    $ salt-call --local state.highstate -l debug

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

.. code-block:: shell

    $ cd test/
    $ TEST_DIST=debian docker-compose up

You should be able to see from the logs if all the states completed successfully.
