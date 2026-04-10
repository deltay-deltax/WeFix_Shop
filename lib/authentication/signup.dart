import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../widgets/auth_input_field.dart';
import 'terms_and_use_1_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
                    'Shop Registration',
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
                    'Register your shop to start receiving\nservice requests from customers.',
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
                  isPassword: true,
                  fillColor: Colors.white,
                ),
                const SizedBox(height: 12),
                InputField(
                  hint: 'Confirm Password',
                  controller: confirmPassCtrl,
                  isPassword: true,
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
                            } on FirebaseAuthException catch (e) {
                              String msg = 'Registration error';
                              if (e.code == 'email-already-in-use') {
                                msg = 'This email is already registered.';
                              } else if (e.code == 'weak-password') {
                                msg = 'The password is too weak.';
                              } else if (e.code == 'invalid-email') {
                                msg = 'The email address is invalid.';
                              } else if (e.code == 'network-request-failed') {
                                msg = 'Network error. Please check your connection.';
                              } else {
                                msg = e.message ?? 'Sign up failed. Please try again.';
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(msg)),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}')));
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
