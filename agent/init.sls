datadog-repo:
  pkgrepo:
    - managed
    - humanname: "Datadog Agent"
    - name: deb http://apt.datadoghq.com/ unstable main
    - keyserver: keyserver.ubuntu.com
    - keyid: C7A7DA52
    - file: /etc/apt/sources.list.d/datadog.list
 
datadog-pkg:
  pkg.latest:
    - name: datadog-agent
    - require:
      - pkgrepo.managed: datadog-repo
 
datadog-example:
  cmd.run:
    - name: cp /etc/dd-agent/datadog.conf.example /etc/dd-agent/datadog.conf
    # copy just if datadog.conf does not exists yet and the .example exists
    - onlyif: test ! -f /etc/dd-agent/datadog.conf -a -f /etc/dd-agent/datadog.conf.example
    - require:
      - pkg.latest: datadog-pkg
 
datadog-conf:
  file.sed:
    - name: /etc/dd-agent/datadog.conf
    - before: "api_key:.*"
    - after: "api_key: {{ pillar['datadog']['api_agent_key'] }}"
    - watch:
      - pkg.latest: datadog-pkg
    - require:
      - cmd.run: datadog-example
 
datadog-agent-service:
  service:
    - name: datadog-agent
    - running
    - enable: True
    - watch:
      - pkg: datadog-agent
