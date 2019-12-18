{% from "datadog/map.jinja" import datadog_install_settings with context %}

datadog-uninstall:
  service.dead:
    - name: datadog-agent
    - enable: False
  pkg.removed:
    - pkgs:
      - datadog-agent
    - require:
      - service: datadog-uninstall
