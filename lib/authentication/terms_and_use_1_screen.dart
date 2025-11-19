import 'package:flutter/material.dart';
import 'package:wefix_shop/core/constants/app_colors.dart';
import 'package:wefix_shop/core/services/auth_service.dart';
import 'privacy_and_policy_screen.dart';

class TermsAndUse1Screen extends StatefulWidget {
  final bool returnToDashboard;
  const TermsAndUse1Screen({super.key, this.returnToDashboard = false});

  @override
  State<TermsAndUse1Screen> createState() => _TermsAndUse1ScreenState();
}

class _TermsAndUse1ScreenState extends State<TermsAndUse1Screen> {
  bool _showConsent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // Background content stays visible
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Terms of Use',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Last updated: 23 September 2025',
                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const SingleChildScrollView(
                        child: Text(
                          '''1. Acceptance of Terms

Welcome to [Your App Name] ("App"), operated by [Your Company Name] ("we", "us", or "our"). By accessing or using our App, you agree to comply with and be bound by these Terms of Use ("Terms"). If you do not agree, please do not use the App.

By continuing to use the App, you acknowledge that you are at least 18 years old or have the consent of a parent or guardian to use the Services.

---

2. Changes to Terms

We may modify or update these Terms from time to time. When we do, the updated date at the top of this page will be revised. Continued use of the App after changes means you accept those changes.

---

3. Use of the App

You agree to use the App only for lawful purposes and in accordance with these Terms. You shall not:
- Use the App for any illegal or unauthorized purpose.
- Attempt to hack, reverse engineer, or disrupt the App’s functionality.
- Use automated systems (such as bots or scrapers) to access data from the App.

---

4. Accounts and Registration

When you create an account, you agree to provide accurate and complete information. You are responsible for maintaining the confidentiality of your login credentials and for all activities that occur under your account.

If we suspect unauthorized access or misuse, we reserve the right to suspend or terminate your account immediately.

---

5. Intellectual Property Rights

All content, trademarks, logos, and design elements available through the App are owned or licensed by [Your Company Name]. You may not reproduce, distribute, or modify any part of the App without prior written consent.

---

6. Privacy Policy

Your use of the App is also governed by our Privacy Policy, which explains how we collect, use, and protect your personal data. Please review it carefully before using the App.

---

7. Disclaimer of Warranties

The App and all related services are provided on an “as-is” and “as-available” basis. We do not guarantee uninterrupted or error-free service. You use the App at your own risk.

---

8. Limitation of Liability

To the fullest extent permitted by law, [Your Company Name] shall not be liable for any direct, indirect, incidental, or consequential damages arising out of your use or inability to use the App.

---

9. Termination

We reserve the right to suspend or terminate your access to the App at any time, without notice, for conduct that violates these Terms or is harmful to other users or us.

---

10. Governing Law

These Terms shall be governed and interpreted in accordance with the laws of [Your Country/State], without regard to its conflict of law provisions.

---

11. Contact Us

If you have any questions about these Terms, please contact us at:
📧 support@[yourappname].com
📞 +91-XXXXXXXXXX

Thank you for using [Your App Name].''',
                          style: TextStyle(fontSize: 15, height: 1.5),
                        ),
                      ),
                    ),
                  ),
                  if (!widget.returnToDashboard) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              onPressed: () =>
                                  setState(() => _showConsent = true),
                              label: const Text('Agree'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.cancel,
                                color: Colors.white,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF5252),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                              label: const Text('Disagree'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (_showConsent) ...[
              // Faint backdrop without fully dimming
              Positioned.fill(child: Container(color: Colors.black12)),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Terms and Conditions',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () =>
                                    setState(() => _showConsent = false),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'I agree to the iOS, iCloud and Game Center Terms and Conditions and the Apple Privacy Policy.',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 44,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    onPressed: () async {
                                      setState(() => _showConsent = false);
                                      try {
                                        await AuthService.instance
                                            .updateProgress({
                                              'terms_done': true,
                                            });
                                      } catch (_) {}
                                      if (!mounted) return;
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const PrivacyAndPolicy(),
                                        ),
                                      );
                                    },
                                    label: const Text('Agree'),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 44,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(
                                      Icons.cancel,
                                      color: Colors.white,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() => _showConsent = false);
                                      Navigator.of(context).maybePop();
                                    },
                                    label: const Text('Disagree'),
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
              ),
            ],
          ],
        ),
      ),
    );
  }
}
