import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/database_helper.dart';
import 'providers/app_provider.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = DatabaseHelper();
  await db.database;
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(db)..loadInitialData(),
      child: const CampusLoanApp(),
    ),
  );
}

class CampusLoanApp extends StatelessWidget {
  const CampusLoanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sarana Kampus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2457C5)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
