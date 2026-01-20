import 'package:flutter/material.dart';

class TermsOfServiceView extends StatelessWidget {
  const TermsOfServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Terms of Service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
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
              'By accessing and using ThoughtVault, you accept and agree to be bound by the terms and provision of this agreement.\n\n'
              '2. Use License\n\n'
              'Permission is granted to temporarily download one copy of the materials (information or software) on ThoughtVault for personal, non-commercial transitory viewing only.\n\n'
              '3. Disclaimer\n\n'
              'The materials on ThoughtVault are provided "as is". ThoughtVault makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties.\n\n'
              '4. Limitations\n\n'
              'In no event shall ThoughtVault be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on ThoughtVault.\n\n'
              '5. Governing Law\n\n'
              'Any claim relating to ThoughtVault shall be governed by the laws of the State of California without regard to its conflict of law provisions.',
              style: TextStyle(height: 1.5, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
