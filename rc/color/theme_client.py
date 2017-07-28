import socket
import sys
import re

so = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
so.connect(('127.0.0.1',7890))

so.send(';'.join(sys.argv[1:]).encode('utf8'))
response = so.recv(4096)
response = response.decode('utf8')

def format_ncol(s, ncol=80):
    s = s.replace('\n',' ')
    return s
    return '\n '.join(re.findall('.{78,88} ',s))

# if sys.argv[1:] == ['l']:
#     response = format_ncol(response)
print(response)

