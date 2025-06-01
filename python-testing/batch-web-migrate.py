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
test_scripts = "/root/BIG-Troubleshoot/website-script.sh"


def run_test_on_host(host, vm_count, script_path):
    try:
        s = pxssh.pxssh()
        s.login(host["ip"], "root", PASSWORD)
        print(f"[{host['name']}] Connected.")

        s.sendline("cd /root/BIG-Troubleshoot")  # Pindah ke direktori script
        s.sendline("git pull") # Update script jika ada perubahan

        s.sendline(f"bash {script_path}")

        # Tunggu prompt jumlah VM
        s.expect(r"IP publik mesin ini*:")
        s.sendline(host["ip"])

        # Tunggu prompt nama instance
        s.expect(r"Nama domain mesin ini*:")
        s.sendline(host["ip"])  # kirim nama miliknya sendiri saja

        # Kirim tombol enter untuk melanjutkan
        s.sendline("")  # Kirim enter

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
    print("=== SYSBENCH TEST RUNNER ===")
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
    script_path = test_scripts

    selected_hosts = hosts[:vm_count]
    script_path = test_scripts

    threads = []
    for host in selected_hosts:
        t = threading.Thread(target=run_test_on_host, args=(host, vm_count, script_path))
        t.start()
        threads.append(t)

    for t in threads:
        t.join()

    print("✅ Semua test selesai.")
    
if __name__ == "__main__":
    main()
