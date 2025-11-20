import 'package:flutter/material.dart';
import 'package:wefix_shop/authentication/register_new_shop_screen.dart';
import 'package:wefix_shop/core/constants/app_colors.dart';
import 'package:wefix_shop/core/services/auth_service.dart';

class PrivacyAndPolicy extends StatefulWidget {
  static const String routeName = '/privacy';
  final bool returnToDashboard;

  const PrivacyAndPolicy({super.key, this.returnToDashboard = false});

  @override
  State<PrivacyAndPolicy> createState() => _PrivacyAndPolicyState();
}

class _PrivacyAndPolicyState extends State<PrivacyAndPolicy> {
  bool _showConsent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // MAIN BODY
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  const Text(
                    'Privacy & Policy',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Last updated: 23 September 2025',
                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
                  ),

                  const SizedBox(height: 12),

                  // SCROLLABLE WHITE CONTAINER
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const SingleChildScrollView(
                        child: Text('''1. Introduction

Welcome to [Your App Name] ("App"), operated by [Your Company Name] ("we", "us", or "our"). This Privacy Policy explains how we collect, use, and protect your personal information when you use our App and related services.

By using our App, you agree to the collection and use of your data in accordance with this Privacy Policy.

---

2. Information We Collect

We may collect the following types of information:
- **Personal Information**: Name, email address, phone number, or other identifiers you provide during registration or communication.
- **Usage Data**: Information about how you interact with our App, such as pages viewed, time spent, and navigation patterns.
- **Device Information**: Device model, operating system, unique device identifiers, and IP address.
- **Location Data** (if applicable): Only when you grant permission through your device settings.

---

3. How We Use Your Information

We use your information to:
- Provide, maintain, and improve our services.
- Personalize user experience and deliver relevant content.
- Communicate important updates, promotions, or security alerts.
- Detect, prevent, and address fraud or technical issues.
- Comply with legal obligations.

We do **not** sell or rent your personal data to third parties.

---

4. Data Storage and Security

We implement industry-standard security measures to protect your data. However, no online service is completely secure, and we cannot guarantee absolute data protection.

Your data is stored securely on cloud servers or service providers that comply with applicable privacy regulations.

---

5. Sharing of Information

We may share your information only in the following cases:
- With trusted third-party service providers who assist in operating our App.
- To comply with legal obligations.
- To protect our rights or prevent fraud.

---

6. Cookies and Tracking Technologies

We may use cookies or similar technologies to improve user experience, analyze trends, and understand usage patterns.

---

7. Your Data Rights

You may have the right to:
- Access your data
- Request correction or deletion
- Withdraw consent
- Request data copy (portability)

---

8. Third-Party Links

We are not responsible for the privacy policies of external third-party sites.

---

9. Children’s Privacy

We do not knowingly collect data from children under 13.

---

10. Updates

This Privacy Policy may be updated. Continued use = acceptance.

---

11. Contact Us

Email: support@[yourappname].com
Phone: +91-XXXXXXXXXX
''', style: TextStyle(fontSize: 15, height: 1.5)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // FIXED BOTTOM BUTTONS (Only if not returning to dashboard)
                  if (!widget.returnToDashboard)
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
                                backgroundColor: AppColors.error,
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

                  const SizedBox(height: 8),
                ],
              ),
            ),

            // CONSENT POPUP
            if (_showConsent) ...[
              Positioned.fill(child: Container(color: Colors.black12)),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Material(
                    elevation: 6,
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Terms and Conditions',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
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
                            'I agree to the Privacy Policy and related service conditions.',
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
                                              'privacy_done': true,
                                            });
                                      } catch (_) {}

                                      if (!mounted) return;

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const RegisterNewShopScreen(),
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
