#!/usr/bin/env python

import subprocess
import yum
import sys
from helpers import get_options, check_major_version, check_install_info


def get_yum_package_version(package_name):
    yb = yum.YumBase()
    try:
        # Use next to stop at the first match
        pkg = next(p for p in yb.rpmdb.returnPackages() if p.name == package_name)
        installed_version = pkg.version
    except StopIteration:
        # datadog-agent is not in the list of installed packages
        installed_version = None

    return installed_version


def is_rpm_package_installed(package_name):
    try:
        subprocess.check_output(["rpm", "-q", package_name])
        return True
    except subprocess.CalledProcessError:
        return False


def main(argv):
    expected_major_version = get_options(argv[1:])
    print("Expected major version: {}".format(expected_major_version))

    installed_version = get_yum_package_version("datadog-agent")
    print("Installed Agent version: {}".format(installed_version))

    assert check_major_version(installed_version, expected_major_version)
    print("Agent version check successful!")

    # expected_major_version
    if expected_major_version:
        assert check_install_info(expected_major_version)
        print("install_info check successful!")
    else:
        print("Skipping install_info check.")

    assert not is_rpm_package_installed("gpg-pubkey-4172a230-55dd14f6")
    print("GPG key 4172a230 is not installed.")

    sys.exit()


if __name__ == "__main__":
    main(sys.argv)
