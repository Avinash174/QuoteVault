import 'package:flutter/material.dart';

class TermsOfServiceView extends StatelessWidget {
  const TermsOfServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Terms of Service')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Last updated: January 20, 2026',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24),
            Text(
              '1. Acceptance of Terms\n\n'
              'By downloading or using ThoughtVault, you agree to these Terms of Service. If you do not agree, please do not use the app.\n\n'
              '2. Use of Service\n\n'
              'ThoughtVault provides a platform for discovering, creating, and sharing quotes. You agree to use this service for lawful purposes only.\n\n'
              '3. User Accounts\n\n'
              'You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.\n\n'
              '4. Intellectual Property\n\n'
              'All content provided in ThoughtVault, including quotes fetched from APIs, is the property of their respective owners. User-created quotes remain the property of the creator, but by posting, you grant us a license to display them.\n\n'
              '5. Disclaimer of Warranties\n\n'
              'ThoughtVault is provided "as is" without any warranties, express or implied. We do not guarantee that the service will be uninterrupted or error-free.\n\n'
              '6. Limitation of Liability\n\n'
              'In no event shall ThoughtVault be liable for any damages arising out of the use or inability to use the service.\n\n'
              '7. Changes to Terms\n\n'
              'We reserve the right to modify these terms at any time. Your continued use of the app constitutes acceptance of the updated terms.',
              style: TextStyle(height: 1.5, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
