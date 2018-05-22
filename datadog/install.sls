# -*- coding: utf-8 -*-

{% from "datadog/map.jinja" import datadog with context %}

{% if grains['os_family'].lower() == 'debian' %}
datadog-apt-https:
  pkg.installed:
    - name: apt-transport-https
{% endif %}

datadog-repo:
  pkgrepo.managed:
    - humanname: "Datadog, Inc."
    {% if grains['os_family'].lower() == 'debian' %}
      {% if datadog['agent_version'] == 5 %}
    - name: deb https://apt.datadoghq.com/ stable main
      {% elif datadog['agent_version'] == 6 %}
    - name: deb https://apt.datadoghq.com/ stable 6
      {% endif %}
    - keyserver: keyserver.ubuntu.com
    - keyid: 382E94DE
    - file: /etc/apt/sources.list.d/datadog.list
    - require:
      - pkg: datadog-apt-https
    {% elif grains['os_family'].lower() == 'redhat' %}
    - name: datadog
      {% if datadog['agent_version'] == 5 %}
    - baseurl: https://yum.datadoghq.com/rpm/{{ grains['cpuarch'] }}
      {% elif datadog['agent_version'] == 6 %}
    - baseurl: https://yum.datadoghq.com/stable/6/{{ grains['cpuarch'] }}
      {% endif %}
    - gpgcheck: '1'
    - gpgkey: https://yum.datadoghq.com/DATADOG_RPM_KEY.public
    - sslverify: '1'
    {% endif %}

datadog-pkg:
  pkg.latest:
    - name: {{ datadog.pkg }}
    - refresh: True
    - require:
      - pkgrepo: datadog-repo
