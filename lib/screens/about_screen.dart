import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Aplikasi')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              height: 96,
              width: 96,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.apartment_rounded,
                  color: Colors.white, size: 52),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            appName,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Versi $appVersion',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Deskripsi',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(appDescription),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.code),
                  title: Text('Framework'),
                  subtitle: Text('Flutter + Dart'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.storage),
                  title: Text('Database'),
                  subtitle: Text('SQLite (sqflite)'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.sync_alt),
                  title: Text('State Management'),
                  subtitle: Text('Provider'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.qr_code),
                  title: Text('QR Code'),
                  subtitle: Text('qr_flutter + mobile_scanner'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.cloud_off),
                  title: Text('Mode Data'),
                  subtitle: Text('Offline — data lokal pada perangkat'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fitur Utama',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _featureItem(Icons.person_outline,
                      'Login multi-role (Mahasiswa, Admin, Super Admin)'),
                  _featureItem(Icons.inventory_2_outlined,
                      'Pengelolaan sarana kampus'),
                  _featureItem(Icons.receipt_long,
                      'Pengajuan dan persetujuan peminjaman'),
                  _featureItem(Icons.qr_code_scanner,
                      'QR Code untuk serah-terima sarana'),
                  _featureItem(
                      Icons.history, 'Riwayat dan log perubahan transaksi'),
                  _featureItem(Icons.search, 'Pencarian sarana'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pengembang',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Proyek Akhir — Mobile Programming'),
                  const SizedBox(height: 4),
                  const Text(
                    'Dikembangkan sebagai bagian tugas akhir mata kuliah '
                    'Mobile Programming menggunakan framework Flutter.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '© 2026 Proyek Akhir Mobile Programming',
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  static Widget _featureItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2457C5)),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}
