# -*- coding: utf-8 -*-

include:
  - datadog.config
  - datadog.install
  - datadog.service

{% for check_type in pillar.datadog %}
  {% if check_type == 'config' %}
datadog_conf_installed:
  file.managed:
    - name: /etc/dd-agent/datadog.conf
    - source: salt://datadog/files/datadog.conf.jinja
    - user: dd-agent
    - group: root
    - mode: 600
    - template: jinja
  {% else %}
datadog_{{ check_type }}_yaml_installed:
  file.managed:
    - name: /etc/dd-agent/conf.d/{{ check_type }}.yaml
    - source: salt://datadog/files/check_type.yaml.jinja
    - user: dd-agent
    - group: root
    - mode: 600
    - template: jinja
    - context:
        check_type: {{ check_type }}
  {% endif %}
{% endfor %}
 
datadog-agent-service:
  service:
    - name: datadog-agent
    - running
    - enable: True
    - watch:
      - pkg: datadog-agent
