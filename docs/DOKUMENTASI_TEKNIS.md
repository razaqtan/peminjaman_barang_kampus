# Dokumentasi Teknis — Peminjaman Sarana Kampus

## Ringkasan

Aplikasi Flutter untuk mendata sarana kampus dan mengelola pengajuan peminjaman melalui tiga peran lokal: Mahasiswa, Admin, dan Super Admin. Data disimpan dalam SQLite pada perangkat yang menjalankan aplikasi. Aplikasi tidak memiliki akun server, sinkronisasi antarperangkat, atau pencadangan cloud.

## Teknologi

- Flutter dan Dart.
- Provider untuk state management.
- SQLite melalui `sqflite`; `path` menyusun lokasi database.
- `qr_flutter` untuk menampilkan QR pengajuan yang disetujui.
- `mobile_scanner` untuk membaca QR dengan kamera.

## Struktur sumber

| Lokasi | Tanggung jawab |
|---|---|
| `lib/main.dart` | Inisialisasi database, Provider, tema dan root aplikasi |
| `lib/screens/` | Login, dashboard, daftar/detail/form sarana, alur peminjaman, scan dan QR |
| `lib/providers/app_provider.dart` | Sesi peran, pemuatan data, operasi dan notifikasi perubahan state |
| `lib/database/database_helper.dart` | Skema SQLite, seed demo, query, transaksi stok dan log |
| `lib/models/` | Representasi user, sarana, peminjaman dan log |
| `lib/widgets/` | Komponen UI reusable seperti badge status |
| `test/widget_test.dart` | Pengujian widget untuk layar awal dan validasi formulir |

## Alur utama

1. Database `campus_loan.db` dibuat pada pembukaan pertama; akun dan sarana demo dimasukkan hanya ketika database dibuat.
2. Pengguna masuk dengan akun lokal. Mahasiswa melihat pengajuannya sendiri; Admin/Super Admin dapat memproses daftar transaksi sesuai UI.
3. Mahasiswa mengirim permintaan. SQLite mencatat status `SUBMITTED` dan log awal.
4. Admin menyetujui/menolak. Penolakan membutuhkan alasan; QR hanya dihasilkan untuk status `APPROVED`.
5. Super Admin memindai QR atau mengetik kode transaksi, mengonfirmasi checkout dan return. Pembaruan stok, status, dan log dilakukan dalam transaksi SQLite.
6. Super Admin dapat menambah/mengubah/menghapus sarana; database menolak perubahan stok yang akan melanggar jumlah unit yang masih dipinjam dan penghapusan dengan transaksi aktif.

## Tabel data

- `users`: nama, email, password lokal, peran, dan status aktif.
- `facilities`: kode unik, nama, kategori, lokasi, deskripsi, total dan stok tersedia.
- `loans`: kode transaksi, peminjam, sarana, jumlah, jadwal, tujuan, status, catatan, QR payload, waktu dibuat.
- `loan_logs`: riwayat aksi, aktor, catatan, dan waktu.

Perubahan status/stok kritis dilakukan di dalam transaksi SQLite. Password akun demo disimpan plaintext untuk demonstrasi lokal; ini **bukan** praktik yang aman untuk produksi. Gunakan autentikasi backend dan penyimpanan kredensial yang sesuai sebelum menerapkan sistem nyata.

## Menyiapkan dan menjalankan

Prasyarat: Flutter SDK yang mendukung batas SDK pada `pubspec.yaml`, Android SDK untuk target Android, dan perangkat/emulator untuk menjalankan.

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

Izin kamera Android sudah dideklarasikan pada `android/app/src/main/AndroidManifest.xml`. Pengujian scan memerlukan kamera dan izin runtime pada perangkat. Bila izin ditolak, uji jalur input kode manual.

## Build APK

Untuk menghasilkan APK kandidat evaluasi:

```powershell
flutter build apk --release
```

Output standar: `build\app\outputs\flutter-apk\app-release.apk`. Konfigurasi Gradle saat ini menggunakan debug signing untuk varian release. APK ini hanya untuk demo/evaluasi, bukan distribusi produksi atau Google Play. Atur signing key rahasia melalui konfigurasi aman dan tinjau application ID/version sebelum rilis resmi. Jalankan pada perangkat Android dan lakukan TC-20 sebelum menandai APK tervalidasi kamera.

## Batasan dan risiko yang diketahui

- Database lokal per perangkat; beberapa aktor tidak berbagi status antarperangkat.
- Akun demo dan kata sandi tetap ditanam sebagai data awal lokal.
- Belum ada pengujian perangkat nyata, sinkronisasi, backup/restore, atau pengujian keamanan produksi.
- Proyek tidak dikaitkan dengan remote Git pada workspace saat dokumen ini disusun; tambahkan tautan repositori yang benar setelah pemilik proyek mempublikasikan kode.

## Transparansi sumber dan pustaka

Pustaka pihak ketiga yang menjadi dependency aplikasi tercantum di `pubspec.yaml`/`pubspec.lock`. Implementasi proyek dapat dikembangkan menggunakan bantuan AI, sesuai ketentuan akademik; mahasiswa perlu mengungkapkan penggunaan tersebut sesuai format institusi dan mampu menjelaskan arsitektur, state management, query SQLite, transaksi stok, izin kamera, serta keterbatasan yang dicantumkan di sini.
