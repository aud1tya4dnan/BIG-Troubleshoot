import paramiko
import os
import stat  # ✅ FIX penting
from dotenv import load_dotenv

load_dotenv(override=True)

ip_big1 = os.environ.get('IP_BIG_1')
ip_big2 = os.environ.get('IP_BIG_2')
ip_big3 = os.environ.get('IP_BIG_3')
user_big = os.environ.get('USER')
password_big = os.environ.get('PASS')
location_transfer_big1 = os.environ.get('FILE_LOCATION_BIG1')

hosts = [
    {"ip": ip_big1, "name": "big1", "local_dir": r"D:\TA_script\big1", "has_iperf3": True},
    {"ip": ip_big2, "name": "big2", "local_dir": r"D:\TA_script\big2", "has_iperf3": True},
    {"ip": ip_big3, "name": "big3", "local_dir": r"D:\TA_script\big3", "has_iperf3": False},
]

USERNAME = user_big
PASSWORD = password_big

def download_dir_sftp(hostname, port, username, password, remote_dir, local_dir):
    transport = paramiko.Transport((hostname, port))
    transport.connect(username=username, password=password)
    sftp = paramiko.SFTPClient.from_transport(transport)

    def _recursive_download(remote_path, local_path):
        os.makedirs(local_path, exist_ok=True)
        for item in sftp.listdir_attr(remote_path):
            remote_item = f"{remote_path}/{item.filename}"
            local_item = os.path.join(local_path, item.filename)

            if stat.S_ISDIR(item.st_mode):  # ✅ Perbaikan di sini
                _recursive_download(remote_item, local_item)
            else:
                print(f"📥 Downloading {remote_item} → {local_item}")
                sftp.get(remote_item, local_item)

    _recursive_download(remote_dir, local_dir)
    sftp.close()
    transport.close()

# Jalankan untuk semua host
for host in hosts:
    print(f"\n🔄 Mengambil hasil dari {host['name']} ({host['ip']})...")

    # Download sysbench results
    try:
        sysbench_remote = "/home/sysbench_tests"
        sysbench_local = os.path.join(host["local_dir"], "sysbench_tests")
        download_dir_sftp(
            hostname=host["ip"],
            port=22,
            username=USERNAME,
            password=PASSWORD,
            remote_dir=sysbench_remote,
            local_dir=sysbench_local
        )
        print(f"✅ Sysbench dari {host['name']} tersimpan di {sysbench_local}")
    except Exception as e:
        print(f"❌ Gagal mengunduh sysbench dari {host['name']}: {e}")

    # Download iperf3 results jika tersedia
    if host.get("has_iperf3", False):
        try:
            iperf_remote = "/home/iperf3-results"
            iperf_local = os.path.join(host["local_dir"], "iperf3-results")
            download_dir_sftp(
                hostname=host["ip"],
                port=22,
                username=USERNAME,
                password=PASSWORD,
                remote_dir=iperf_remote,
                local_dir=iperf_local
            )
            print(f"✅ iperf3 dari {host['name']} tersimpan di {iperf_local}")
        except Exception as e:
            print(f"⚠  Gagal mengunduh iperf3 dari {host['name']}: {e}")
    else:
        print(f"⏩ Melewati iperf3 dari {host['name']} (tidak ada folder).")
