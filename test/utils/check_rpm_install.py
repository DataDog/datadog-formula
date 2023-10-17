#!/usr/bin/env python

import subprocess
import sys
from helpers import get_options, check_major_version, check_install_info


def is_rpm_package_installed(package_name):
    try:
        subprocess.check_output(["rpm", "-q", package_name])
        return True
    except subprocess.CalledProcessError:
        return False


def get_rpm_package_version(package_name):
    try:
        if not is_rpm_package_installed(package_name):
            return None
        return subprocess.check_output('rpm -qi {} | grep -E "Version[[:space:]]+:" | cut -d: -f2 | xargs'.format(package_name),
                                       shell=True)
    except subprocess.CalledProcessError:
        return None



def main(argv):
    expected_major_version = get_options(argv[1:])
    print("Expected major version: {}".format(expected_major_version))

    installed_version = get_rpm_package_version("datadog-agent")
    print("Installed Agent version: {}".format(installed_version))

    result = check_major_version(installed_version, expected_major_version)
    assert result
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
