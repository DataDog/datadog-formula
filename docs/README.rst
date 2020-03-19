.. _readme:

Datadog Formula
================

|img_travis| |img_sr|

.. |img_travis| image:: ![Integration](https://github.com/Perceptyx/datadog-formula/workflows/Integration/badge.svg)
   :alt: GitHub Actions Build Status
   :scale: 100%
   :target: https://github.com/Perceptyx/datadog-formula/actions

SaltStack Formula to install the Datadog Agent and the Agent based integrations, also called Checks.

.. contents:: **Table of Contents**

General notes
-------------

See the full `SaltStack Formulas installation and usage instructions
<https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

If you are interested in writing or contributing to formulas, please pay attention to the `Writing Formula Section
<https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#writing-formulas>`_.

If you want to use this formula, please pay attention to the ``FORMULA`` file and/or ``git tag``,
which contains the currently released version. This formula is versioned according to `Semantic Versioning <http://semver.org/>`_.

See `Formula Versioning Section <https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#versioning>`_ for more details.

If you need (non-default) configuration, please pay attention to the ``pillar.example`` file and/or `Special notes`_ section.

Contributing to this repo
-------------------------

**Commit message formatting is significant!!**

Please see `How to contribute <https://github.com/saltstack-formulas/.github/blob/master/CONTRIBUTING.rst>`_ for more details.

Special notes
-------------

None

Available states
----------------

.. contents::
   :local:

``datadog``
^^^^^^^^^^^^

*Meta-state (This is a state that includes other states)*.

This installs the datadog package,
manages the datadog configuration file and then
starts the associated Datadog Agent service.

``datadog.package``
^^^^^^^^^^^^^^^^^^^^

This state will configure repos and install the datadog package only.

``datadog.config``
^^^^^^^^^^^^^^^^^^^

This state will configure the datadog service and has a dependency on ``datadog.install``
via include list.

**NOTE:** in order to split a single check type's configuration among multiple
pillar files (eg. to configure different check instances on different machines),
the `pillar_merge_lists` option must be set to `True` in the Salt master config
(or the salt minion config if running masterless) (see
https://docs.saltstack.com/en/latest/ref/configuration/master.html#pillar-merge-lists).


``datadog.service``
^^^^^^^^^^^^^^^^^^^^

This state will start the datadog service and has a dependency on ``datadog.config``
via include list.

``datadog.uninstall``
^^^^^^^^^^^^^^^^^^

*Meta-state (This is a state that includes other states)*.

this state will undo everything performed in the ``datadog`` meta-state in reverse order, i.e.
stops the service, removes the configuration file and then uninstalls the package.

Pillar configuration
====================

The formula configuration must be written in the ``datadog`` key of the pillar file.

The formula configuration contains three parts: ``config``, ``install_settings``, and ``checks``.

``config``
----------
The ``config`` option contains the configuration options which will be written in the minions' Agent configuration file (``datadog.yaml`` for Agent v6 & v7, ``datadog.conf`` for Agent v5).

Depending on the Agent version installed, different options can be set:

- Agent v6 & v7: all options supported by the Agent's configuration file are supported.
- Agent v5: only the ``api_key`` option is supported.

Example: set the API key, and the site option to ``datadoghq.eu`` (Agent v6 only)
.. code::

  datadog:
    install_settings:
      agent_version: 6.14.1


``checks``
----------
The ``checks`` option contains configuration for the Agent Checks.

To add an Agent Check, add an entry in the ``checks`` option with the check's name as the key.

Each check has two options:

- ``config``: contains the check's configuration, which will be written to the check's configuration file (``<confd_path>/<check>.d/conf.yaml`` for Agent v6/v7, ``<confd_path>/<check>.yaml`` for Agent v5).
- ``version``: the version of the check which will be installed (Agent v6 and v7 only). Default: the version bundled with the agent.

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



Testing
-------

Linux testing is done with ``kitchen-salt``.

Requirements
^^^^^^^^^^^^

* Ruby
* Docker

.. code-block:: bash

   $ gem install bundler
   $ bundle install
   $ bin/kitchen test [platform]

Where ``[platform]`` is the platform name defined in ``kitchen.yml``,
e.g. ``debian-9-2019-2-py3``.

``bin/kitchen converge``
^^^^^^^^^^^^^^^^^^^^^^^^

Creates the docker instance and runs the ``datadog`` main state, ready for testing.

``bin/kitchen verify``
^^^^^^^^^^^^^^^^^^^^^^

Runs the ``inspec`` tests on the actual instance.

``bin/kitchen destroy``
^^^^^^^^^^^^^^^^^^^^^^^

Removes the docker instance.

``bin/kitchen test``
^^^^^^^^^^^^^^^^^^^^

Runs all of the stages above in one go: i.e. ``destroy`` + ``converge`` + ``verify`` + ``destroy``.

``bin/kitchen login``
^^^^^^^^^^^^^^^^^^^^^

Gives you SSH access to the instance for manual testing.

