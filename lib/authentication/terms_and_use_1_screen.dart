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
                    style: TextStyle(color: Colors.black.withValues(alpha: 0.6)),
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
                        child: Text('''1. Acceptance of Terms

Welcome to WeFix Shop App ("App"), operated by WeFix ("we", "us", or "our"). By accessing or using our App to provide your services, you agree to comply with and be bound by these Terms of Use ("Terms"). If you do not agree, please do not use the App.

By continuing to use the App, you acknowledge that you are at least 18 years old and legally competent to enter into a contract under the Indian Contract Act, 1872.

---

2. Service Commission

By registering as a service provider on our platform, you agree that WeFix shall deduct a flat 20% commission on the total value of each service request completed through the App. This commission is non-negotiable and will be deducted from your earnings or billed to you as per our payment cycle.

---

3. Banner Advertisement Services

We offer promotional banner advertisement spaces within the WeFix user app to help you grow your business. The advertising fees are structured as follows:
- Weekly Plan: ₹2,000 to ₹3,000 per week.
- Monthly Plan: ₹8,000 to ₹10,000 per month.
Prices may vary based on slot availability and promotional offers. Advertisement fees must be paid in advance.

---

4. Use of the App

You agree to use the App only for lawful purposes and in accordance with these Terms. You shall not:
- Use the App for any illegal or unauthorized purpose.
- Attempt to hack, reverse engineer, or disrupt the App’s functionality.
- Bypass our platform to fulfill service requests offline to avoid commission.

---

5. Accounts and Registration

When you create an account, you agree to provide accurate and complete information, including valid GSTIN and KYC details if applicable under Indian law. You are responsible for maintaining the confidentiality of your login credentials.

---

6. Governing Law and Dispute Resolution

These Terms shall be governed by and interpreted in accordance with the laws of India. Any disputes arising out of or relating to these Terms shall be subject to the exclusive jurisdiction of the courts in India.

---

7. Contact Us

If you have any questions about these Terms, please contact us at:
📧 wefix.info25@gmail.com
📞 +91 861 838 0961''', style: TextStyle(fontSize: 15, height: 1.5)),
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
                            children: [
                              const Expanded(
                                child: Text(
                                  'Terms of Use',
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
                            'I agree to the Terms of Use and related service conditions.',
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.7),
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
