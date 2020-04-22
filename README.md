# Datadog Formula

The Datadog SaltStack formula is used to install the Datadog Agent and the Agent based integrations (checks). For more details SaltStack formulas, see the [Salt formulas installation and usage instructions][1].

## Setup

### Requirements

xxx

### Installation

Install the Datadog formula on your Salt master node, using the `gitfs_remotes` option in your Salt master configuration file (defaults to `/etc/salt/master`):

```text
gitfs_remotes:
  - https://github.com/DataDog/datadog-formula.git:
    - ref: 3.0 # Pin the version of the formula you want to use
```

Alternatively, clone the Datadog formula on your Salt master node:

```shell
mkdir -p /srv/formulas && cd /srv/formulas
git clone https://github.com/DataDog/datadog-formula.git
```

Then, add it to the `file_roots` of your Salt master configuration file (defaults to `/etc/salt/master`):

```text
file_roots:
  - /srv/salt/
  - /srv/formulas/datadog-formula/
```

### Deployment

To deploy the Datadog Agent on your hosts:

1. Add the Datadog formula to your top file (defaults to `/srv/salt/top.sls`):

    ```text
    base:
      '*':
        - datadog
    ```

2. Add `datadog.sls` to your pillar directory (defaults to `/srv/pillar/`) with your [Datadog API key][2]:

    ```text
    datadog:
      config:
        api_key: <YOUR_DD_API_KEY>
    ```

3. Add `datadog.sls` to the top pillar file (defaults to `/srv/pillar/top.sls`):

    ```text
    base:
      '*':
        - datadog
    ```

### Integrations

To add an Agent integration to your host, use the checks variable. Below is an example for the [Directory][3] integration:

```text
datadog:
  config:
    api_key: <YOUR_DD_API_KEY>
  checks:
    directory:
      config:
        instances:
          - directory: "/srv/pillar"
            name: "pillars"
```


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
    config:
      api_key: <your_api_key>
      site: datadoghq.eu

``install_settings``
--------------------
The ``install_settings`` option contains the Agent installation configuration options.
It has the following option:

- ``agent_version``: the version of the Agent which will be installed. Default: latest (will install the latest Agent v7 package).

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


[1]: http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html
[2]: https://app.datadoghq.com/account/settings#api
[3]: https://docs.datadoghq.com/integrations/directory/
