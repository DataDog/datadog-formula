{% from "datadog/map.jinja" import datadog_settings with context %}

datadog-uninstall:
  service.dead:
    - name: {{ datadog_settings.service_name }}
    - enable: False
  pkg.removed:
    - pkgs:
      - {{ datadog_settings.pkg_name }}
    - require:
      - service: datadog-uninstall
