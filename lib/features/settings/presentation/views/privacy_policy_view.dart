import 'package:flutter/material.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Last updated: January 20, 2026',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24),
            Text(
              '1. Introduction\n\n'
              'Welcome to ThoughtVault. We respect your privacy and are committed to protecting your personal data.\n\n'
              '2. Data We Collect\n\n'
              'We collect minimal personal information necessary to provide our services, such as your email address when you create an account.\n\n'
              '3. How We Use Your Data\n\n'
              'We use your data to manage your account, sync your favorite quotes, and improve your experience.\n\n'
              '4. Data Security\n\n'
              'We implement appropriate security measures to protect your personal data from unauthorized access.\n\n'
              '5. Contact Us\n\n'
              'If you have any questions about this Privacy Policy, please contact us at support@thoughtvault.app.',
              style: TextStyle(height: 1.5, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
