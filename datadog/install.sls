{% from "datadog/map.jinja" import datadog_settings with context %}

{% if grains['os_family'].lower() == 'debian' %}
datadog-apt-https:
  pkg.installed:
    - name: apt-transport-https
{% endif %}

datadog-repo:
  pkgrepo.managed:
    - humanname: "Datadog, Inc."
    {% if grains['os_family'].lower() == 'debian' %}
    - name: deb https://apt.datadoghq.com/ stable main
    - keyserver: keyserver.ubuntu.com
    - keyid: 382E94DE
    - file: /etc/apt/sources.list.d/datadog.list
    - require:
      - pkg: datadog-apt-https
    {% elif grains['os_family'].lower() == 'redhat' %}
    - name: datadog
    - baseurl: https://yum.datadoghq.com/rpm/{{ grains['cpuarch'] }}
    - gpgcheck: '1'
    - gpgkey: https://yum.datadoghq.com/DATADOG_RPM_KEY.public
    - sslverify: '1'
    {% endif %}

datadog-pkg:
  pkg.latest:
    - name: {{ datadog_settings.pkg_name }}
    - refresh: True
    - require:
      - pkgrepo: datadog-repo
