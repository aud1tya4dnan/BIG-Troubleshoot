# Tutorial untuk menyelesaikan masalah centos 7 /dev/root /dev/boot etc tidak terdeteksi

## Langkah-langkah yang bisa dilakukan

Step yang akan dicontohkan menggunakan platform `proxmox`, untuk platform lain bisa menyesuaikan dengan dokumentasi platform masing-masing

### Step 1

Matikan vm terlebih dahulu kemudian jalankan vm lagi

![Start vm](./image/Start%20the%20VM.png)

### Step 2

Saat booting terdapat pilihan yang diberikan waktu hanya sekitar 20-15 detik untuk memilih boot option yang dapat ditampilkan seperti pada gambar

![Select Rescue option](./image/Go%20to%20recovery%20sections%20(must%20move%20fast).png)

Silahkan masuk ke rescue mode agar dapat memperbaiki initframs

### Step 3

Ketika sudah masuk ke rescue mode masukkan credentials yang diberikan oleh BIG

![Cred](./image/login%20using%20big%20credentials.png)

### Step 4

Kemudian ketikkan `dracut --regenerate-all --force` dan enter untuk merekonstruksi `initframs`

![dracut](./image/use%20dracut%20--regenerate-all%20--force.png)

### Step 5

Ketika selesai restart vm menggunakan tombol dari platform atau command linux `shutdown -r now`.

![restart](./image/kemudian%20restart%20vm%20menggunakan%20tombol%20reboot%20maupun%20shutdown%20-r%20now.png)

### Dan centos sudah dapat digunakan dengan normal
