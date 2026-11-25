import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/clinic_data_provider.dart';
import '../routing/app_router.dart';
import '../theme/sehatku_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final clinic = context.read<ClinicDataProvider>();

    final success = await auth.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (success && auth.currentUser != null) {
      await clinic.applyAuthenticatedUser(auth.currentUser!);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.home,
        (_) => false,
      );
    }
  }

  Future<void> _handleOfflineDemo() async {
    final auth = context.read<AuthProvider>();
    final clinic = context.read<ClinicDataProvider>();
    await auth.enterOfflineDemoSession();
    if (auth.currentUser != null) {
      await clinic.applyAuthenticatedUser(auth.currentUser!);
    }
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.home,
      (_) => false,
    );
  }

  Future<void> _showServerConfigDialog() async {
    final auth = context.read<AuthProvider>();
    final urlCtrl = TextEditingController(text: auth.serverBaseUrl);
    String? testStatus;
    bool isTesting = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Pengaturan Server Auth MySQL'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Masukkan alamat backend PHP yang terhubung ke database sehatku_db. Gunakan 10.0.2.2:8080 untuk emulator Android atau 127.0.0.1:8080 di Web/Desktop.',
                  style: TextStyle(fontSize: 12.5, height: 1.4),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'URL Server Backend',
                    hintText: 'http://127.0.0.1:8080',
                    prefixIcon: Icon(Icons.dns_outlined),
                  ),
                ),
                if (testStatus != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    testStatus!,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: testStatus!.startsWith('Terhubung')
                          ? SehatKuColors.success
                          : SehatKuColors.danger,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isTesting
                  ? null
                  : () async {
                      setDialogState(() {
                        isTesting = true;
                        testStatus = 'Memeriksa koneksi...';
                      });
                      await auth.updateServerBaseUrl(urlCtrl.text);
                      final ok = await auth.checkBackendConnection();
                      if (!ctx.mounted) return;
                      setDialogState(() {
                        isTesting = false;
                        testStatus = ok
                            ? 'Terhubung ke backend PHP dan MySQL sehatku_db.'
                            : 'Gagal terhubung. Pastikan server PHP dan MySQL aktif.';
                      });
                    },
              child: const Text('Uji Koneksi'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Tutup'),
            ),
            ElevatedButton(
              onPressed: () async {
                await auth.updateServerBaseUrl(urlCtrl.text);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
    urlCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final isDarkMode = context.select<ClinicDataProvider, bool>(
      (c) => c.isDarkMode,
    );

    final subtleTextColor = isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF475569);
    final linkColor = isDark
        ? const Color(0xFF5EEAD4)
        : SehatKuColors.primaryDark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: SehatKuColors.primaryDark,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.local_hospital_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SehatKu Klinik',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Pendaftaran dan Rekam Medis',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: subtleTextColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        tooltip: isDarkMode ? 'Mode Terang' : 'Mode Gelap',
                        onPressed: () => context
                            .read<ClinicDataProvider>()
                            .toggleDarkMode(!isDarkMode),
                        icon: Icon(
                          isDarkMode
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Masuk Akun Pasien',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Masuk dengan akun MySQL klinik untuk mengambil antrean poli dan membuka catatan rekam medis.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.45,
                                color: subtleTextColor,
                              ),
                            ),
                            const SizedBox(height: 20),
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
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 18,
                                      color: isDark
                                          ? const Color(0xFFFCA5A5)
                                          : const Color(0xFF991B1B),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
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
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            TextFormField(
                              key: const Key('login_email_field'),
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onChanged: (_) => auth.clearError(),
                              decoration: const InputDecoration(
                                labelText: 'Email Pasien',
                                hintText: 'nama@email.com',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (val) {
                                final text = (val ?? '').trim();
                                if (text.isEmpty || !text.contains('@')) {
                                  return 'Masukkan alamat email yang valid';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              key: const Key('login_password_field'),
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onChanged: (_) => auth.clearError(),
                              onFieldSubmitted: (_) => _handleLogin(),
                              decoration: InputDecoration(
                                labelText: 'Kata Sandi',
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
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                key: const Key('login_submit_button'),
                                onPressed: auth.isLoading ? null : _handleLogin,
                                child: auth.isLoading
                                    ? const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                          Text('Memverifikasi akun...'),
                                        ],
                                      )
                                    : const Text('Masuk ke SehatKu'),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Belum punya akun pasien?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: subtleTextColor,
                                  ),
                                ),
                                TextButton(
                                  key: const Key('goto_register_button'),
                                  onPressed: auth.isLoading
                                      ? null
                                      : () {
                                          auth.clearError();
                                          Navigator.pushNamed(
                                            context,
                                            AppRouter.register,
                                          );
                                        },
                                  child: Text(
                                    'Daftar Sekarang',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: linkColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Server Auth MySQL',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      auth.serverBaseUrl,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: subtleTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _showServerConfigDialog,
                                icon: const Icon(Icons.tune, size: 16),
                                label: const Text('Atur Server'),
                              ),
                            ],
                          ),
                          const Divider(height: 18),
                          SizedBox(
                            height: 44,
                            child: OutlinedButton.icon(
                              key: const Key('login_offline_demo_button'),
                              onPressed: auth.isLoading
                                  ? null
                                  : _handleOfflineDemo,
                              icon: const Icon(
                                Icons.offline_bolt_outlined,
                                size: 18,
                              ),
                              label: const Text(
                                'Masuk Mode Demo Lokal (Tanpa Server)',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
