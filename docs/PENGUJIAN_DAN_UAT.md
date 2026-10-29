# Tahap 4 — Pengujian, Integrasi, dan Umpan Balik

## Ruang lingkup

Pengujian mencakup alur masuk, validasi formulir pengajuan, pencarian dan tampilan data, pengelolaan sarana, keputusan admin, QR, serah-terima, penyimpanan SQLite, dan penanganan kegagalan. Aplikasi menggunakan database lokal; pengujian antarpengguna pada beberapa perangkat memerlukan backend/sinkronisasi yang belum menjadi bagian implementasi ini.

## Kondisi pengujian

- Aplikasi: Peminjaman Sarana Kampus, Flutter/Dart, SQLite lokal.
- Data awal demo: 3 akun dan 4 sarana dibuat saat database pertama kali dibuat.
- Akun demo: lihat [README.md](../README.md); jangan gunakan kata sandi demo sebagai kredensial produksi.
- Otomatis: pengujian widget melalui `flutter test`, dan pemeriksaan statis melalui `flutter analyze`.
- Perangkat fisik/kamera: perlu diuji pada perangkat Android dengan kamera dan izin kamera. Hasilnya belum boleh dinyatakan lulus tanpa pelaksanaan langsung.
- Uji pengguna: lembar di bawah ini disediakan untuk sesi nyata. Tidak ada peserta atau skor yang direkayasa/dicatat dalam dokumen ini.

## Skenario dan kasus uji

| ID | Area | Langkah / masukan | Hasil yang diharapkan |
|---|---|---|---|
| TC-01 | Pembukaan | Jalankan aplikasi | Layar login dan nama aplikasi tampil |
| TC-02 | Validasi login | Masukkan email tanpa `@`, tekan Masuk | Pesan validasi tampil; proses login tidak dijalankan |
| TC-03 | Login gagal | Masukkan kredensial yang salah | Pesan gagal; sesi tidak terbentuk |
| TC-04 | Login peran | Login dengan masing-masing akun demo | Navigasi sesuai peran Mahasiswa, Admin, atau Super Admin |
| TC-05 | Pencarian | Cari sarana dengan nama, kode, kategori, dan lokasi | Hasil cocok tampil; pencarian kosong menampilkan empty state |
| TC-06 | Validasi jumlah | Ajukan jumlah 0, teks nonangka, atau lebih dari stok | Form menolak masukan |
| TC-07 | Validasi tujuan | Kosongkan tujuan lalu kirim pengajuan | Pesan “Tujuan penggunaan wajib diisi.” tampil |
| TC-08 | Validasi tanggal | Kirim tanpa tanggal; lalu coba tanggal akhir tidak setelah tanggal awal | Form meminta tanggal dan menolak rentang tidak valid |
| TC-09 | Pembuatan pengajuan | Mahasiswa mengajukan sarana, jumlah, tanggal, dan tujuan valid | Transaksi tersimpan dengan status `SUBMITTED` dan log dibuat |
| TC-10 | Keputusan admin | Admin menyetujui transaksi | Status `APPROVED`, QR tersedia, dan perubahan tercatat |
| TC-11 | Tolak tanpa alasan | Admin mencoba menolak tanpa catatan | Penolakan ditolak dan pesan alasan wajib tampil |
| TC-12 | QR tidak valid | Coba checkout pengajuan yang belum disetujui/kode tidak dikenal | Transaksi tidak berubah dan kesalahan diinformasikan |
| TC-13 | Serah-terima | Super Admin checkout transaksi disetujui lalu mengembalikan | Status berubah; stok turun saat checkout dan naik saat return |
| TC-14 | Pencegahan duplikasi | Checkout transaksi yang sudah di-checkout atau return ulang | Aksi kedua ditolak; stok tidak berubah |
| TC-15 | Ubah stok | Edit total stok di bawah unit yang sedang dipinjam | Perubahan ditolak; nilai stok tetap konsisten |
| TC-16 | Penghapusan sarana | Hapus sarana dengan transaksi aktif | Penghapusan ditolak dan pesan alasan tampil |
| TC-17 | Tambah sarana | Simpan sarana baru dengan kolom wajib kosong atau kode duplikat | Validasi/database menolak dan kesalahan terlihat |
| TC-18 | Persistensi lokal | Tutup dan buka kembali aplikasi pada perangkat sama | Data yang tersimpan masih tersedia |
| TC-19 | Refresh / navigasi | Ganti tab, muat ulang, lalu kembali ke daftar | Tidak crash; data tampil pada permukaan yang sesuai |
| TC-20 | Kamera | Beri izin kamera lalu scan QR valid pada Android | Kode terbaca satu kali dan dapat dikonfirmasi; uji perangkat wajib |

## Catatan hasil otomatis

Hasil terbaru setelah implementasi dicatat pada tabel ini. Satu kasus lulus hanya jika benar-benar dijalankan; kasus manual/perangkat tidak dianggap lulus berdasarkan inspeksi kode.

| Pemeriksaan | Hasil | Catatan |
|---|---|---|
| `flutter test` | Isi setelah menjalankan perintah | Pengujian widget otomatis |
| `flutter analyze` | Isi setelah menjalankan perintah | Pemeriksaan statis |
| `flutter build apk --release` | Isi setelah menjalankan perintah | Kandidat APK; periksa lokasi output dan tanda tangan |
| TC-20 pada perangkat Android | Belum dijalankan di lingkungan ini | Catat model perangkat, versi Android, izin kamera, dan hasil |

## Daftar masalah dan perbaikan

| Temuan | Dampak | Perbaikan |
|---|---|---|
| Lapisan database menerima nilai total dan tersedia tanpa memeriksa stok yang sedang dipinjam | Pemanggil selain form edit dapat membuat data stok tidak konsisten | Pembaruan dibungkus transaksi; database memeriksa keberadaan sarana, total minimum, jumlah dipinjam, dan stok tersedia hasil perhitungan |
| Database tidak menolak jumlah pengajuan kurang dari satu jika dipanggil di luar UI | Data transaksi tidak valid dapat tersimpan melalui pemanggil lain | `createLoan` menolak quantity di bawah satu |
| Serah-terima dapat gagal dengan kesalahan indeks jika data sarana sudah tidak ada; pengembalian juga tidak menjaga batas total stok | Kesalahan teknis tidak jelas dan nilai stok bisa melampaui total | Tambah pesan sarana tidak ditemukan serta pemeriksaan batas pengembalian |
| Pengujian otomatis hanya memeriksa tampilan awal | Validasi masukan belum terverifikasi | Tambah widget test untuk format email, tujuan wajib, dan jumlah melebihi stok |

## Lembar uji pengguna (isi setelah sesi nyata)

Lakukan uji dengan 3–5 calon pengguna. Minta tiap peserta mencoba tugas berikut tanpa dibimbing: (1) masuk sebagai mahasiswa demo, (2) temukan proyektor, (3) ajukan satu unit dengan tujuan yang jelas, (4) temukan status transaksi, dan (5) jelaskan langkah berikutnya. Uji admin/Super Admin dapat dilakukan pada sesi terpisah. Jangan meminta peserta memakai kata sandi pribadi.

Gunakan skala 1 (sangat sulit/tidak setuju) sampai 5 (sangat mudah/setuju).

| Peserta (inisial/kode) | Berhasil ajukan tanpa bantuan? | Mudah menemukan sarana (1–5) | Mudah memahami status (1–5) | Bagian membingungkan / saran | Tanggal |
|---|---|---:|---:|---|---|
| P-01 | Belum diisi | — | — | — | — |
| P-02 | Belum diisi | — | — | — | — |
| P-03 | Belum diisi | — | — | — | — |

### Kesimpulan UAT

Belum dapat disimpulkan sebelum tabel peserta diisi. Setelah sesi, rangkum jumlah peserta yang berhasil menyelesaikan tugas, rata-rata skor kemudahan, temuan berulang, prioritas perbaikan, dan bukti persetujuan peserta untuk dokumentasi (jika diperlukan).

## Penyempurnaan UI/UX yang disertakan

- Validasi dasar jumlah, tujuan, tanggal, dan email dengan pesan yang terlihat.
- State kosong, indikator status, pencarian sarana, serta tombol refresh untuk membantu orientasi dan pemulihan.
- Form pengajuan menampilkan stok sarana sebelum pengguna mengirim permintaan.
- Perubahan stok dilindungi di database agar aturan tetap berlaku walau jalur data UI berubah.

Sebelum serah terima, jalankan seluruh TC-01–TC-20 sesuai metode yang tersedia, isi hasil aktual, dan tandai kasus kamera/UX hanya setelah pengujian nyata.
