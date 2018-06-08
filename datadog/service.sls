{% from "datadog/map.jinja" import datadog_settings with context %}
{% set config_file_path = '%s/%s'|format(datadog_settings.config_folder, datadog_settings.config_file) -%}

datadog-agent-service:
  service:
    - name: {{ datadog_settings.service_name }}
    - running
    - enable: True
    - watch:
      - pkg: {{ datadog_settings.pkg_name }}
      - file: {{ config_file_path }}
{%- if datadog_settings.checks is defined %}
      - file: {{ datadog_settings.checks_confd }}/*
{% endif %}
