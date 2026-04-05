import 'package:flutter/material.dart';
import 'package:wefix_shop/core/constants/app_colors.dart';
import 'package:wefix_shop/core/constants/app_routes.dart';

class PublicPrivacyPolicy extends StatelessWidget {
  const PublicPrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Privacy & Policy',
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
Email:wefix.info25@gmail.com
Phone: +91 861 838 0961
''', style: TextStyle(fontSize: 15, height: 1.5)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.termsOfUse,
                    );
                  },
                  child: const Text('Read Terms of Use'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
