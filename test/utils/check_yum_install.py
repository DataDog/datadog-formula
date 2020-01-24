#!/usr/bin/env python

import yum, sys
from helpers import get_options, check_major_version

def get_yum_package_version(package_name):
  yb = yum.YumBase()
  try:
    # Use next to stop at the first match
    pkg = next(p for p in yb.rpmdb.returnPackages() if p.name == "datadog-agent")
    installed_version = pkg.version
  except StopIteration:
    # datadog-agent is not in the list of installed packages
    installed_version = None
  
  return installed_version

def main(argv):
  expected_major_version = get_options(argv[1:])
  print("Expected major version: {}".format(expected_major_version))

  installed_version = get_yum_package_version("datadog-agent")
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
