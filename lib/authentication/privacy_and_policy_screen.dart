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

Welcome to the WeFix Shop App ("App"). This Privacy Policy explains how WeFix ("we", "us", or "our") collects, uses, and protects your personal and business information in compliance with the Information Technology Act, 2000 and applicable Indian laws.

By using our App, you consent to the data practices described in this policy.

---

2. Information We Collect

We may collect the following types of information:
- **Personal & Business Information**: Name, business name, address, email, phone number, KYC documents, and GST details necessary for vendor onboarding.
- **Financial Information**: Bank account details or UPI IDs for processing payouts and managing the 20% service commission.
- **Service & Usage Data**: Details of services provided, reviews, and interaction logs.
- **Device & Location Data**: Your live location to assign nearby service requests, operating system, and IP address.

---

3. How We Use Your Information

We use your information to:
- Onboard you as a verified service provider.
- Manage and process service requests and deduct the agreed 20% commission per service.
- Process payments for banner advertisements (₹2,000-₹3,000/week or ₹8,000-₹10,000/month).
- Ensure safety, resolve disputes, and comply with legal obligations under Indian law.

We do **not** sell or rent your personal data to third parties.

---

4. Data Sharing and Disclosure

We may share your information only with:
- Customers (Users) booking your services.
- Trusted third-party payment gateways (e.g., Razorpay, PhonePe) for processing transactions.
- Law enforcement agencies if required under Indian law.

---

5. Data Security

We implement robust, industry-standard security measures to protect your data. However, no electronic transmission or storage is 100% secure.

---

6. Your Rights

You have the right to access, correct, or request deletion of your data, subject to legal and accounting retention requirements in India.

---

7. Updates

This Privacy Policy may be updated periodically. Your continued use of the App signifies your acceptance of any changes.

---

8. Contact Us

For any privacy-related concerns or grievances, please contact our Grievance Officer at:
Email: support@wefix.com
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
