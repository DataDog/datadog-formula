datadog:
  api_key: aaaaaaaabbbbbbbbccccccccdddddddd
  site: datadoghq.com
  checks:
    directory:
      instances:
        - directory: "/srv/pillar"
          name: "pillars"
