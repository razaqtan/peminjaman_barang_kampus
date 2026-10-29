import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/facility.dart';
import '../models/loan.dart';
import '../models/loan_log.dart';
import '../models/user.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseHelper db;
  AppProvider(this.db);

  AppUser? user;
  List<Facility> facilities = [];
  List<Loan> loans = [];
  bool loading = false;
  String? errorMessage;

  // ──── Initialization ────
  Future<void> loadInitialData() async {
    await refreshFacilities();
  }

  // ──── Auth ────
  Future<String?> login(String email, String password) async {
    _setLoading(true);
    try {
      final row = await db.login(email, password);
      if (row == null) return 'Email atau kata sandi salah, atau akun tidak aktif.';
      user = AppUser.fromMap(row);
      await refreshFacilities();
      await refreshLoans();
      notifyListeners();
      return null;
    } catch (e) {
      return 'Terjadi kesalahan saat login: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    user = null;
    loans = [];
    errorMessage = null;
    notifyListeners();
  }

  // ──── Facilities ────
  Future<void> refreshFacilities() async {
    try {
      facilities = (await db.getFacilities()).map(Facility.fromMap).toList();
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Gagal memuat data sarana: ${e.toString()}';
    }
    notifyListeners();
  }

  Future<void> addFacility({
    required String code,
    required String name,
    required String category,
    required String location,
    required String description,
    required int quantity,
  }) async {
    await db.addFacility(
      code: code,
      name: name,
      category: category,
      location: location,
      description: description,
      quantity: quantity,
    );
    await refreshFacilities();
  }

  Future<void> updateFacility({
    required int id,
    required String code,
    required String name,
    required String category,
    required String location,
    required String description,
    required int totalQty,
    required int availableQty,
  }) async {
    await db.updateFacility(
      id: id,
      code: code,
      name: name,
      category: category,
      location: location,
      description: description,
      totalQty: totalQty,
      availableQty: availableQty,
    );
    await refreshFacilities();
  }

  Future<void> deleteFacility(int id) async {
    await db.deleteFacility(id);
    await refreshFacilities();
  }

  // ──── Loans ────
  Future<void> refreshLoans() async {
    try {
      loans = (await db.getLoans(
              borrowerId: user?.role == 'MAHASISWA' ? user!.id : null))
          .map(Loan.fromMap)
          .toList();
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Gagal memuat data peminjaman: ${e.toString()}';
    }
    notifyListeners();
  }

  Future<void> createLoan({
    required Facility facility,
    required int quantity,
    required DateTime start,
    required DateTime end,
    required String purpose,
  }) async {
    if (user == null) throw Exception('Silakan login kembali.');
    await db.createLoan(
      borrowerId: user!.id,
      facilityId: facility.id,
      quantity: quantity,
      startAt: start.toIso8601String(),
      endAt: end.toIso8601String(),
      purpose: purpose,
    );
    await refreshLoans();
    await refreshFacilities();
  }

  Future<void> decideLoan(Loan loan, bool approve, String note) async {
    await db.decideLoan(loan.id, user!.id, approve, note);
    await refreshLoans();
  }

  Future<void> cancelLoan(Loan loan) async {
    if (user == null) throw Exception('Silakan login kembali.');
    await db.cancelLoan(loan.id, user!.id);
    await refreshLoans();
  }

  Future<void> handover(String code, bool checkout) async {
    await db.completeHandover(code, user!.id, checkout);
    await refreshLoans();
    await refreshFacilities();
  }

  // ──── Loan Logs ────
  Future<List<LoanLog>> getLoanLogs(int loanId) async {
    final rows = await db.getLoanLogs(loanId);
    return rows.map(LoanLog.fromMap).toList();
  }

  // ──── Helpers ────
  void _setLoading(bool value) {
    loading = value;
    notifyListeners();
  }
}
