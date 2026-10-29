# Aplikasi Peminjaman Sarana Kampus

Implementasi Proyek Akhir “Pengembangan Aplikasi Mobile Peminjaman Sarana Kampus Berbasis Flutter dengan Implementasi QR Code dan SQLite”.

## Fitur yang tersedia
- Login demo berbasis peran: Mahasiswa, Admin, Super Admin.
- Daftar sarana, pencarian, lokasi, dan stok.
- Pengajuan peminjaman dengan validasi jumlah, tanggal, dan tujuan.
- Admin menyetujui atau menolak pengajuan; alasan penolakan wajib diisi.
- QR Code hanya ditampilkan untuk transaksi berstatus `APPROVED`.
- Super Admin memindai QR atau memasukkan kode transaksi secara manual untuk checkout/return.
- Stok berkurang ketika checkout dan bertambah ketika return.
- Log perubahan transaksi di SQLite.
- Tambah sarana untuk Super Admin.
- Data lokal/offline pada satu perangkat; tidak ada sinkronisasi antarperangkat.

## Akun demo
Semua kata sandi: `123456`
- Mahasiswa: `mahasiswa@kampus.ac.id`
- Admin: `admin@kampus.ac.id`
- Super Admin: `superadmin@kampus.ac.id`

## Menjalankan dan menguji aplikasi
1. Pasang Flutter SDK dan Android Studio atau VS Code.
2. Buka terminal pada folder proyek dan jalankan:
   ```bash
   flutter pub get
   flutter analyze
   flutter test
   flutter run
   ```
3. Untuk pemindaian QR pada Android, izinkan akses kamera bila diminta. Izin kamera sudah tercantum pada manifest.
4. Buat APK kandidat evaluasi:
   ```bash
   flutter build apk --release
   ```
   Output standar berada di `build/app/outputs/flutter-apk/app-release.apk`. Release saat ini menggunakan debug signing, sehingga APK hanya untuk evaluasi/demo dan bukan distribusi produksi.

## Struktur
- `models/`: model pengguna, sarana, dan transaksi.
- `database/`: SQLite dan transaksi atomik.
- `providers/`: state management Provider.
- `services` (dapat diperluas): tempat logika integrasi layanan.
- `screens/`: halaman UI dan navigasi.
- `widgets/`: komponen UI yang digunakan ulang.
- `utils/`: helper status transaksi.

## Luaran Tahap 4 dan 5
- [Dokumentasi pengujian dan UAT](docs/PENGUJIAN_DAN_UAT.md) — skenario, kasus uji, perbaikan, serta form pengujian pengguna.
- [Dokumentasi teknis](docs/DOKUMENTASI_TEKNIS.md) — arsitektur, alur, menjalankan aplikasi, dan build APK.
- [Laporan Proyek Akhir](docs/LAPORAN_PROYEK_AKHIR.md) — kerangka laporan yang harus dilengkapi identitas dan hasil aktual.
- [Bahan presentasi dan panduan demo](docs/PRESENTASI_DAN_DEMO.md) — alur presentasi dan naskah demonstrasi.

## Catatan penting
Ini adalah prototipe akademik/demo, bukan sistem produksi. Akun dan password demo disimpan lokal secara plaintext. Jangan gunakan akun tersebut pada layanan nyata. Database SQLite lokal tidak menyinkronkan data antarperangkat. Pengujian kamera dan pengguna harus dilakukan langsung; dokumen proyek menandai aktivitas yang belum dijalankan agar hasil tidak diklaim secara fiktif.
