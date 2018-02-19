# -*- coding: utf-8 -*-

{% from "datadog/map.jinja" import datadog with context %}

datadog-example:
  cmd.run:
    - name: cp /etc/dd-agent/datadog.conf.example {{ datadog.config }}
    # copy just if datadog.conf does not exists yet and the .example exists
    - onlyif: test ! -f {{ datadog.config }} -a -f /etc/dd-agent/datadog.conf.example
    - require:
      - pkg: datadog-pkg

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
