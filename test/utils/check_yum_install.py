#!/usr/bin/env python

import yum, sys
from helpers import get_options, check_major_version, check_install_info

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
  else:
    print("Agent version check failed.")
    sys.exit(1)

  # expected_major_version
  if expected_major_version:
    if check_install_info(expected_major_version):
      print("install_info check successful!")
      sys.exit()
    else:
      print("install_info check failed.")
      sys.exit(1)
  else:
    print("Skipping install_info check.")
    sys.exit()


if __name__ == "__main__":
  main(sys.argv)
