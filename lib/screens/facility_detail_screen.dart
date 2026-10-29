import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/facility.dart';
import '../providers/app_provider.dart';

class FacilityDetailScreen extends StatelessWidget {
  final Facility facility;
  const FacilityDetailScreen({super.key, required this.facility});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = context.watch<AppProvider>();
    final user = app.user;
    final isSuperAdmin = user?.role == 'SUPER_ADMIN';

    // Refresh facility data from provider to keep it in sync
    final currentFacility = app.facilities.firstWhere(
      (f) => f.id == facility.id,
      orElse: () => facility,
    );

    final usagePercent = currentFacility.totalQty > 0
        ? ((currentFacility.totalQty - currentFacility.availableQty) /
                currentFacility.totalQty *
                100)
            .round()
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Sarana'),
        actions: isSuperAdmin
            ? [
                IconButton(
                  tooltip: 'Edit sarana',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _showEditDialog(context, currentFacility),
                ),
                IconButton(
                  tooltip: 'Hapus sarana',
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(context, currentFacility),
                ),
              ]
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2457C5), Color(0xFF5684E8)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child:
                      const Icon(Icons.inventory_2, color: Colors.white, size: 38),
                ),
                const SizedBox(height: 16),
                Text(
                  currentFacility.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  currentFacility.code,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stock card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ketersediaan Stok',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _stockIndicator(
                          'Tersedia',
                          currentFacility.availableQty,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _stockIndicator(
                          'Dipinjam',
                          currentFacility.totalQty -
                              currentFacility.availableQty,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _stockIndicator(
                          'Total',
                          currentFacility.totalQty,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: usagePercent / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          AlwaysStoppedAnimation(usagePercent > 80 ? Colors.red : Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Penggunaan: $usagePercent%',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Detail card
          Card(
            child: Column(
              children: [
                _detailTile(Icons.category_outlined, 'Kategori',
                    currentFacility.category),
                const Divider(height: 1),
                _detailTile(Icons.location_on_outlined, 'Lokasi',
                    currentFacility.location),
                const Divider(height: 1),
                _detailTile(Icons.description_outlined, 'Deskripsi',
                    currentFacility.description),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: user?.role == 'MAHASISWA' && currentFacility.availableQty > 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, '/loan-form',
                    arguments: currentFacility);
              },
              icon: const Icon(Icons.add),
              label: const Text('Ajukan Peminjaman'),
            )
          : null,
    );
  }

  Widget _stockIndicator(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(fontSize: 11, color: color.withOpacity(.8))),
        ],
      ),
    );
  }

  Widget _detailTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2457C5)),
      title: Text(title,
          style: const TextStyle(color: Colors.black54, fontSize: 13)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(value, style: const TextStyle(fontSize: 15)),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Facility f) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Sarana'),
        content: Text(
            'Apakah Anda yakin ingin menghapus "${f.name}" (${f.code})?\n\nTindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context.read<AppProvider>().deleteFacility(f.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Sarana berhasil dihapus.')),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            e.toString().replaceFirst('Exception: ', ''))),
                  );
                }
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Facility f) {
    final cCode = TextEditingController(text: f.code);
    final cName = TextEditingController(text: f.name);
    final cCategory = TextEditingController(text: f.category);
    final cLocation = TextEditingController(text: f.location);
    final cDescription = TextEditingController(text: f.description);
    final cTotalQty = TextEditingController(text: f.totalQty.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Sarana'),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: cCode,
                    decoration:
                        const InputDecoration(labelText: 'Kode sarana'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: cName,
                    decoration:
                        const InputDecoration(labelText: 'Nama sarana'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: cCategory,
                    decoration:
                        const InputDecoration(labelText: 'Kategori'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: cLocation,
                    decoration:
                        const InputDecoration(labelText: 'Lokasi'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: cDescription,
                    decoration:
                        const InputDecoration(labelText: 'Deskripsi'),
                    minLines: 2,
                    maxLines: 4,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: cTotalQty,
                    decoration:
                        const InputDecoration(labelText: 'Total stok'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n < 1) return 'Minimal 1';
                      final borrowed = f.totalQty - f.availableQty;
                      if (n < borrowed) {
                        return 'Tidak boleh kurang dari jumlah yang sedang dipinjam ($borrowed)';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              try {
                final newTotal = int.parse(cTotalQty.text);
                final borrowed = f.totalQty - f.availableQty;
                final newAvailable = newTotal - borrowed;
                await context.read<AppProvider>().updateFacility(
                      id: f.id,
                      code: cCode.text,
                      name: cName.text,
                      category: cCategory.text,
                      location: cLocation.text,
                      description: cDescription.text,
                      totalQty: newTotal,
                      availableQty: newAvailable,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Sarana berhasil diperbarui.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal: $e')),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
