{% from "datadog/map.jinja" import
    datadog_apt_default_keys,
    datadog_apt_trusted_d_keyring,
    datadog_apt_usr_share_keyring,
    datadog_install_settings,
    latest_agent_version,
    parsed_version
  with context %}

{% macro import_apt_key(key_fingerprint, key_url) %}
{# Since we always have to download at least the CURRENT key, but can't tell Saltstack to not
   count it as "changed state", we do this workaround with fetching a URL and setting it
   to a variable, which doesn't show up in state at all. #}
{% set key_response = salt['http.query'](key_url) %}

key-file-{{ key_fingerprint }}-import:
  cmd.run:
    {# we put key inside an env variable here to prevent the whole long key from appearing in the state output #}
    - name: |
        echo "${KEY_FROM_URL}" | gpg --import --batch --no-default-keyring --keyring {{ datadog_apt_usr_share_keyring }}
    - env:
        KEY_FROM_URL: |
          {{ key_response.body| indent(10) }}
    - unless: |
        echo "{{ key_response.body|indent(8) }}" | gpg --dry-run --import --batch --no-default-keyring --keyring {{ datadog_apt_usr_share_keyring }} 2>&1 | grep "unchanged: 1"
{% endmacro %}

{%- if grains['os_family'].lower() == 'debian' %}
datadog-apt-https:
  pkg.installed:
    - name: apt-transport-https

{# Create the keyring unless it exists #}
{{ datadog_apt_usr_share_keyring }}:
  file.managed:
    - contents: ''
    - contents_newline: False
    - mode: 0644
    - unless: ls {{ datadog_apt_usr_share_keyring }}

{% set apt_keys_tmpdir = salt['temp.dir']() %}

{% for key_fingerprint, key_url in datadog_apt_default_keys.items() %}
  {{ import_apt_key(key_fingerprint, key_url) }}
{% endfor %}

{% if (grains['os'].lower() == 'ubuntu' and grains['osrelease'].split('.')[0]|int < 16) or
      (grains['os'].lower() == 'debian' and grains['osrelease'].split('.')[0]|int < 9) %}
{{ datadog_apt_trusted_d_keyring }}:
  file.managed:
    - mode: 0644
    - source: {{ datadog_apt_usr_share_keyring }}
{% endif %}

{% endif %}

{# Some versions of Salt still in use have issue with providing repo options for
   APT sources: https://github.com/saltstack/salt/issues/22412; therefore we use
   file.managed instead of pkgrepo.managed for debian platforms #}

{%- if grains['os_family'].lower() == 'debian' -%}
datadog-repo:
  file.managed:
    {# Determine beta or stable distribution from version #}
    {% if not latest_agent_version and (parsed_version[2] == 'beta' or parsed_version[2] == 'rc') %}
        {% set distribution = 'beta' %}
    {% else %}
        {% set distribution = 'stable' %}
    {% endif %}
    {# Determine which channel we should look in #}
    {% if latest_agent_version or parsed_version[1] == '7' %}
        {% set packages = '7' %}
    {% elif parsed_version[1] == '6' %}
        {% set packages = '6' %}
    {% else %}
        {% set packages = 'main' %}
    {% endif %}
    - contents: deb [signed-by={{ datadog_apt_usr_share_keyring }}] https://apt.datadoghq.com/ {{ distribution }} {{ packages }}
    - mode: 0644
    - name: /etc/apt/sources.list.d/datadog.list
    - require:
      - pkg: datadog-apt-https

datadog-repo-refresh:
  cmd.run:
    - name: apt-get update
    - retry:
        attempts: 2 # TODO: 5
        interval: 1

{%- elif grains['os_family'].lower() == 'redhat' %}

datadog-repo:
  pkgrepo.managed:
    - humanname: "Datadog, Inc."
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
    {%- if latest_agent_version or parsed_version[1] != '5' %}
    - repo_gpgcheck: '1'
    {%- else %}
    - repo_gpgcheck: '0'
    {%- endif %}
    - name: datadog
    - baseurl: https://yum.datadoghq.com/{{ path }}/{{ grains['cpuarch'] }}
    - gpgcheck: '1'
    {%- if latest_agent_version or parsed_version[1] == '7' %}
    - gpgkey: https://keys.datadoghq.com/DATADOG_RPM_KEY_CURRENT.public https://keys.datadoghq.com/DATADOG_RPM_KEY_FD4BF915.public https://keys.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public
    {%- else %}
    - gpgkey: https://keys.datadoghq.com/DATADOG_RPM_KEY_CURRENT.public https://keys.datadoghq.com/DATADOG_RPM_KEY_FD4BF915.public https://keys.datadoghq.com/DATADOG_RPM_KEY_E09422B3.public https://keys.datadoghq.com/DATADOG_RPM_KEY.public
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