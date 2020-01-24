#!/usr/bin/env python

import apt, re, sys
from helpers import get_options, check_major_version

def get_apt_package_version(package_name):
  cache = apt.cache.Cache()
  cache.update()
  cache.open()

  installed_version = None
  try:
    pkg = cache["datadog-agent"]
    if pkg.is_installed:
      # pkg.installed has the form datadog-agent=1:x.y.z-1, we only want x.y.z
      installed_version = re.match("datadog-agent=[0-9]+:(.*)-[0-9]+", str(pkg.installed)).groups()[0]
  except KeyError:
    # datadog-agent is not installed
    pass

  return installed_version


def main(argv):
  expected_major_version = get_options(argv[1:])
  print("Expected major version: {}".format(expected_major_version))

  installed_version = get_apt_package_version("datadog-agent")
  print("Installed Agent version: {}".format(installed_version))

  result = check_major_version(installed_version, expected_major_version)
  if result:
    print("Agent version check successful!")
    sys.exit()
  else:
    print("Agent version check failed.")
    sys.exit(1)

if __name__ == "__main__":
  main(sys.argv)
