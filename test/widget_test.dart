import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peminjaman_sarana_kampus/main.dart';
import 'package:peminjaman_sarana_kampus/models/facility.dart';
import 'package:peminjaman_sarana_kampus/screens/loan_form_screen.dart';

void main() {
  testWidgets('Campus app opens on the login screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CampusLoanApp());

    expect(find.text('Sarana Kampus'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });

  testWidgets('Login rejects an invalid email before submitting',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CampusLoanApp());
    await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(find.text('Masukkan email yang valid.'), findsOneWidget);
  });

  testWidgets('Loan form requires a purpose', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoanFormScreen(
          facility: const Facility(
            id: 1,
            code: 'SRN-001',
            name: 'Proyektor',
            category: 'Elektronik',
            location: 'Gedung A',
            description: 'Proyektor presentasi',
            totalQty: 4,
            availableQty: 4,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Kirim Pengajuan'));
    await tester.pump();

    expect(find.text('Tujuan penggunaan wajib diisi.'), findsOneWidget);
  });

  testWidgets('Loan form rejects a quantity above available stock',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoanFormScreen(
          facility: const Facility(
            id: 1,
            code: 'SRN-001',
            name: 'Proyektor',
            category: 'Elektronik',
            location: 'Gedung A',
            description: 'Proyektor presentasi',
            totalQty: 4,
            availableQty: 4,
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField).first, '5');
    await tester.tap(find.text('Kirim Pengajuan'));
    await tester.pump();

    expect(find.text('Jumlah melebihi stok yang tersedia.'), findsOneWidget);
  });
}
