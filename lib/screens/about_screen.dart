// about_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Motmaen'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildAppInfoCard(),
            const SizedBox(height: 10),
            _buildFeaturesCard(),
            const SizedBox(height: 10),
            _buildTeamCard(),
            const SizedBox(height: 10),
            _buildLegalCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Image.asset("assets/images/icon.png", width: 120, height: 120,),
            const SizedBox(height: 16),
            const Text(
              'Motmaen',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF28BAA8),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your Trusted Diabetes Companion',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Version ${_packageInfo.version} (Build ${_packageInfo.buildNumber})',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              '© 2024 Motmaen. All rights reserved.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Our Mission',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Motmaen is dedicated to empowering individuals with diabetes to take control of their health through innovative technology and personalized insights.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            const Text(
              'Key Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildFeatureItem('Glucose Tracking', 'Monitor and track your blood sugar levels'),
            _buildFeatureItem('AI Food Scanning', 'Get instant GI analysis using camera'),
            _buildFeatureItem('Meal Logging', 'Track your nutrition and calories'),
            _buildFeatureItem('Health Reports', 'Detailed analytics and trends'),
            _buildFeatureItem('Emergency Ready', 'Quick access to medical information'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return ListTile(
      leading: const Icon(Icons.check_circle, color: Colors.green, size: 20),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(description),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildTeamCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Development Team',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Motmaen is developed by a dedicated team of healthcare professionals, developers, and designers committed to improving diabetes management.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildTeamMember('Dr. Ahmed Hassan', 'Medical Advisor'),
            _buildTeamMember('Sarah Mohamed', 'Lead Developer'),
            _buildTeamMember('Omar Khaled', 'Product Designer'),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMember(String name, String role) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: Text(
          name.split(' ').map((e) => e[0]).take(2).join(),
          style: const TextStyle(color: Colors.blue),
        ),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(role),
    );
  }

  Widget _buildLegalCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Legal & Privacy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildLegalOption('Privacy Policy', _launchPrivacyPolicy),
            _buildLegalOption('Terms of Service', _launchTerms),
            _buildLegalOption('Open Source Licenses', _showLicenses),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalOption(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Future<void> _launchPrivacyPolicy() async {
    final url = Uri.parse('https://motmaen.com/privacy');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchTerms() async {
    final url = Uri.parse('https://motmaen.com/terms');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: 'Motmaen',
      applicationVersion: _packageInfo.version,
    );
  }
}