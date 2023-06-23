datadog:
  config:
    api_key: aaaaaaaabbbbbbbbccccccccdddddddd
    site: datadoghq.com
    hostname: test-5

  checks:
    directory:
      config:
        instances:
          - directory: "/srv/pillar"
            name: "pillars"

  install_settings:
    {% if grains['os_family'].lower() == 'redhat' %}
    agent_version: 5.32.9
    {% else %}
    agent_version: 5.32.8
    {% endif %}
