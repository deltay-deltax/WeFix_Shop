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
    final Widget actionsSection = widget.returnToDashboard
        ? const SizedBox.shrink()
        : Column(
            children: [
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
                          backgroundColor: const Color(0xFF6F8A53),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        onPressed: () => setState(() => _showConsent = true),
                        label: const Text('Agree'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.cancel, color: Colors.black87),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE6F0D6),
                          foregroundColor: const Color(0xFF6F8A53),
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
          );

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
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
                  if (!widget.returnToDashboard) ...[
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
                    const SizedBox(height: 12),
                  ],
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('''1. Introduction

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
- With trusted third-party service providers who assist in operating our App (e.g., payment gateways, analytics).
- To comply with legal obligations or respond to lawful requests.
- To protect our rights, prevent fraud, or ensure safety.

---

6. Cookies and Tracking Technologies

We may use cookies or similar technologies to improve user experience, analyze trends, and understand how users interact with the App. You can manage cookie preferences through your device or browser settings.

---

7. Your Data Rights

Depending on your jurisdiction, you may have the right to:
- Access the data we hold about you.
- Request correction or deletion of your data.
- Withdraw consent to data processing.
- Request a copy of your data (data portability).

To exercise these rights, please contact us using the details below.

---

8. Third-Party Links and Services

Our App may contain links to external websites or services. We are not responsible for the privacy practices or content of those third parties. Please review their privacy policies separately.

---

9. Children’s Privacy

We do not knowingly collect data from children under 13 (or the applicable age in your region). If you believe we have collected data from a child, contact us immediately to delete it.

---

10. Updates to This Policy

We may update this Privacy Policy from time to time. Changes will be reflected by updating the “Last Updated” date. Continued use of our App signifies acceptance of the updated policy.

---

11. Contact Us

If you have any questions or concerns about this Privacy Policy, please reach out to us at:

📧 Email: support@[yourappname].com  
📞 Phone: +91-XXXXXXXXXX  
📍 Address: [Your Company Address]

Thank you for trusting [Your App Name] with your information.
''', style: TextStyle(fontSize: 15, height: 1.5)),
                  ),
                ],
              ),
            ),
            if (_showConsent) ...[
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
                            mainAxisAlignment:
                                MainAxisAlignment.center, // Changed to center
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
                                      Navigator.of(context).push(
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
