// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'login_screen.dart'; // import _ErrorBanner

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _agree = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms to continue.')),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.signUp(_emailCtrl.text.trim(), _passCtrl.text);
    if (ok && mounted) context.go('/upload');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => context.go('/'),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [AppTheme.goldLight, AppTheme.gold]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.face_retouching_natural,
                            color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Text('DermaMatch',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.deepNavy,
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                Text('Create your account',
                    style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.stars_rounded,
                      color: AppTheme.gold, size: 16),
                  const SizedBox(width: 6),
                  Text('3 free scans included',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.gold,
                        fontWeight: FontWeight.w500,
                      )),
                ]),
                const SizedBox(height: 32),
                if (auth.error != null) _ErrorBanner(auth.error!),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.mail_outline, size: 20),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter your email';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                                _obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 20),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => (v == null || v.length < 6)
                            ? 'Min 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: Icon(Icons.lock_outline, size: 20),
                        ),
                        validator: (v) => v != _passCtrl.text
                            ? 'Passwords do not match'
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _agree,
                      activeColor: AppTheme.gold,
                      onChanged: (v) => setState(() => _agree = v ?? false),
                    ),
                    Expanded(
                        child: Text(
                            'I agree to the Terms of Service & Privacy Policy',
                            style: GoogleFonts.inter(
                                fontSize: 13, color: AppTheme.mutedText))),
                  ],
                ),
                const SizedBox(height: 24),
                GoldButton(
                  text: 'Create Account',
                  isLoading: auth.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account? ",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.mutedText,
                        )),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text('Sign in',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.gold,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
