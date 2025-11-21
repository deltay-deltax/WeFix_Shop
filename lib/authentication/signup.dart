import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../widgets/auth_input_field.dart';
import 'terms_and_use_1_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Basic info
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  // Auth
  final passCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  bool _emailLoading = false;
  bool _googleLoading = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passCtrl.dispose();
    confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Create an account so you can explore all the\nexisting jobs',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 36),
                // Signup fields
                InputField(
                  hint: 'Full Name',
                  controller: nameCtrl,
                  fillColor: Colors.white,
                ),
                const SizedBox(height: 12),
                InputField(
                  hint: 'Email',
                  controller: emailCtrl,

                  fillColor: Colors.white,
                ),
                const SizedBox(height: 12),
                // Phone number with +91 prefix
                InputField(
                  hint: 'Phone number',
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  fillColor: Colors.white,
                  prefix: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 15,
                    ),
                    child: Text(
                      '+91',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                const SizedBox(height: 8),
                InputField(
                  hint: 'Password',
                  controller: passCtrl,
                  obscureText: true,
                  fillColor: Colors.white,
                ),
                const SizedBox(height: 12),
                InputField(
                  hint: 'Confirm Password',
                  controller: confirmPassCtrl,
                  obscureText: true,
                  fillColor: Colors.white,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2.5,
                    ),
                    onPressed: _emailLoading || _googleLoading
                        ? null
                        : () async {
                            if (nameCtrl.text.trim().isEmpty ||
                                emailCtrl.text.trim().isEmpty ||
                                phoneCtrl.text.trim().isEmpty ||
                                passCtrl.text.isEmpty ||
                                confirmPassCtrl.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Fill all fields'),
                                ),
                              );
                              return;
                            }
                            if (passCtrl.text != confirmPassCtrl.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Passwords do not match'),
                                ),
                              );
                              return;
                            }
                            setState(() => _emailLoading = true);
                            try {
                              final rawPhone = phoneCtrl.text.trim();
                              final normalizedPhone = rawPhone.startsWith('+')
                                  ? rawPhone
                                  : '+91 ${rawPhone}';
                              await AuthService.instance.signUpWithEmail(
                                email: emailCtrl.text.trim(),
                                password: passCtrl.text,
                                role: 'shop',
                                extra: {
                                  'name': nameCtrl.text.trim(),
                                  'phone': normalizedPhone,
                                },
                              );
                              if (!mounted) return;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const TermsAndUse1Screen(),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text('$e')));
                            } finally {
                              if (mounted)
                                setState(() => _emailLoading = false);
                            }
                          },
                    child: _emailLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Sign up',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // Continue with Google (only)
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _emailLoading || _googleLoading
                        ? null
                        : () async {
                            setState(() => _googleLoading = true);
                            try {
                              await AuthService.instance.signInWithGoogle(
                                role: 'shop',
                              );
                              if (!mounted) return;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const TermsAndUse1Screen(),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text('$e')));
                            } finally {
                              if (mounted)
                                setState(() => _googleLoading = false);
                            }
                          },
                    child: _googleLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/icon/google_g.svg',
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Continue with Google',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(AppRoutes.login);
                    },
                    child: const Text(
                      "Already have an account",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
