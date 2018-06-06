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
    - name: {{ datadog.pkg }}
    - refresh: True
    - require:
      - pkgrepo: datadog-repo

#
# DD docker-agent
#
#docker run -d --name dd-agent -v /var/run/docker.sock:/var/run/docker.sock:ro -v /proc/:/host/proc/:ro -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro -e DD_API_KEY=2494bbd7f3f567e4142cb25ef9d9f389 datadog/agent:latest
# docker-agent-present:
#   docker_image.present:
#     - image: {{ config.docker.image }}
#     - tag: {{ config.docker.tag }}
#     - force: true  # ensure its always pulled