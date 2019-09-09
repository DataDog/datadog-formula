{% from "datadog/map.jinja" import datadog_install_settings, datadog_checks with context %}
{% set config_file_path = '%s/%s'|format(datadog_install_settings.config_folder, datadog_install_settings.config_file) -%}

datadog-agent-service:
  service.running:
    - name: {{ datadog_install_settings.service_name }}
    - enable: True
    - watch:
      - pkg: {{ datadog_install_settings.pkg_name }}
      - file: {{ config_file_path }}
{%- if datadog_checks | length %}
      - file: {{ datadog_install_settings.checks_confd }}/*
{% endif %}
