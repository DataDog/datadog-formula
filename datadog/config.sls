{% from "datadog/map.jinja" import datadog_config, datadog_install_settings, datadog_checks with context %}
{% set config_file_path = '%s/%s'|format(datadog_install_settings.config_folder, datadog_install_settings.config_file) -%}

datadog_conf_installed:
  file.managed:
    - name: {{ config_file_path }}
    - source: salt://datadog/files/datadog.yaml.jinja
    - user: dd-agent
    - group: dd-agent
    - mode: 600
    - template: jinja
    - require:
      - pkg: datadog-pkg

{% if datadog_checks is defined %}
{% for check_name in datadog_checks %}
datadog_{{ check_name }}_yaml_installed:
  file.managed:
    - name: {{ datadog_install_settings.checks_confd }}/{{ check_name }}.yaml
    - source: salt://datadog/files/conf.yaml.jinja
    - user: dd-agent
    - group: root
    - mode: 600
    - template: jinja
    - context:
        check_name: {{ check_name }}
{% endfor %}
{% endif %}
