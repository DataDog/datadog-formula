{% from tpldir ~ "/map.jinja" import datadog_install_settings with context %}

datadog-uninstall:
  service.dead:
    - name: datadog-agent
    - enable: False
  pkg.removed:
    - pkgs:
      - datadog-agent
      - datadog-signing-keys
    - require:
      - service: datadog-uninstall
