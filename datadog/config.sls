{% from "datadog/map.jinja" import datadog_settings, latest_agent_version, parsed_version with context %}
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
datadog-conf-api-key:
  file.replace:
    - name: {{ config_file_path }}
    - pattern: "api_key:(.*)"
    - repl: "api_key: {{ datadog_settings.api_key }}"
    - count: 1
    - onlyif: test -f {{ config_file_path }}
    - watch:
      - pkg: datadog-pkg
{% endif %}

datadog-conf-site:
  file.replace:
    - name: {{ config_file_path }}
    - pattern: "(.*)site:(.*)"
{% if datadog_settings.site is defined %}
    - repl: "site: {{ datadog_settings.site }}"
{% else %}
    - repl: "# site: datadoghq.com"
{% endif %}
    - count: 1
    - onlyif: test -f {{ config_file_path }}
    - watch:
      - pkg: datadog-pkg

datadog-conf-python-version:
  file.replace:
    - name: {{ config_file_path }}
    - pattern: "(.*)python_version:(.*)"
{% if datadog_settings.python_version is defined %}
    - repl: "python_version: {{ datadog_settings.python_version }}"
{% else %}
    - repl: "# python_version: 2"
{% endif %}
    - count: 1
    - onlyif: test -f {{ config_file_path }}
    - watch:
      - pkg: datadog-pkg

{% if datadog_settings.checks is defined %}
{% for check_name in datadog_settings.checks %}

{%- if latest_agent_version or parsed_version[1] != '5' %}
# Make sure the check directory is present
datadog_{{ check_name }}_folder_installed:
  file.directory:
    - name: {{ datadog_settings.checks_confd }}/{{ check_name }}.d
    - user: dd-agent
    - group: root
    - mode: 600

# Remove the old config file (if it exists)
datadog_{{ check_name }}_old_yaml_removed:
  file.absent:
    - name: {{ datadog_settings.checks_confd }}/{{ check_name }}.yaml
{%- endif %}

datadog_{{ check_name }}_yaml_installed:
  file.managed:
    {%- if latest_agent_version or parsed_version[1] != '5' %}
    - name: {{ datadog_settings.checks_confd }}/{{ check_name }}.d/conf.yaml
    {%- else %}
    - name: {{ datadog_settings.checks_confd }}/{{ check_name }}.yaml
    {%- endif %}
    - source: salt://datadog/files/conf.yaml.jinja
    - user: dd-agent
    - group: root
    - mode: 600
    - template: jinja
    - context:
        check_name: {{ check_name }}
{% endfor %}
{% endif %}
