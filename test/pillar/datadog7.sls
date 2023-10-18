datadog:
  config:
    api_key: aaaaaaaabbbbbbbbccccccccdddddddd
    site: datadoghq.com
    hostname: test-7

  checks:
    directory:
      config:
        instances:
          - directory: "/srv/pillar"
            name: "pillars"
    # Test installing a third-party integration
    reboot_required:
      config:
        instances:
          - {}
      version: 1.0.0
      third_party: true

  install_settings:
    agent_version: latest
