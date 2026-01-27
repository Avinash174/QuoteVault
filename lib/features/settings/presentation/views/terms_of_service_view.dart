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
              'By downloading, installing, or using ThoughtVault ("the App"), you agree to be bound by these Terms of Service. If you do not agree to these terms, you must not use the App.\n\n'
              '2. Use of Service\n\n'
              'ThoughtVault provides a platform for discovering, organizing, and sharing inspirational quotes. You are granted a limited, non-exclusive, non-transferable license to use the App for personal, non-commercial purposes.\n\n'
              '3. User-Generated Content (Community Quotes)\n\n'
              'You may have the ability to create and share your own quotes within the App. By posting content, you represent that you have the right to do so and grant ThoughtVault a worldwide, royalty-free license to display and distribute this content to other users. We reserve the right to remove any content that violates our community standards or is deemed inappropriate.\n\n'
              '4. Daily Inspiration Notifications\n\n'
              'The App offers a "Daily Inspiration" feature that sends scheduled push notifications. By enabling this feature, you consent to receive these notifications at your selected time. You can manage or disable these notifications at any time in the settings menu.\n\n'
              '5. Advertisements\n\n'
              'ThoughtVault is supported by advertising via Google AdMob. By using the App, you agree to the display of advertisements. We are not responsible for the content of third-party advertisements or the services they promote.\n\n'
              '6. Intellectual Property\n\n'
              'All quotes fetched from third-party APIs (such as ZenQuotes) remain the property of their respective owners. The App\'s interface, design, and original code are the intellectual property of ThoughtVault.\n\n'
              '7. Disclaimer of Warranties\n\n'
              'The App is provided "as is" and "as available" without any warranties of any kind. We do not warrant that the App will meet your requirements or that its operation will be uninterrupted or error-free.\n\n'
              '8. Limitation of Liability\n\n'
              'To the maximum extent permitted by law, ThoughtVault shall not be liable for any indirect, incidental, or consequential damages resulting from your use of the App.\n\n'
              '9. Changes to Terms\n\n'
              'We may update these Terms of Service from time to time. Your continued use of the App after such changes constitutes your acceptance of the new terms.',
              style: TextStyle(height: 1.5, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
