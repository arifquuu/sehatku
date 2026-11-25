import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/clinic_data_provider.dart';
import '../routing/app_router.dart';
import '../theme/sehatku_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nikController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bpjsController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _bloodType = 'O+';
  bool _obscurePassword = true;

  static const List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bpjsController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final clinic = context.read<ClinicDataProvider>();

    final success = await auth.register(
      fullName: _nameController.text.trim(),
      nik: _nikController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
      bloodType: _bloodType,
      bpjsNumber: _bpjsController.text.trim(),
    );

    if (!mounted) return;
    if (success && auth.currentUser != null) {
      await clinic.applyAuthenticatedUser(auth.currentUser!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun pasien berhasil didaftarkan ke MySQL.'),
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.home,
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final subtleTextColor = isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF475569);

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun Pasien')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Buat Akun Klinik SehatKu',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Data akun dan kata sandi terenkripsi bcrypt akan disimpan pada tabel users di database sehatku_db.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: subtleTextColor,
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (auth.errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF450A0A)
                                  : const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFFB91C1C)
                                    : const Color(0xFFFECACA),
                              ),
                            ),
                            child: Text(
                              auth.errorMessage!,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDark
                                    ? const Color(0xFFFECACA)
                                    : const Color(0xFF991B1B),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        TextFormField(
                          key: const Key('register_name_field'),
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Nama Lengkap Pasien',
                            hintText: 'Nama sesuai KTP',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().length < 3) {
                              return 'Nama lengkap minimal 3 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('register_nik_field'),
                          controller: _nikController,
                          keyboardType: TextInputType.number,
                          maxLength: 16,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'NIK Pasien (16 Digit)',
                            hintText: '16 digit angka KTP',
                            prefixIcon: Icon(Icons.badge_outlined),
                            counterText: '',
                          ),
                          validator: (val) {
                            final digits = (val ?? '').replaceAll(
                              RegExp(r'\D'),
                              '',
                            );
                            if (digits.length != 16) {
                              return 'NIK wajib terdiri dari tepat 16 digit angka';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('register_email_field'),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Email Aktif',
                            hintText: 'nama@email.com',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (val) {
                            final text = (val ?? '').trim();
                            if (text.isEmpty ||
                                !text.contains('@') ||
                                !text.contains('.')) {
                              return 'Masukkan alamat email yang valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final phoneField = TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'No. Telepon (Opsional)',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                            );
                            final bloodField = DropdownButtonFormField<String>(
                              initialValue: _bloodType,
                              decoration: const InputDecoration(
                                labelText: 'Golongan Darah',
                                prefixIcon: Icon(Icons.bloodtype_outlined),
                              ),
                              items: _bloodTypes
                                  .map(
                                    (b) => DropdownMenuItem(
                                      value: b,
                                      child: Text(b),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _bloodType = val);
                                }
                              },
                            );

                            if (constraints.maxWidth < 380) {
                              return Column(
                                children: [
                                  phoneField,
                                  const SizedBox(height: 12),
                                  bloodField,
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(flex: 3, child: phoneField),
                                const SizedBox(width: 12),
                                Expanded(flex: 2, child: bloodField),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _bpjsController,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Nomor Kartu BPJS (Opsional)',
                            prefixIcon: Icon(Icons.health_and_safety_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('register_password_field'),
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Kata Sandi',
                            hintText: 'Minimal 6 karakter',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword
                                  ? 'Tampilkan kata sandi'
                                  : 'Sembunyikan kata sandi',
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.length < 6) {
                              return 'Kata sandi minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('register_confirm_password_field'),
                          controller: _confirmPasswordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleRegister(),
                          decoration: const InputDecoration(
                            labelText: 'Konfirmasi Kata Sandi',
                            prefixIcon: Icon(Icons.lock_reset_outlined),
                          ),
                          validator: (val) {
                            if (val != _passwordController.text) {
                              return 'Konfirmasi kata sandi tidak sama';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            key: const Key('register_submit_button'),
                            onPressed: auth.isLoading ? null : _handleRegister,
                            child: auth.isLoading
                                ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text('Mendaftarkan akun...'),
                                    ],
                                  )
                                : const Text('Buat Akun Pasien'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: auth.isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: Text(
                            'Sudah punya akun? Kembali ke Masuk',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFF5EEAD4)
                                  : SehatKuColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
