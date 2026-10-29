# Laporan Proyek Akhir

## Judul

**Pengembangan Aplikasi Mobile Peminjaman Sarana Kampus Berbasis Flutter dengan Implementasi QR Code dan SQLite**

## Identitas tim

Lengkapi sebelum pengumpulan:

- Nama anggota/NIM: `[isi oleh tim]`
- Kelas/mata kuliah: `[isi]`
- Dosen pembimbing/pengampu: `[isi]`
- Institusi dan tanggal: `[isi]`

## 1. Masalah dan tujuan

Pencatatan peminjaman sarana kampus secara manual dapat menyulitkan pencarian ketersediaan, pelacakan keputusan, dan pencatatan pengambilan/pengembalian. Proyek ini menyediakan prototipe mobile untuk melihat sarana, mengajukan peminjaman, memproses persetujuan, serta mencatat serah-terima melalui QR dan database SQLite.

Tujuan implementasi adalah menyatukan alur tersebut pada satu aplikasi Flutter yang dapat didemonstrasikan secara offline pada satu perangkat. Implementasi ini prototipe akademik; bukan layanan produksi atau sistem multi-perangkat.

## 2. Kebutuhan pengguna

- Mahasiswa: masuk, mencari sarana dan stok, mengajukan permintaan dengan jumlah/jadwal/tujuan, melihat status dan QR setelah disetujui.
- Admin: meninjau pengajuan dan menerima atau menolak dengan alasan.
- Super Admin: memelihara data sarana, memindai/memasukkan kode, dan mengonfirmasi pengambilan serta pengembalian.
- Semua peran: memperoleh umpan balik saat validasi gagal; riwayat operasi tersimpan lokal.

## 3. Rancangan solusi dan implementasi

Flutter menyediakan antarmuka Android; Provider mengelola state; SQLite menyimpan akun demo, sarana, transaksi, dan log. Alur peminjaman mengikuti status `SUBMITTED` → `APPROVED` atau `REJECTED` → `CHECKED_OUT` → `RETURNED`; pengajuan `SUBMITTED` dapat dibatalkan. Stok berkurang saat checkout dan bertambah saat return. QR membawa kode transaksi dan hanya tersedia sesudah persetujuan.

Detail arsitektur dan batasan teknis: [DOKUMENTASI_TEKNIS.md](DOKUMENTASI_TEKNIS.md). Skenario dan temuan uji: [PENGUJIAN_DAN_UAT.md](PENGUJIAN_DAN_UAT.md).

## 4. Integrasi dan pengujian (Tahap 4)

### Pelaksanaan

Isi berdasarkan hasil nyata:

- Perintah otomatis dan hasil/versi Flutter: `[isi setelah menjalankan; lihat tabel hasil di PENGUJIAN_DAN_UAT.md]`
- Perangkat/emulator dan versi Android: `[isi]`
- Jumlah peserta uji pengguna: `[isi; jangan mengisi sebelum sesi berlangsung]`
- Kasus lulus/gagal/belum dijalankan: `[isi]`

### Temuan dan tindak lanjut

Implementasi memperketat konsistensi jumlah stok di operasi database, menolak jumlah pinjaman kurang dari satu, memberi kesalahan eksplisit pada data sarana yang hilang atau pengembalian melebihi total, serta menambahkan pengujian widget untuk validasi email, tujuan, dan jumlah. Catat regresi atau masalah tambahan berdasarkan eksekusi nyata pada [PENGUJIAN_DAN_UAT.md](PENGUJIAN_DAN_UAT.md).

### Umpan balik pengguna

Belum ada hasil pengguna yang diklaim pada dokumen ini. Isi tabel peserta dan simpulan UAT di dokumen pengujian setelah memperoleh umpan balik calon pengguna.

## 5. Hasil akhir (Tahap 5)

- Kode Flutter: folder proyek ini.
- APK kandidat: dibuat dengan `flutter build apk --release`; verifikasi file dan uji instalasi sebelum pengumpulan.
- Repositori Git: belum tersedia/tertaut pada workspace ini; tambahkan URL remote publik/private yang disetujui institusi: `[isi URL]`.
- Dokumentasi teknis: [DOKUMENTASI_TEKNIS.md](DOKUMENTASI_TEKNIS.md).
- Skenario pengujian dan hasil: [PENGUJIAN_DAN_UAT.md](PENGUJIAN_DAN_UAT.md).
- Bahan presentasi dan panduan demonstrasi: [PRESENTASI_DAN_DEMO.md](PRESENTASI_DAN_DEMO.md).
- Video demo: perlu direkam oleh tim pada aplikasi yang berjalan; belum dibuat oleh dokumen ini.

## 6. Evaluasi dan keterbatasan

Keberhasilan fungsi harus dinilai dari hasil kasus uji, bukan hanya keberadaan layar. Database SQLite lokal tidak mendukung pertukaran data antarperangkat. Akun demo memakai password tetap dan penyimpanan lokal tidak dimaksudkan sebagai keamanan produksi. Scan QR wajib diuji dengan kamera perangkat Android; uji widget tidak membuktikan perilaku kamera fisik.

## 7. Transparansi dan kontribusi

Tuliskan pembagian kerja setiap anggota dan cantumkan pemakaian pustaka eksternal, kode sumber terbuka, API, dan bantuan kecerdasan artifisial sesuai aturan kampus. Tim harus dapat menjelaskan kode yang dikumpulkan. Lengkapi bagian ini sendiri berdasarkan proses pengerjaan aktual.

## 8. Kesimpulan

Proyek mengintegrasikan prototipe peminjaman sarana berbasis Flutter dengan SQLite, Provider, QR, peran pengguna, dan pencatatan perubahan. Status final, kelayakan APK, dan kemudahan penggunaan baru dapat disimpulkan setelah hasil build, pengujian Android, dan sesi UAT aktual dicatat pada dokumen terkait.
