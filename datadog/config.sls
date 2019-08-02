{% from "datadog/map.jinja" import datadog_settings with context %}
{% set config_file_path = '%s/%s'|format(datadog_settings.config_folder, datadog_settings.config_file) -%}
{% set example_file_path = '%s.example'|format(config_file_path) -%}

datadog-example:
  file.copy:
    - name: {{ config_file_path }}
    - source: {{ example_file_path }}
    # file.copy will not overwrite a named file, so we only need to check if the example config file exists
    - onlyif: test -f {{ example_file_path }}
    - require:
      - pkg: datadog-pkg

{% if datadog_settings.api_key is defined %}
datadog-conf:
  file.replace:
    - name: {{ config_file_path }}
    - pattern: "api_key:(.*)"
    - repl: "api_key: {{ datadog_settings.api_key }}"
    - count: 1
    - onlyif: test -f {{ config_file_path }}
    - watch:
      - pkg: datadog-pkg
{% endif %}

{% if datadog_settings.site is defined %}
datadog-conf:
  file.replace:
    - name: {{ config_file_path }}
    - pattern: "(.*)site:(.*)"
    - repl: "site: {{ datadog_settings.site }}"
    - count: 1
    - onlyif: test -f {{ config_file_path }}
    - watch:
      - pkg: datadog-pkg
{% endif %}

{% if datadog_settings.checks is defined %}
{% for check_name in datadog_settings.checks %}
datadog_{{ check_name }}_yaml_installed:
  file.managed:
    - name: {{ datadog_settings.checks_confd }}/{{ check_name }}.yaml
    - source: salt://datadog/files/conf.yaml.jinja
    - user: dd-agent
    - group: root
    - mode: 600
    - template: jinja
    - context:
        check_name: {{ check_name }}
{% endfor %}
{% endif %}
