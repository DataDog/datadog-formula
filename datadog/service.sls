{% from "datadog/map.jinja" import datadog_install_settings, datadog_checks, latest_agent_version, parsed_version with context %}
{% set config_file_path = '%s/%s'|format(datadog_install_settings.config_folder, datadog_install_settings.config_file) -%}

datadog-agent-service:
  service.running:
    - name: datadog-agent
    - enable: True
    - init_delay: 5
    - watch:
      - pkg: datadog-agent
      - file: {{ config_file_path }}
{%- if datadog_checks | length %}
      - file: {{ datadog_install_settings.confd_path }}/*
{% endif %}
{%- if latest_agent_version or parsed_version[1] != '5' %}
{%- if datadog_checks is defined %}
{%- for check_name in datadog_checks %}
{%- if datadog_checks[check_name].version is defined %}
      - cmd: datadog_check_{{ check_name }}_version_{{ datadog_checks[check_name].version }}_installed
{% endif %}
{% endfor %}
{% endif %}
{% endif %}
