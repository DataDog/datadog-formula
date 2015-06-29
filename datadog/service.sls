# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "datadog/map.jinja" import datadog with context %}

datadog-agent-service:
  service.running:
    - name: {{ datadog.service.name }}
    - enable: True
