import 'package:flutter/material.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              'Welcome to ThoughtVault ("we", "our", or "us"). We are committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our mobile application.\n\n'
              '2. Information We Collect\n\n'
              '• Personal Information: When you create an account, we collect your email address and name.\n'
              '• Usage Data: We may collect information about how you interact with our app to improve our services.\n'
              '• Push Notifications: We may request to send you push notifications regarding your "Quote of the Day". You can opt-out at any time in settings.\n\n'
              '3. How We Use Your Information\n\n'
              'We use the information we collect to:\n'
              '• Provide and maintain our service.\n'
              '• Personalize your experience.\n'
              '• Sync your favorite quotes across devices.\n'
              '• Communicate with you regarding updates or support.\n\n'
              '4. Data Security\n\n'
              'The security of your data is important to us. We use industry-standard encryption and security measures to protect your personal information.\n\n'
              '5. Your Data Rights\n\n'
              'You have the right to access, update, or delete your personal information. You can do this within the app or by contacting us.\n\n'
              '6. Contact Us\n\n'
              'If you have any questions about this Privacy Policy, please contact us at support@thoughtvault.app.',
              style: TextStyle(height: 1.5, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
