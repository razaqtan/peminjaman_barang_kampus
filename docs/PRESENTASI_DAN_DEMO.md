# Bahan Presentasi dan Panduan Demonstrasi

## Alur slide yang disarankan

1. **Judul dan tim** — nama proyek, anggota, mata kuliah.
2. **Masalah** — kesulitan pencatatan/pelacakan sarana; dukung dengan observasi tim yang benar-benar dilakukan.
3. **Pengguna dan kebutuhan** — Mahasiswa, Admin, Super Admin; kebutuhan tiap peran.
4. **Rancangan solusi** — diagram alur `ajukan → putuskan → checkout → return`, status transaksi, dan pemakaian QR.
5. **Teknologi dan arsitektur** — Flutter, Provider, SQLite, `qr_flutter`, `mobile_scanner`; jelaskan alasan dan batasan offline.
6. **Implementasi** — tampilkan login, daftar/pencarian sarana, pengajuan, status dan QR, pengelolaan sarana.
7. **Pengujian** — metode, kasus penting, hasil aktual (sertakan hanya bukti yang benar-benar dijalankan), masalah dan perbaikannya.
8. **Umpan balik pengguna** — jumlah dan profil umum peserta, tugas uji, skor/komentar tanpa identitas sensitif; bila belum diuji, nyatakan belum.
9. **Aplikasi akhir dan keterbatasan** — APK kandidat, data satu perangkat, kebutuhan uji kamera, serta pekerjaan lanjutan.
10. **Demo, kesimpulan, tanya jawab** — jelaskan ketercapaian kebutuhan dan refleksi tim.

## Naskah demonstrasi langsung (sekitar 5–7 menit)

1. Jelaskan konteks aplikasi dan batasannya: prototipe offline satu perangkat.
2. Login sebagai Mahasiswa (`mahasiswa@kampus.ac.id`, kata sandi demo `123456`); tunjukkan dashboard dan pencarian sarana.
3. Buka sarana Proyektor; ajukan satu unit, pilih tanggal mulai/selesai yang berurutan, masukkan tujuan, lalu kirim.
4. Keluar, login sebagai Admin (`admin@kampus.ac.id`, `123456`); buka daftar pengajuan dan setujui transaksi.
5. Kembali ke transaksi mahasiswa dan tampilkan QR yang baru tersedia setelah persetujuan.
6. Login sebagai Super Admin (`superadmin@kampus.ac.id`, `123456`); tunjukkan pemindaian QR di perangkat berkamera atau masukkan kode transaksi secara manual, lalu konfirmasi checkout.
7. Tunjukkan stok yang berkurang dan status transaksi. Konfirmasi return dan tunjukkan stok kembali.
8. Tutup dengan ringkasan hasil tes dan keterbatasan; jangan mengklaim sinkronisasi multi-perangkat.

## Persiapan sebelum presentasi

- Jalankan `flutter test`, `flutter analyze`, dan build APK; salin hasil aktualnya ke laporan.
- Instal dan buka APK kandidat pada Android; uji izin kamera dan skenario manual.
- Reset data/demo hanya sebelum demonstrasi jika diperlukan dan aman; jangan menghapus data pengguna tanpa persetujuan.
- Pastikan tanggal pinjam yang dipilih tidak kedaluwarsa dan database demo memiliki sarana/stok.
- Siapkan screenshot/video lokal cadangan, tetapi jelaskan bila rekaman menggantikan demo langsung.
- Sembunyikan informasi pribadi; akun demo bukan kredensial nyata.

## Daftar aset produksi oleh tim

- [ ] Slide presentasi dibuat dari alur di atas dan memuat nama/identitas tim yang benar.
- [ ] Video demonstrasi direkam dan ditinjau sebelum pengumpulan.
- [ ] URL repository diisi pada laporan setelah publikasi.
- [ ] Bukti hasil uji dan UAT yang nyata dilampirkan.
