# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "datadog/map.jinja" import datadog with context %}

{# copy just if datadog.conf does not exists yet and the .example exists #}
datadog-example:
  cmd.run:
    - name: cp /etc/dd-agent/datadog.conf.example {{ datadog.config }}
    - onlyif: test ! {{ datadog.config }} -f  -a -f /etc/dd-agent/datadog.conf.example
 
datadog-conf:
  file.replace:
    - name: {{ datadog.config }}
    - pattern: "api_key:(.*)"
    - repl: "api_key: {{ datadog.api_key }}"
    - count: 1
