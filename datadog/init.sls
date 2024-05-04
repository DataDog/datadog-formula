{%- from 'datadog/map.jinja' import datadog_deprecated %}

include:
  {%- if datadog_deprecated %}
  - datadog.deprecated
  {%- endif %}
  - datadog.install
  - datadog.config
  - datadog.service
