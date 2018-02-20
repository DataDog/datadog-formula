# -*- coding: utf-8 -*-

{% from "datadog/map.jinja" import datadog with context %}

datadog-uninstall:
  service.dead:
    - name: {{ datadog.service.name }}
    - enable: False
  pkg.removed:
    - pkgs:
      - {{ datadog.pkg }}
    - require:
      - service: datadog-uninstall
