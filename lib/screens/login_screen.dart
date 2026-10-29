import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'mahasiswa@kampus.ac.id');
  final _password = TextEditingController(text: '123456');
  bool _busy = false;
  bool _obscure = true;

  @override
  void dispose() { _email.dispose(); _password.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final error = await context.read<AppProvider>().login(_email.text, _password.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(height: 88, width: 88, alignment: Alignment.center,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(26)),
              child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 46)),
            const SizedBox(height: 24),
            Text('Sarana Kampus', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Masuk untuk mengelola peminjaman sarana kampus.'),
            const SizedBox(height: 28),
            TextFormField(controller: _email, keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email kampus', prefixIcon: Icon(Icons.email_outlined)),
              validator: (v) => v == null || !v.contains('@') ? 'Masukkan email yang valid.' : null),
            const SizedBox(height: 16),
            TextFormField(controller: _password, obscureText: _obscure,
              decoration: InputDecoration(labelText: 'Kata sandi', prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscure = !_obscure)),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Kata sandi wajib diisi.' : null,
              onFieldSubmitted: (_) => _login()),
            const SizedBox(height: 22),
            FilledButton.icon(onPressed: _busy ? null : _login,
              icon: _busy ? const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2)) : const Icon(Icons.login),
              label: Text(_busy ? 'Memproses...' : 'Masuk'), style: FilledButton.styleFrom(padding: const EdgeInsets.all(16))),
            const SizedBox(height: 24),
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('Akun demo', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8), Text('Mahasiswa: mahasiswa@kampus.ac.id'),
              Text('Admin: admin@kampus.ac.id'),
              Text('Super Admin: superadmin@kampus.ac.id'),
              Text('Kata sandi semua akun: 123456'),
            ]))),
            const SizedBox(height: 8),
            const Text('Mode offline: data disimpan pada perangkat ini.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
          ]),
        )),
      ))),
    );
  }
}
