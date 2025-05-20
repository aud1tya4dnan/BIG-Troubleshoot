Tahap 1
- Load file OVA kedalam VM terlebih dahulu (OK)

Tahap 2
- Pastikan nama subdomain sudah ready (OK)

Tahap 3
- Login ke server geoportal

Tahap 4
- Pastikan terdapat koneksi internet reply, dengan menjalankan perintah berikut

ping 8.8.8.8

ping gitHub.com

- Jika reply menunjukan terdapat koneksi internet, jika timeout pastikan server konek internet terlebih dahulu

Tahap 5
- upload file migratevm_new_modif.sh , chpass.sh , host ke dalam server path /home

- Jalankan perintah berikut, sebelum eksekusi file sh :

unset http_proxy

unset https_proxy

chmod +rx *.sh

- Eksekusi file dengan menjalankan :

./migratevm_new_modif.sh

- Ikut instruksi selanjutnya

- Masukan nama domain name geoportal tanpa http

### Footnote
Dapat juga menggunakan script yang telah saya buat.
