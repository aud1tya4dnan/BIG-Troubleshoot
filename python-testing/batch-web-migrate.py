from pexpect import pxssh
import threading
import time
import os
from dotenv import load_dotenv

load_dotenv(override=True)

ip_big1 = os.environ.get('IP_BIG_1')
ip_big2 = os.environ.get('IP_BIG_2')
ip_big3 = os.environ.get('IP_BIG_3')
password_big = os.environ.get('PASS')
# Daftar host
hosts = [
    {"ip": ip_big1, "name": "big1"},
    {"ip": ip_big2, "name": "big2"},
    {"ip": ip_big3, "name": "big3"},
]

PASSWORD = password_big

# Path to your script on the remote machine
remote_script = 'bash website-script.sh'

# SSH options to avoid host key checking (optional, for automation)
ssh_options = '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

for host in hosts:
    print(f"Connecting to {host}...")
    try:
        child = pexpect.spawn(f'ssh {ssh_options} {host} "{remote_script}"', timeout=120)
        child.logfile = None  # Set to sys.stdout if you want to see output
        child.expect(pexpect.EOF)
        print(f"Finished running script on {host}")
    except Exception as e:
        print(f"Error on {host}: {e}")


def main():
    vm_count = 3
    script_path = "/root/BIG-Troubleshoot/website-script.sh"  # Ganti dengan path script yang sesuai
    threads = []
    for host in selected_hosts:
        t = threading.Thread(target=run_test_on_host, args=(host, vm_count, script_path))
        t.start()
        threads.append(t)

    for t in threads:
        t.join()