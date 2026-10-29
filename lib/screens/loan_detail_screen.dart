import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/loan.dart';
import '../models/loan_log.dart';
import '../providers/app_provider.dart';
import '../utils/app_constants.dart';
import '../widgets/status_badge.dart';
import 'qr_screen.dart';

class LoanDetailScreen extends StatefulWidget {
  final Loan loan;
  final bool admin;
  const LoanDetailScreen({super.key, required this.loan, this.admin = false});
  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen> {
  final _note = TextEditingController();
  bool _busy = false;
  List<LoanLog>? _logs;
  bool _logsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    try {
      final logs =
          await context.read<AppProvider>().getLoanLogs(widget.loan.id);
      if (mounted) setState(() { _logs = logs; _logsLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _logsLoading = false);
    }
  }

  Future<void> _decide(bool approve) async {
    if (!approve && _note.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alasan penolakan wajib diisi.')),
      );
      return;
    }

    final confirmed = await _showConfirmDialog(
      approve ? 'Setujui Pengajuan' : 'Tolak Pengajuan',
      approve
          ? 'Apakah Anda yakin ingin menyetujui pengajuan peminjaman ini?'
          : 'Apakah Anda yakin ingin menolak pengajuan peminjaman ini?',
      approve ? 'Setujui' : 'Tolak',
      approve ? null : Colors.red,
    );
    if (!confirmed) return;

    setState(() => _busy = true);
    try {
      await context
          .read<AppProvider>()
          .decideLoan(widget.loan, approve, _note.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                approve ? 'Pengajuan disetujui.' : 'Pengajuan ditolak.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancelLoan() async {
    final confirmed = await _showConfirmDialog(
      'Batalkan Pengajuan',
      'Apakah Anda yakin ingin membatalkan pengajuan peminjaman ini?\n\nTindakan ini tidak dapat dibatalkan.',
      'Ya, Batalkan',
      Colors.red,
    );
    if (!confirmed) return;

    setState(() => _busy = true);
    try {
      await context.read<AppProvider>().cancelLoan(widget.loan);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengajuan berhasil dibatalkan.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _showConfirmDialog(
      String title, String message, String confirmText, Color? color) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                style: color != null
                    ? FilledButton.styleFrom(backgroundColor: color)
                    : null,
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(confirmText),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.loan;
    final app = context.watch<AppProvider>();
    final isOwner = app.user?.id == l.borrowerId;
    final canCancel = isOwner && l.status == 'SUBMITTED';

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Peminjaman')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.facilityName,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(l.loanCode,
                      style: const TextStyle(
                          color: Colors.black54, fontFamily: 'monospace')),
                  const SizedBox(height: 12),
                  StatusBadge(l.status, showIcon: true),
                ],
              ),
            ),
          ),

          // Details
          Card(
            child: Column(
              children: [
                _detail(Icons.person_outline, 'Peminjam', l.borrowerName),
                const Divider(height: 1),
                _detail(Icons.numbers, 'Jumlah', '${l.quantity} unit'),
                const Divider(height: 1),
                _detail(Icons.calendar_today, 'Tanggal Mulai',
                    formatDate(l.startAt)),
                const Divider(height: 1),
                _detail(
                    Icons.event, 'Tanggal Selesai', formatDate(l.endAt)),
                const Divider(height: 1),
                _detail(Icons.description_outlined, 'Tujuan', l.purpose),
                if (l.note.isNotEmpty) ...[
                  const Divider(height: 1),
                  _detail(Icons.note_outlined, 'Catatan', l.note),
                ],
              ],
            ),
          ),

          // QR Code button
          if (l.status == 'APPROVED' && !widget.admin) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => QrScreen(loan: l)),
              ),
              icon: const Icon(Icons.qr_code_2),
              label: const Text('Tampilkan QR Code'),
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(14)),
            ),
          ],

          // Cancel button for student
          if (canCancel) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _busy ? null : _cancelLoan,
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              label: const Text('Batalkan Pengajuan',
                  style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(14),
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ],

          // Admin actions
          if (widget.admin && l.status == 'SUBMITTED') ...[
            const SizedBox(height: 16),
            Text('Keputusan Admin',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _note,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Catatan / alasan keputusan',
                hintText: 'Wajib diisi jika menolak',
                prefixIcon: Icon(Icons.edit_note),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _busy ? null : () => _decide(true),
                    icon: const Icon(Icons.check),
                    label: const Text('Setujui'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : () => _decide(false),
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text('Tolak',
                        style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // ──── Transaction History Log ────
          const SizedBox(height: 20),
          Text('Riwayat Transaksi',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_logsLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_logs == null || _logs!.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text('Belum ada riwayat.',
                      style: TextStyle(color: Colors.grey.shade500)),
                ),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: _logs!.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final log = entry.value;
                    final isLast = idx == _logs!.length - 1;
                    return _logItem(log, isLast);
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _detail(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2457C5), size: 20),
      title: Text(title,
          style: const TextStyle(color: Colors.black54, fontSize: 13)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(value, style: const TextStyle(fontSize: 15)),
      ),
    );
  }

  Widget _logItem(LoanLog log, bool isLast) {
    final color = statusColor(log.action);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StatusBadge(log.action),
                      const Spacer(),
                      Text(
                        formatDateTime(log.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    log.actorName.isNotEmpty
                        ? 'Oleh: ${log.actorName}'
                        : 'Sistem',
                    style: const TextStyle(fontSize: 13),
                  ),
                  if (log.note.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      log.note,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
