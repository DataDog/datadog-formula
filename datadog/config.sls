{% from "datadog/map.jinja" import datadog_config, datadog_install_settings, datadog_checks, latest_agent_version, parsed_version with context %}
{% set config_file_path = '%s/%s'|format(datadog_install_settings.config_folder, datadog_install_settings.config_file) -%}

{%- if not latest_agent_version and parsed_version[1] == '5' %}
datadog_conf_installed:
  file.managed:
    - name: {{ config_file_path }}
    - source: salt://datadog/files/datadog.conf.jinja
    - user: dd-agent
    - group: dd-agent
    - mode: 600
    - template: jinja
    - require:
      - pkg: datadog-pkg
{%- else %}
datadog_yaml_installed:
  file.managed:
    - name: {{ config_file_path }}
    - source: salt://datadog/files/datadog.yaml.jinja
    - user: dd-agent
    - group: dd-agent
    - mode: 600
    - template: jinja
    - require:
      - pkg: datadog-pkg
{%- endif %}

{% if datadog_checks is defined %}
{% for check_name in datadog_checks %}

{%- if latest_agent_version or parsed_version[1] != '5' %}
# Make sure the check directory is present
datadog_{{ check_name }}_folder_installed:
  file.directory:
    - name: {{ datadog_install_settings.confd_path }}/{{ check_name }}.d
    - user: dd-agent
    - group: root
    - mode: 700

# Remove the old config file (if it exists)
datadog_{{ check_name }}_old_yaml_removed:
  file.absent:
    - name: {{ datadog_install_settings.confd_path }}/{{ check_name }}.yaml
{%- endif %}

datadog_{{ check_name }}_yaml_installed:
  file.managed:
    {%- if latest_agent_version or parsed_version[1] != '5' %}
    - name: {{ datadog_install_settings.confd_path }}/{{ check_name }}.d/conf.yaml
    {%- else %}
    - name: {{ datadog_install_settings.confd_path }}/{{ check_name }}.yaml
    {%- endif %}
    - source: salt://datadog/files/conf.yaml.jinja
    - user: dd-agent
    - group: root
    - mode: 600
    - template: jinja
    - context:
        check_name: {{ check_name }}

{%- if latest_agent_version or parsed_version[1] != '5' %}
{%- if datadog_checks[check_name].version is defined %}

{%- if datadog_checks[check_name].third_party is defined and datadog_checks[check_name].third_party | to_bool %}
{% set install_command = "install --third-party" %}
{%- else %}
{% set install_command = "install" %}
{%- endif %}

datadog_check_{{ check_name }}_version_{{ datadog_checks[check_name].version }}_installed:
  cmd.run:
    - name: sudo -u dd-agent datadog-agent integration {{ install_command }} datadog-{{ check_name }}=={{ datadog_checks[check_name].version }}
{%- endif %}
{%- endif %}

{% endfor %}
{% endif %}

{% set install_info_path = '%s/install_info'|format(datadog_install_settings.config_folder) -%}
install_info_installed:
  file.managed:
    - name: {{ install_info_path }}
    - source: salt://datadog/files/install_info.jinja
    - user: dd-agent
    - group: dd-agent
    - mode: 600
    - template: jinja
    - require:
      - pkg: datadog-pkg
