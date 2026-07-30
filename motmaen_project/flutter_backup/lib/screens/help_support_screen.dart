// help_support_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHelpCard(),
            const SizedBox(height: 10),
            _buildContactCard(context), // Pass context here
            const SizedBox(height: 10),
            _buildFaqCard(),
            const SizedBox(height: 10),
            _buildResourcesCard(),
          ],
      ),
    ));
  }

  Widget _buildHelpCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Icon(
              Icons.help_center,
              size: 60,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'How can we help you?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Find answers to common questions or get in touch with our support team',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) { // Accept context as parameter
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Support',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactOption(
              Icons.email,
              'Email Support',
              'Send us an email and we\'ll respond within 24 hours',
              () => _launchEmail(),
            ),
            const SizedBox(height: 16),
            _buildContactOption(
              Icons.phone,
              'Phone Support',
              'Call our support line for immediate assistance',
              () => _launchPhone(),
            ),
            const SizedBox(height: 16),
            _buildContactOption(
              Icons.chat,
              'Live Chat',
              'Chat with our support team in real-time',
              () => _launchChat(context), // Pass context here
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildFaqCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFaqItem(
              'How do I add a glucose reading?',
              'Go to Dashboard → Quick Actions → Add Glucose, then enter your reading details.',
            ),
            _buildFaqItem(
              'How accurate is the food scanning feature?',
              'Our AI model is trained on thousands of food images and provides accurate predictions with confidence scores.',
            ),
            _buildFaqItem(
              'Can I export my health data?',
              'Yes, go to App Settings → Data Export to download your data in various formats.',
            ),
            _buildFaqItem(
              'How do I set up emergency contacts?',
              'Navigate to Profile → Emergency Contacts to add and manage your emergency contacts.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(answer),
        ),
      ],
    );
  }

  Widget _buildResourcesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Resources',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildResourceItem(
              'User Guide',
              'Complete guide to using Motmaen features',
            ),
            _buildResourceItem(
              'Diabetes Management Tips',
              'Expert advice for managing diabetes',
            ),
            _buildResourceItem(
              'Nutrition Guide',
              'Healthy eating recommendations',
            ),
            _buildResourceItem(
              'Video Tutorials',
              'Step-by-step video guides',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceItem(String title, String subtitle) {
    return ListTile(
      leading: const Icon(Icons.description, color: Colors.green),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.download, size: 20),
      onTap: () {
        // Handle resource download/view
      },
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@motmaen.com',
      queryParameters: {
        'subject': 'Motmaen App Support',
        'body': 'Hello Motmaen team,\n\nI need help with:',
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneLaunchUri = Uri(
      scheme: 'tel',
      path: '+201234567890',
    );

    if (await canLaunchUrl(phoneLaunchUri)) {
      await launchUrl(phoneLaunchUri);
    }
  }

  void _launchChat(BuildContext context) { // Add context parameter
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Live Chat'),
        content: const Text('Live chat feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}