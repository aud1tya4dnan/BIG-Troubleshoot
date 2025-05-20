Repository untuk Centos 7 telah diberhentikan sejak bulan juli tahun 2024 sehingga perlu adanya perbaikan pada source repo (sementara/temporary) agar dapat melakukan yum update dan mendapatkan package dari repository centos lama

### Guna dari file script [fix-centos-repo-big.sh](https://github.com/aud1tya4dnan/BIG-Troubleshoot/blob/main/fix-centos-repo-big.sh)

- Command 1: This command finds and replaces all occurrences of mirror.centos.org with vault.centos.org in all .repo files in the /etc/yum.repos.d/ directory. This can help access old CentOS repositories when major mirrors are unavailable.
- Command 2: This command finds and removes the # sign at the beginning of lines containing baseurl=http in all .repo files in the /etc/yum.repos.d/ directory. This enables baseurl usage instead of disabling it.
- Command 3: This command adds a # sign to the beginning of lines containing mirrorlist=http in all .repo files in the /etc/yum.repos.d/ directory. This disables the use of mirrorlist.
- Command 4: This command adds the line sslverify=false to the end of the /etc/yum.conf file. This turns off SSL checking when using yum, which can help overcome problems related to SSL certificates

### [Source](https://medium.com/@bonguides25/fix-http-error-404-not-found-trying-other-mirror-centos-7-1600e862644c)
