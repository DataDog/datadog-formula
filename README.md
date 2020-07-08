# Datadog Formula

The Datadog SaltStack formula is used to install the Datadog Agent and the Agent-based integrations (checks). For more details on SaltStack formulas, see the [Salt formulas installation and usage instructions][1].

## Setup

### Requirements

The Datadog SaltStack formula only supports installs on Debian-based and RedHat-based systems.

### Installation

The following instructions add the Datadog formula to the `base` Salt environment. To add it to another Salt environment, change the `base` references to the name of your Salt environment.

#### Option 1

Install the [Datadog formula][6] in the base environment of your Salt master node, using the `gitfs_remotes` option in your Salt master configuration file (defaults to `/etc/salt/master`):

```text
fileserver_backend:
  - roots # Active by default, necessary to be able to use the local salt files we define in the next steps
  - gitfs # Adds gitfs as a fileserver backend to be able to use gitfs_remotes

gitfs_remotes:
  - https://github.com/DataDog/datadog-formula.git:
    - saltenv:
      - base:
        - ref: 3.0 # Pin the version of the formula you want to use
```

Then restart your Salt Master service to apply the configuration changes:

```shell
systemctl restart salt-master
# OR
service salt-master restart
```

#### Option 2

Alternatively, clone the Datadog formula on your Salt master node:

```shell
mkdir -p /srv/formulas && cd /srv/formulas
git clone https://github.com/DataDog/datadog-formula.git
```

Then, add it to the base environment under `file_roots` of your Salt master configuration file (defaults to `/etc/salt/master`):

```text
file_roots:
  base:
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

2. Create `datadog.sls` in your pillar directory (defaults to `/srv/pillar/`). Add the following and update your [Datadog API key][2]:

    ```
    datadog:
      config:
        api_key: <YOUR_DD_API_KEY>
      install_settings:
        agent_version: <AGENT7_VERSION>
    ```

3. Add `datadog.sls` to the top pillar file (defaults to `/srv/pillar/top.sls`):

    ```text
    base:
      '*':
        - datadog
    ```

### Configuration

The formula configuration must be written in the `datadog` key of the pillar file. It contains three parts: `config`, `install_settings`, and `checks`.

#### Config

Under `config`, add the configuration options to write to the minions' Agent configuration file (`datadog.yaml` for Agent v6 & v7, `datadog.conf` for Agent v5).

Depending on the Agent version installed, different options can be set:

- Agent v6 & v7: all options supported by the Agent's configuration file are supported.
- Agent v5: only the `api_key` option is supported.

The example below sets your Datadog API key and the Datadog site to `datadoghq.eu` (available for Agent v6 & v7).

```text
  datadog:
    config:
      api_key: <YOUR_DD_API_KEY>
      site: datadoghq.eu
```

#### Install settings

Under `install_settings`, configure the Agent installation option:

- `agent_version`: The version of the Agent to install (defaults to the latest Agent v7).

The example below installs Agent v6.14.1:

```text
  datadog:
    install_settings:
      agent_version: 6.14.1
```

#### Checks

To add an Agent integration to your host, use the `checks` variable with the check's name as the key. Each check has two options:

| Option    | Description                                                                                                                                                             |
|-----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `config`  | Add the configuration options to write to the check's configuration file:<br>Agent v6 & v7: `<confd_path>/<check>.d/conf.yaml`<br>Agent v5: `<confd_path>/<check>.yaml` |
| `version` | For Agent v6 & v7, the version of the check to install (defaults to the version bundled with the Agent).                                                                |

Below is an example to use v1.4.0 of the [Directory][3] integration monitoring the `/srv/pillar` directory:

```text
datadog:
  config:
    api_key: <YOUR_DD_API_KEY>
  install_settings:
    agent_version: <AGENT7_VERSION>
  checks:
    directory:
      config:
        instances:
          - directory: "/srv/pillar"
            name: "pillars"
      version: 1.4.0
```

##### Logs

To enable log collection, set `logs_enabled` to `true` in the main configuration:
```text
datadog:
  config:
    logs_enabled: true
```

To send logs to Datadog, use the `logs` key in a check (either an existing check to setup logs for an integration, or a custom check to setup custom log collection). In the following example, we'll use a custom check named `system_logs`.

The contents of the `config:` key of this check will be written to the `/etc/datadog-agent/conf.d/<check_name>.d/conf.yaml` file (in this example: `/etc/datadog-agent/conf.d/system_logs.d/conf.yaml`).

To list the logs you want to collect, fill the `config` section the same way you'd fill the `conf.yaml` file of a custom log collection configuration file (refer to the section on [custom log collection](https://docs.datadoghq.com/agent/logs/?tab=tailfiles#custom-log-collection) in the official docs).

For instance, to collect logs from `/var/log/syslog` and `/var/log/auth.log`, the configuration would be:

```text
datadog:
[...]
  checks:
    system_logs:
      config:
        logs:
          - type: file
            path: "/var/log/syslog"
            service: "system"
          - type: file
            path: "/var/log/auth.log"
            service: "system"
```


## States

Salt formulas are pre-written Salt states. The following states are available in the Datadog formula:

| State               | Description                                                                                             |
|---------------------|---------------------------------------------------------------------------------------------------------|
| `datadog`           | Installs, configures, and starts the Datadog Agent service.                                             |
| `datadog.install`   | Configures the correct repo and installs the Datadog Agent.                                             |
| `datadog.config`    | Configures the Datadog Agent and integrations using pillar data (see [pillar.example][4]).              |
| `datadog.service`   | Runs the Datadog Agent service, which watches for changes to the config files for the Agent and checks. |
| `datadog.uninstall` | Stops the service and uninstalls the Datadog Agent.                                                     |

**NOTE**: When using `datadog.config` to configure different check instances on different machines, the `pillar_merge_lists` option must be set to `True` in the Salt master config or the Salt minion config if running masterless. See the [SaltStack documentation][5] for more details.

[1]: http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html
[2]: https://app.datadoghq.com/account/settings#api
[3]: https://docs.datadoghq.com/integrations/directory/
[4]: https://github.com/DataDog/datadog-formula/blob/master/pillar.example
[5]: https://docs.saltstack.com/en/latest/ref/configuration/master.html#pillar-merge-lists
[6]: https://github.com/DataDog/datadog-formula
