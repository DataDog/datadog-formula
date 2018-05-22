# -*- coding: utf-8 -*-

{% from "datadog/map.jinja" import datadog with context %}

{% if datadog['agent_version'] == 5 %}

datadog-example:
  cmd.run:
    - name: cp /etc/dd-agent/datadog.conf.example {{ datadog.config }}
    # copy just if datadog.conf does not exists yet and the .example exists
    - onlyif: test ! -f {{ datadog.config }} -a -f /etc/dd-agent/datadog.conf.example
    - require:
      - pkg: datadog-pkg

{% if datadog.datadog.api_key is defined %}
datadog-conf:
  file.replace:
    - name: {{ datadog.config }}
    - pattern: "api_key:(.*)"
    - repl: "api_key: {{ datadog.api_key }}"
    - count: 1
    - watch:
      - pkg: datadog-pkg
    - require:
      - cmd: datadog-example
{% endif %}
{% elif datadog['agent_version'] == 6 %}
datadog-conf:
  file.managed:
    - name: {{ datadog.config }}
    - source: salt://datadog/files/datadog.yaml.jinja
    - user: dd-agent
    - group: root
    - mode: 600
    - template: jinja
    - watch:
      - pkg: datadog-pkg
{% endif %}

{% for check_name in datadog.checks %}
datadog_{{ check_name }}_yaml_installed:
  file.managed:
    - name: {{ datadog.checks_config }}/{{ check_name }}.yaml
    - source: salt://datadog/files/conf.yaml.jinja
    - user: dd-agent
    - group: root
    - mode: 600
    - template: jinja
    - context:
        check_name: {{ check_name }}
{% endfor %}
