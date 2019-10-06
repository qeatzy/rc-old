import re
import requests
from pprint import pprint as pp, pformat as pf

fn_packages = '/etc/setup/installed.db'

def get_packages(fn_packages):
    with open(fn_packages) as f:
        lines = f.readlines()
    ret = []
    for line in lines:
        m = re.search('^(\S+)\s+(\S+)\s+1\s*$', line)
        if m:
            ret.append(m.group(1))
    return ret

packages = get_packages(fn_packages)
[print(i) for i in packages]
# help(packages)
#  python3 > p.out > q.out
#  python3 | tee p.out > q.out
# print(2**32)

# exe_url = 'https://www.cygwin.com/setup-x86_64.exe'
#
# x = requests.get(exe_url)
