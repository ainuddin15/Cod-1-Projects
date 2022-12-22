import socket
import time
import sys

Host = sys.argv[1]
Port = sys.argv[2]
Rcon = sys.argv[3]
command = sys.argv[4]

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.connect((Host, Port))

sock.send("\xFF\xFF\xFF\xFFrcon %s %s"%(Rcon, command))
