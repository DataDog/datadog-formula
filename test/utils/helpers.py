#!/usr/bin/env python3

import getopt
import re
import os.path
import os

def get_options(args):
  expected_major_version = None
  try:
    opts, _ = getopt.getopt(args, "hnm:", ["not-installed", "major-version="])
  except getopt.GetoptError:
    print('check_install.py [-n] [-m <major_version>]')
    sys.exit(2)
  for opt, arg in opts:
    if opt == '-h':
        print('check_apt_install.py [-n] [-m <major_version>]')
        sys.exit()
    elif opt in ("-n", "--not-installed"):
        expected_major_version = None
    elif opt in ("-m", "--major-version"):
        expected_major_version = arg

  return expected_major_version

def check_major_version(installed_version, expected_major_version):
  installed_major_version = None

  if installed_version is not None:
    installed_major_version = re.match("([0-9]+).*", installed_version).groups()[0]

  print("Installed Agent major version: {}".format(installed_major_version))
  return installed_major_version == expected_major_version

def get_config_dir(agent_version):
  """Get the agent configuration directory on *nix systems."""
  if int(agent_version) == 5:
    return "/etc/dd-agent"
  else:
    return "/etc/datadog-agent"


def check_install_info(agent_version):
  """Check install_info file."""
  config_dir = get_config_dir(agent_version)
  info_path = os.path.join(config_dir, "install_info")

  if not os.path.isfile(info_path):
    print("install_info file not found at {}".format(info_path))
    return False

  with open(info_path, 'r') as install_info:
    contents = install_info.read()
    for pat in [
      r'^  tool:\s*saltstack$',
      r'^  tool_version:\s*saltstack-([0-9.]+|unknown)$',
      r'^  installer_version:\s*datadog_formula-[0-9](\.[0-9]+)*$'
    ]:
      if not re.search(pat, contents, flags=re.MULTILINE):
        print("Expected match for '{}' in '{}'".format(pat, contents))
        return False

  return True
