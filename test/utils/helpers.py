#!/usr/bin/env python

import getopt, re

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
