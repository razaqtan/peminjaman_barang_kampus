import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._();

  Database? _db;
  Future<Database> get database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'campus_loan.db');
    _db = await openDatabase(path, version: 1, onCreate: _create);
    return _db!;
  }

  Future<void> _create(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL, email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL, role TEXT NOT NULL, is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute('''
      CREATE TABLE facilities(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE, name TEXT NOT NULL, category TEXT NOT NULL,
        location TEXT NOT NULL, description TEXT NOT NULL,
        total_qty INTEGER NOT NULL, available_qty INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE loans(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        loan_code TEXT NOT NULL UNIQUE, borrower_id INTEGER NOT NULL,
        facility_id INTEGER NOT NULL, quantity INTEGER NOT NULL,
        start_at TEXT NOT NULL, end_at TEXT NOT NULL, purpose TEXT NOT NULL,
        status TEXT NOT NULL, note TEXT NOT NULL DEFAULT '', qr_payload TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE loan_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT, loan_id INTEGER NOT NULL,
        action TEXT NOT NULL, actor_id INTEGER NOT NULL, note TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    final batch = db.batch();
    batch.insert('users', {'name':'Mahasiswa Demo','email':'mahasiswa@kampus.ac.id','password':'123456','role':'MAHASISWA'});
    batch.insert('users', {'name':'Admin Demo','email':'admin@kampus.ac.id','password':'123456','role':'ADMIN'});
    batch.insert('users', {'name':'Super Admin Demo','email':'superadmin@kampus.ac.id','password':'123456','role':'SUPER_ADMIN'});
    batch.insert('facilities', {'code':'SRN-001','name':'Proyektor','category':'Elektronik','location':'Gedung A, Ruang 101','description':'Proyektor untuk presentasi dan kegiatan perkuliahan.','total_qty':8,'available_qty':8});
    batch.insert('facilities', {'code':'SRN-002','name':'Kabel HDMI','category':'Aksesori','location':'Gudang Sarana','description':'Kabel HDMI untuk koneksi perangkat presentasi.','total_qty':12,'available_qty':12});
    batch.insert('facilities', {'code':'SRN-003','name':'Kursi Lipat','category':'Perabot','location':'Gedung B, Gudang 2','description':'Kursi lipat untuk kegiatan kampus.','total_qty':40,'available_qty':40});
    batch.insert('facilities', {'code':'SRN-004','name':'Speaker Portable','category':'Audio','location':'Gedung A, Ruang 103','description':'Speaker portabel untuk acara dan diskusi.','total_qty':5,'available_qty':5});
    await batch.commit(noResult: true);
  }

  // ──── Users ────
  Future<List<Map<String, Object?>>> getUsers() async => (await database).query('users');
  Future<Map<String, Object?>?> login(String email, String password) async {
    final rows = await (await database).query('users',
      where: 'LOWER(email) = LOWER(?) AND password = ? AND is_active = 1',
      whereArgs: [email.trim(), password], limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  // ──── Facilities ────
  Future<List<Map<String, Object?>>> getFacilities() async =>
      (await database).query('facilities', orderBy: 'name COLLATE NOCASE');

  Future<Map<String, Object?>?> getFacilityById(int id) async {
    final rows = await (await database).query('facilities', where: 'id=?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> addFacility({required String code, required String name, required String category,
    required String location, required String description, required int quantity}) async {
    await (await database).insert('facilities', {
      'code':code.trim(), 'name':name.trim(), 'category':category.trim(),
      'location':location.trim(), 'description':description.trim(),
      'total_qty':quantity, 'available_qty':quantity,
    });
  }

  Future<void> updateFacility({required int id, required String code, required String name,
    required String category, required String location, required String description,
    required int totalQty, required int availableQty}) async {
    final db = await database;
    await db.transaction((txn) async {
      final rows = await txn.query(
        'facilities',
        columns: ['total_qty', 'available_qty'],
        where: 'id=?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) throw Exception('Sarana tidak ditemukan.');
      if (totalQty < 1) throw Exception('Total stok minimal 1.');

      final borrowed = (rows.first['total_qty'] as int) -
          (rows.first['available_qty'] as int);
      if (totalQty < borrowed || availableQty != totalQty - borrowed) {
        throw Exception(
          'Stok tidak valid. Total stok tidak boleh kurang dari jumlah yang sedang dipinjam.',
        );
      }

      await txn.update('facilities', {
        'code': code.trim(), 'name': name.trim(), 'category': category.trim(),
        'location': location.trim(), 'description': description.trim(),
        'total_qty': totalQty, 'available_qty': availableQty,
      }, where: 'id=?', whereArgs: [id]);
    });
  }

  Future<void> deleteFacility(int id) async {
    final db = await database;
    // Check for active loans referencing this facility
    final activeLoans = await db.query('loans',
      where: 'facility_id = ? AND status IN (?, ?, ?)',
      whereArgs: [id, 'SUBMITTED', 'APPROVED', 'CHECKED_OUT'], limit: 1);
    if (activeLoans.isNotEmpty) {
      throw Exception('Sarana tidak dapat dihapus karena masih memiliki peminjaman aktif.');
    }
    await db.delete('facilities', where: 'id=?', whereArgs: [id]);
  }

  // ──── Loans ────
  Future<List<Map<String, Object?>>> getLoans({int? borrowerId}) async {
    final db = await database;
    final where = borrowerId == null ? '' : 'WHERE l.borrower_id = ?';
    final args = borrowerId == null ? <Object?>[] : <Object?>[borrowerId];
    return db.rawQuery('''
      SELECT l.*, u.name AS borrower_name, f.name AS facility_name
      FROM loans l JOIN users u ON u.id=l.borrower_id
      JOIN facilities f ON f.id=l.facility_id $where
      ORDER BY l.id DESC
    ''', args);
  }

  Future<int> createLoan({
    required int borrowerId, required int facilityId, required int quantity,
    required String startAt, required String endAt, required String purpose,
  }) async {
    if (quantity < 1) throw Exception('Jumlah peminjaman minimal 1.');
    final db = await database;
    return db.transaction((txn) async {
      final facilities = await txn.query('facilities', where: 'id=?', whereArgs: [facilityId], limit: 1);
      if (facilities.isEmpty || (facilities.first['available_qty'] as int) < quantity) {
        throw Exception('Stok tidak mencukupi. Silakan perbarui data sarana.');
      }
      final now = DateTime.now().toIso8601String();
      final code = 'PJM-${DateTime.now().millisecondsSinceEpoch}';
      final id = await txn.insert('loans', {
        'loan_code': code, 'borrower_id': borrowerId, 'facility_id': facilityId,
        'quantity': quantity, 'start_at': startAt, 'end_at': endAt,
        'purpose': purpose, 'status': 'SUBMITTED', 'note': '',
        'qr_payload': '', 'created_at': now,
      });
      await txn.insert('loan_logs', {'loan_id':id,'action':'SUBMITTED','actor_id':borrowerId,'note':'Pengajuan dibuat','created_at':now});
      return id;
    });
  }

  Future<void> decideLoan(int loanId, int actorId, bool approve, String note) async {
    final db = await database;
    await db.transaction((txn) async {
      final rows = await txn.query('loans', where:'id=?', whereArgs:[loanId], limit:1);
      if (rows.isEmpty || rows.first['status'] != 'SUBMITTED') {
        throw Exception('Hanya pengajuan SUBMITTED yang dapat diproses.');
      }
      if (!approve && note.trim().isEmpty) throw Exception('Alasan penolakan wajib diisi.');
      final status = approve ? 'APPROVED' : 'REJECTED';
      final code = rows.first['loan_code'] as String;
      final now = DateTime.now().toIso8601String();
      await txn.update('loans', {'status':status,'note':note.trim(),'qr_payload':approve ? code : ''}, where:'id=?', whereArgs:[loanId]);
      await txn.insert('loan_logs', {'loan_id':loanId,'action':status,'actor_id':actorId,'note':note.trim(),'created_at':now});
    });
  }

  Future<void> cancelLoan(int loanId, int actorId) async {
    final db = await database;
    await db.transaction((txn) async {
      final rows = await txn.query('loans', where: 'id=?', whereArgs: [loanId], limit: 1);
      if (rows.isEmpty) throw Exception('Transaksi tidak ditemukan.');
      final status = rows.first['status'] as String;
      if (status != 'SUBMITTED') {
        throw Exception('Hanya pengajuan berstatus SUBMITTED yang dapat dibatalkan.');
      }
      final now = DateTime.now().toIso8601String();
      await txn.update('loans', {'status': 'CANCELLED', 'note': 'Dibatalkan oleh peminjam'}, where: 'id=?', whereArgs: [loanId]);
      await txn.insert('loan_logs', {'loan_id': loanId, 'action': 'CANCELLED', 'actor_id': actorId, 'note': 'Pengajuan dibatalkan oleh peminjam', 'created_at': now});
    });
  }

  Future<void> completeHandover(String code, int actorId, bool checkout) async {
    final db = await database;
    await db.transaction((txn) async {
      final rows = await txn.query('loans', where:'loan_code=?', whereArgs:[code.trim()], limit:1);
      if (rows.isEmpty) throw Exception('Transaksi tidak ditemukan.');
      final loan = rows.first;
      final status = loan['status'] as String;
      final quantity = loan['quantity'] as int;
      final facilityId = loan['facility_id'] as int;
      final next = checkout ? 'CHECKED_OUT' : 'RETURNED';
      if (checkout && status != 'APPROVED') throw Exception('QR hanya berlaku untuk transaksi APPROVED.');
      if (!checkout && status != 'CHECKED_OUT') throw Exception('Hanya transaksi CHECKED_OUT yang dapat dikembalikan.');
      final facilityRows = await txn.query('facilities', where:'id=?', whereArgs:[facilityId], limit:1);
      if (facilityRows.isEmpty) throw Exception('Sarana transaksi tidak ditemukan.');
      final facility = facilityRows.first;
      final available = facility['available_qty'] as int;
      if (checkout && available < quantity) throw Exception('Stok sarana tidak mencukupi.');
      final total = facility['total_qty'] as int;
      if (!checkout && available + quantity > total) {
        throw Exception('Pengembalian melebihi total stok sarana.');
      }
      await txn.update('facilities', {'available_qty': checkout ? available - quantity : available + quantity},
        where:'id=?', whereArgs:[facilityId]);
      final now = DateTime.now().toIso8601String();
      await txn.update('loans', {'status':next}, where:'id=?', whereArgs:[loan['id']]);
      await txn.insert('loan_logs', {'loan_id':loan['id'],'action':next,'actor_id':actorId,'note':checkout ? 'Pengambilan dikonfirmasi' : 'Pengembalian dikonfirmasi','created_at':now});
    });
  }

  // ──── Loan Logs ────
  Future<List<Map<String, Object?>>> getLoanLogs(int loanId) async {
    final db = await database;
    return db.rawQuery('''
      SELECT ll.*, u.name AS actor_name
      FROM loan_logs ll
      LEFT JOIN users u ON u.id = ll.actor_id
      WHERE ll.loan_id = ?
      ORDER BY ll.id ASC
    ''', [loanId]);
  }

  // ──── Dashboard Stats ────
  Future<Map<String, int>> getDashboardStats({int? borrowerId}) async {
    final db = await database;
    final where = borrowerId != null ? 'WHERE borrower_id = ?' : '';
    final args = borrowerId != null ? [borrowerId] : <Object?>[];
    final result = await db.rawQuery('''
      SELECT
        COUNT(*) AS total,
        SUM(CASE WHEN status='SUBMITTED' THEN 1 ELSE 0 END) AS submitted,
        SUM(CASE WHEN status='APPROVED' THEN 1 ELSE 0 END) AS approved,
        SUM(CASE WHEN status='CHECKED_OUT' THEN 1 ELSE 0 END) AS checked_out,
        SUM(CASE WHEN status='RETURNED' THEN 1 ELSE 0 END) AS returned,
        SUM(CASE WHEN status='REJECTED' THEN 1 ELSE 0 END) AS rejected,
        SUM(CASE WHEN status='CANCELLED' THEN 1 ELSE 0 END) AS cancelled
      FROM loans $where
    ''', args);
    final row = result.first;
    return {
      'total': (row['total'] as int?) ?? 0,
      'submitted': (row['submitted'] as int?) ?? 0,
      'approved': (row['approved'] as int?) ?? 0,
      'checked_out': (row['checked_out'] as int?) ?? 0,
      'returned': (row['returned'] as int?) ?? 0,
      'rejected': (row['rejected'] as int?) ?? 0,
      'cancelled': (row['cancelled'] as int?) ?? 0,
    };
  }
}
