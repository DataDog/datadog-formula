{% from "datadog/map.jinja" import datadog_install_settings, latest_agent_version, parsed_version with context %}

{%- if grains['os_family'].lower() == 'debian' %}
datadog-apt-https:
  pkg.installed:
    - name: apt-transport-https
{%- endif %}

datadog-repo:
  pkgrepo.managed:
    - humanname: "Datadog, Inc."
    {%- if grains['os_family'].lower() == 'debian' -%}
        {#- Determine beta or stable distribution from version #}
        {%- if not latest_agent_version and (parsed_version[2] == 'beta' or parsed_version[2] == 'rc') %}
            {% set distribution = 'beta' %}
        {%- else %}
            {% set distribution = 'stable' %}
        {%- endif %}
        {#- Determine which channel we should look in #}
        {%- if latest_agent_version or parsed_version[1] == '7' %}
            {% set packages = '7' %}
        {%- elif parsed_version[1] == '6' %}
            {% set packages = '6' %}
        {%- else %}
            {% set packages = 'main' %}
        {%- endif %}
    - name: deb https://apt.datadoghq.com/ {{ distribution }} {{ packages }}
    - keyserver: keyserver.ubuntu.com
    - keyid:
      - A2923DFF56EDA6E76E55E492D3A80E30382E94DE
      - D75CEA17048B9ACBF186794B32637D44F14F620E
    - file: /etc/apt/sources.list.d/datadog.list
    - require:
      - pkg: datadog-apt-https
    - retry:
      - attempts: 5
      - interval: 1
    {%- elif grains['os_family'].lower() == 'redhat' %}
        {#- Determine the location of the package we want #}
        {%- if not latest_agent_version and (parsed_version[2] == 'beta' or parsed_version[2] == 'rc') %}
            {%- if parsed_version[1] == '7' %}
                {% set path = 'beta/7' %}
            {%- elif parsed_version[1] == '6' %}
                {% set path = 'beta/6' %}
            {%- else %}
                {% set path = 'beta' %}
            {%- endif %}
        {%- elif latest_agent_version or parsed_version[1] == '7' %}
            {% set path = 'stable/7' %}
        {%- elif parsed_version[1] == '6' %}
            {% set path = 'stable/6' %}
        {%- else %}
            {% set path = 'rpm' %}
        {%- endif %}
    - name: datadog
    - baseurl: https://yum.datadoghq.com/{{ path }}/{{ grains['cpuarch'] }}
    - gpgcheck: '1'
    {%- if latest_agent_version or parsed_version[1] == '7' %}
    - gpgkey: https://yum.datadoghq.com/DATADOG_RPM_KEY_20200908.public https://yum.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public
    {%- else %}
    - gpgkey: https://yum.datadoghq.com/DATADOG_RPM_KEY_20200908.public https://yum.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public https://yum.datadoghq.com/DATADOG_RPM_KEY.public
    {%- endif %}
    - sslverify: '1'
    {% endif %}

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
    - refresh: True
    - require:
      - pkgrepo: datadog-repo