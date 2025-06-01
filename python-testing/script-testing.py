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
test_scripts = {
    "io": "/root/BIG-Troubleshoot/SYSBENCH-script/sysbench_io_test.sh",
    "mem": "/root/BIG-Troubleshoot/SYSBENCH-script/sysbench_mem_test.sh",
    "cpu": "/root/BIG-Troubleshoot/SYSBENCH-script/sysbench_cpu_test.sh",
}


def run_test_on_host(host, vm_count, script_path):
    try:
        s = pxssh.pxssh()
        s.login(host["ip"], "root", PASSWORD)
        print(f"[{host['name']}] Connected.")

        s.sendline("cd /root/BIG-Troubleshoot/SYSBENCH-script")  # Pindah ke direktori script
        s.sendline("git pull") # Update script jika ada perubahan

        # s.sendline("rm -rf /home/sysbench_tests/*")  # Bersihkan hasil sebelumnya

        s.sendline(f"bash {script_path}")

        # Tunggu prompt jumlah VM
        s.expect(r"[Mm]asukkan jumlah vm.*:")
        s.sendline(str(vm_count))

        # Tunggu prompt nama instance
        s.expect(r"[Mm]asukkan nama instance.*:")
        s.sendline(host["name"])  # kirim nama miliknya sendiri saja

        s.prompt(timeout=600)
        print(f"[{host['name']}] Output:\n{s.before.decode(errors='ignore')}")
        s.logout()

    except pxssh.ExceptionPxssh as e:
        print(f"[{host['name']}] SSH session failed: {e}")
    except Exception as e:
        print(f"[{host['name']}] Error: {e}")

def main():
    print("=== SYSBENCH TEST RUNNER ===")
    test_type = input("Mau test apa? (io / mem / cpu): ").strip().lower()

    if test_type not in test_scripts:
        print("❌ Jenis test tidak valid.")
        return

    continuous = input("Apakah ingin melakukan continuous benchmark? (y/n): ").strip().lower()
    
    if continuous == 'y':
        # Run benchmarks sequentially with 1, 2, and 3 VMs
        for vm_count in range(1, 4):
            print(f"\n=== Memulai benchmark dengan {vm_count} VM ===")
            selected_hosts = hosts[:vm_count]
            script_path = test_scripts[test_type]

            threads = []
            for host in selected_hosts:
                t = threading.Thread(target=run_test_on_host, args=(host, vm_count, script_path))
                t.start()
                threads.append(t)

            for t in threads:
                t.join()

            print(f"✅ Benchmark dengan {vm_count} VM selesai.")
            
            if vm_count < 3:
                print("\nMenunggu 30 detik sebelum memulai benchmark selanjutnya...")
                time.sleep(30)  # Wait 30 seconds between different VM count tests
        
        print("\n✅ Semua benchmark selesai.")
        
    else:
        # Original single-run logic
        try:
            vm_count = int(input("Mau dijalankan di berapa VM? (1 / 2 / 3): ").strip())
            if vm_count not in [1, 2, 3]:
                raise ValueError
        except ValueError:
            print("❌ Jumlah VM tidak valid.")
            return

        selected_hosts = hosts[:vm_count]
        script_path = test_scripts[test_type]

        threads = []
        for host in selected_hosts:
            t = threading.Thread(target=run_test_on_host, args=(host, vm_count, script_path))
            t.start()
            threads.append(t)

        for t in threads:
            t.join()

        print("✅ Test selesai.")
    
if __name__ == "__main__":
    main()
