#!/usr/bin/env python3
import platform
import subprocess
import sys

def main():
    # check os type to decide which script to run
    if platform.system().lower() == 'windows':
        # call the powershell script on windows
        # powershell.exe is used to execute the ps1 file
        result = subprocess.run(['powershell.exe', '-File', './sanitize-env-hook.ps1'])
    else:
        # for linux/mac, run the bash script
        result = subprocess.run(['bash', './sanitize-env-hook.sh'])
    # exit with the same return code as the called script
    return result.returncode

if __name__ == '__main__':
    sys.exit(main())
