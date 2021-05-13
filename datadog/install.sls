{% from "datadog/map.jinja" import datadog_install_settings, latest_agent_version, parsed_version with context %}

{%- if grains['os_family'].lower() == 'debian' %}
datadog-apt-https:
  pkg.installed:
    - name: apt-transport-https

datadog-apt-key:
  cmd.run:
    - name: apt-key adv --recv-keys --keyserver 'keyserver.ubuntu.com' D75CEA17048B9ACBF186794B32637D44F14F620E
    - unless: apt-key list | grep 'D75C EA17 048B 9ACB F186  794B 3263 7D44 F14F 620E' || apt-key list | grep 'D75CEA17048B9ACBF186794B32637D44F14F620E'
{%- endif %}

datadog-repo:
  pkgrepo.managed:
    - humanname: "Datadog, Inc."
    - refresh: False # otherwise this adds 17s to state update!
    - name: deb https://apt.datadoghq.com/ stable 7
    - keyserver: hkp://keyserver.ubuntu.com:80
    - keyid:
        - A2923DFF56EDA6E76E55E492D3A80E30382E94DE
        - D75CEA17048B9ACBF186794B32637D44F14F620E
    - file: /etc/apt/sources.list.d/datadog.list
    - require:
        - pkg: datadog-apt-https
    - require_in:
        - sls: datadog
    - retry:
        - attempts: 5
        - interval: 1

datadog-pkg:
  pkg.installed:
    - name: datadog-agent
    {%- if latest_agent_version %}
    - version: 'latest'
    {%- elif grains['os_family'].lower() == 'debian' %}
    - version: 1:{{ datadog_install_settings.agent_version }}-1
    {%- elif grains['os_family'].lower() == 'redhat' %}
    - version: {{ datadog_install_settings.agent_version }}-1
    {%- endif %}
    - ignore_epoch: True
    - refresh: False
    - require:
      - pkgrepo: datadog-repo
