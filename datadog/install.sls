{% from "datadog/map.jinja" import datadog_settings with context %}

{%- if grains['os_family'].lower() == 'debian' %}
datadog-apt-https:
  pkg.installed:
    - name: apt-transport-https
{%- endif %}

{# Get the repository we should be looking in #}
{%- if datadog_settings.agent_version == 'latest' %}
    {%- set latest = true %}
{%- else %}
    {%- set latest = false %}
    {%- set parsed_version = datadog_settings.agent_version | regex_match('(([0-9]+)\.[0-9]+\.[0-9]+)(?:~(rc|beta)\.([0-9]+-[0-9]+))?') %}
{%- endif %}

datadog-repo:
  pkgrepo.managed:
    - humanname: "Datadog, Inc."
    {%- if grains['os_family'].lower() == 'debian' -%}
        {%- if not latest and (parsed_version[2] == 'beta' or parsed_version[2] == 'rc') %}
            {% set distribution = 'beta' %}
        {% else %}
            {% set distribution = 'stable' %}
        {%- endif %}

        {%- if latest or parsed_version[1] == '6' %}
            {% set packages = '6' %}
        {%- else %}
            {% set packages = 'main' %}
        {%- endif %}
    - name: deb https://apt.datadoghq.com/ {{ distribution }} {{ packages }}
    - keyserver: keyserver.ubuntu.com
    - keyid: 382E94DE
    - file: /etc/apt/sources.list.d/datadog.list
    - require:
      - pkg: datadog-apt-https
    {%- elif grains['os_family'].lower() == 'redhat' %}
        {%- if not latest and (parsed_version[2] == 'beta' or parsed_version[2] == 'rc') %}
            {% set path = 'beta' %}
        {%- elif latest or parsed_version[1] == '6' %}
            {% set path = 'stable/6' %}
        {%- else %}
            {% set path = 'rpm' %}
        {%- endif %}
    - name: datadog
    - baseurl: https://yum.datadoghq.com/{{ path }}/{{ grains['cpuarch'] }}
    - gpgcheck: '1'
    - gpgkey: https://yum.datadoghq.com/DATADOG_RPM_KEY.public
    - sslverify: '1'
    {% endif %}

datadog-pkg:
  pkg.installed:
    - name: {{ datadog_settings.pkg_name }}
    {%- if latest %}
    - version: 'latest'
    {%- elif grains['os_family'].lower() == 'debian' %}
    - version: 1:{{ datadog_settings.agent_version }}-1
    {%- elif grains['os_family'].lower() == 'redhat' %}
    - version: {{ datadog_settings.agent_version }}-1
    {%- endif %}
    - ignore_epoch: True
    - refresh: True
    - require:
      - pkgrepo: datadog-repo
