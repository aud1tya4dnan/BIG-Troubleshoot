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

# Mapping test ke path script
# test_scripts = {
#     "io": "/root/BIG-Troubleshoot/SYSBENCH-script/sysbench_io_test.sh",
#     "mem": "/root/BIG-Troubleshoot/SYSBENCH-script/sysbench_mem_test.sh",
#     "cpu": "/root/BIG-Troubleshoot/SYSBENCH-script/sysbench_cpu_test.sh",
# }


def run_test_on_host(host, vm_count, script_path):
    try:
        s = pxssh.pxssh()
        s.login(host["ip"], "root", PASSWORD)
        print(f"[{host['name']}] Connected.")

        s.sendline("rm -rf /home/sysbench_tests/*")  # Bersihkan hasil sebelumnya

        s.prompt(timeout=600)
        print(f"[{host['name']}] Output:\n{s.before.decode(errors='ignore')}")
        s.logout()

    except pxssh.ExceptionPxssh as e:
        print(f"[{host['name']}] SSH session failed: {e}")
    except Exception as e:
        print(f"[{host['name']}] Error: {e}")

def main():
    print("PASTIKAN SEMUA DATA SUDAH DIEXTRACT SEBELUM MENJALANKAN SCRIPT INI!")
    print("KETIKA MENJALANKAN SCRIPT INI SEMUA DATA DALAM /home/sysbench_tests AKAN DIHAPUS!")
    agreement = input("Apakah Anda yakin ingin melanjutkan? (y/n): ").strip().lower()
    # print("=== SYSBENCH TEST RUNNER ===")
    # test_type = input("Mau test apa? (io / mem / cpu): ").strip().lower()

    # if test_type not in test_scripts:
    #     print("❌ Jenis test tidak valid.")
    #     return

    # try:
    #     vm_count = int(input("Mau dijalankan di berapa VM? (1 / 2 / 3): ").strip())
    #     if vm_count not in [1, 2, 3]:
    #         raise ValueError
    # except ValueError:
    #     print("❌ Jumlah VM tidak valid.")
    #     return

    vm_count = 3  # Ganti dengan jumlah VM yang diinginkan
    selected_hosts = hosts[:vm_count]
    # script_path = test_scripts[test_type]
    input_agreement = agreement

    threads = []
    for host in selected_hosts:
        # t = threading.Thread(target=run_test_on_host, args=(host, vm_count, script_path))
        t = threading.Thread(target=run_test_on_host, args=(host, vm_count, input_agreement))
        t.start()
        threads.append(t)

    for t in threads:
        t.join()

    print("✅ Semua delete selesai.")
    
if __name__ == "__main__":
    main()
