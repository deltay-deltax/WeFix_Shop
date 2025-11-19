import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../widgets/custom_button.dart';

class EnterOTPScreen extends StatefulWidget {
  final String phone;
  const EnterOTPScreen({super.key, required this.phone});

  @override
  State<EnterOTPScreen> createState() => _EnterOTPScreenState();
}

class _EnterOTPScreenState extends State<EnterOTPScreen> {
  final List<TextEditingController> _otp = List.generate(
    6,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    for (final c in _otp) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter OTP',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            ),
            const SizedBox(height: 12),
            Text(
              _maskedPhone(widget.phone),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                6,
                (index) => SizedBox(
                  width: 48,
                  child: TextField(
                    controller: _otp[index],
                    maxLength: 1,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      counterText: '',
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                    onChanged: (val) {
                      if (val.isNotEmpty) {
                        if (index < 5) {
                          FocusScope.of(context).nextFocus();
                        } else {
                          FocusScope.of(context).unfocus();
                        }
                      } else {
                        if (index > 0) {
                          FocusScope.of(context).previousFocus();
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              label: 'Verify OTP',
              onPressed: () {
                final code = _otp.map((c) => c.text.trim()).join();
                if (code.length == 6) {
                  Navigator.of(context).pop<String>(code);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter 6-digit OTP')),
                  );
                }
              },
              enabled: true,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                for (final c in _otp) c.clear();
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  String _maskedPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.length < 4) return 'OTP sent to your mobile number';
    final last2 = digits.substring(digits.length - 2);
    return 'OTP sent to your mobile number **** **** **$last2';
  }
}
