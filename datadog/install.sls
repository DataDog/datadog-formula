# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "datadog/map.jinja" import datadog with context %}

datadog-pkg:
  pkgrepo.managed:
    - humanname: "Datadog Agent"
    {% if grains['os'].lower() in ('ubuntu', 'debian') %}
    - name: deb http://apt.datadoghq.com/ stable main
    - keyserver: keyserver.ubuntu.com
    - keyid: C7A7DA52
    - file: /etc/apt/sources.list.d/datadog.list
    {% elif grains['os'].lower() == 'redhat' %}
    - name: Datadog, Inc.
    - baseurl: http://yum.datadoghq.com/rpm/x86_64
    {% endif %}
  pkg.latest:
    - name: {{ datadog.pkg }}
