import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../widgets/custom_button.dart';

class EmailVerifyOTPScreen extends StatefulWidget {
  final String email;
  const EmailVerifyOTPScreen({super.key, required this.email});

  @override
  State<EmailVerifyOTPScreen> createState() => _EmailVerifyOTPScreenState();
}

class _EmailVerifyOTPScreenState extends State<EmailVerifyOTPScreen> {
  final List<TextEditingController> _otp = List.generate(
    6,
    (index) => TextEditingController(),
  );

  String _maskedEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return 'OTP sent to your email';
    final name = parts[0];
    final domain = parts[1];
    final shown = name.length <= 2 ? name : name.substring(0, 2) + '****';
    return 'OTP sent to your email $shown@$domain';
  }

  String _code() => _otp.map((c) => c.text.trim()).join();

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
              'Enter Email OTP',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
            ),
            const SizedBox(height: 12),
            Text(
              _maskedEmail(widget.email),
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
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
                        if (index < _otp.length - 1) {
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
              enabled: true,
              onPressed: () async {
                if (_code().length == 6) {
                  if (context.mounted) Navigator.of(context).pop(true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter 6-digit code')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
