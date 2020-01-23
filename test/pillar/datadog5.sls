datadog:
  config:
    api_key: aaaaaaaabbbbbbbbccccccccdddddddd
    site: datadoghq.com

  checks:
    directory:
      config:
        instances:
          - directory: "/srv/pillar"
            name: "pillars"

  install_settings:
    agent_version: 5.32.5
