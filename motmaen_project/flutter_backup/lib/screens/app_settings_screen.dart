// app_settings_screen.dart - Updated with combined data management card
import 'package:flutter/material.dart';
import 'package:motmaen/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:motmaen/services/database_helper.dart';
import 'package:motmaen/services/auth_service.dart';
import 'package:motmaen/services/user_service.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _notificationsEnabled = true;
  String _language = 'English';
  String _glucoseUnit = 'mg/dL';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _language = prefs.getString('language') ?? 'English';
      _glucoseUnit = prefs.getString('glucose_unit') ?? 'mg/dL';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Column(
              children: [
                _buildSettingSwitch(
                  'Push Notifications',
                  'Receive reminders and alerts',
                  _notificationsEnabled,
                  (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    _saveSetting('notifications', value);
                  },
                ),
                _buildThemeSwitch(
                  'Dark Mode',
                  'Use dark theme',
                  themeProvider.isDarkMode,
                  (value) {
                    themeProvider.toggleDarkMode(value);
                    _showThemeChangeSnackbar(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                _buildSettingDropdown(
                  'Language',
                  _language,
                  ['English', 'Arabic', 'French', 'Spanish'],
                  (value) {
                    setState(() {
                      _language = value!;
                    });
                    _saveSetting('language', value);
                  },
                ),
                _buildSettingDropdown(
                  'Glucose Unit',
                  _glucoseUnit,
                  ['mg/dL', 'mmol/L'],
                  (value) {
                    setState(() {
                      _glucoseUnit = value!;
                    });
                    _saveSetting('glucose_unit', value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Combined Data Management Card
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Data Management',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildSettingButton(
                  'Data Backup',
                  'Backup your data to cloud',
                  Icons.backup,
                  Colors.blue,
                  () {
                    _showComingSoonDialog('Data Backup');
                  },
                ),
                _buildSettingButton(
                  'Data Export',
                  'Export your health data as file',
                  Icons.import_export,
                  Colors.green,
                  () {
                    _showComingSoonDialog('Data Export');
                  },
                ),
                _buildSettingButton(
                  'Clear Data',
                  'Delete all app data and close app',
                  Icons.delete_forever,
                  Colors.orange,
                  _clearData,
                ),
                _buildSettingButton(
                  'Delete Account',
                  'Permanently delete your account and all data',
                  Icons.person_remove,
                  Colors.red,
                  _deleteAccount,
                ),
                const SizedBox(height: 20,)
              ],
            ),
          ),
          // Theme Preview Section
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme Preview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _buildThemePreview(context, themeProvider.isDarkMode),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSwitch(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      inactiveThumbColor: Theme.of(context).colorScheme.primary,
      activeColor: Theme.of(context).colorScheme.primary,
      value: value,
      onChanged: onChanged,
      secondary: Icon(
        value ? Icons.dark_mode : Icons.light_mode,
        color: Theme.of(context).colorScheme.primary,
        size: 40,
      ),
    );
  }

  Widget _buildSettingSwitch(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      inactiveThumbColor: Theme.of(context).colorScheme.primary,
      activeColor: Theme.of(context).colorScheme.primary,
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSettingDropdown(String title, String value, List<String> options, ValueChanged<String?> onChanged) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingButton(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color == Colors.red || color == Colors.orange ? Colors.red : null,
          fontWeight: color == Colors.red || color == Colors.orange ? FontWeight.bold : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildThemePreview(BuildContext context, bool isDarkMode) {
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bloodtype,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sample Glucose Reading',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '120 $_glucoseUnit • 2 hours after meal',
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: textColor.withOpacity(0.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Theme:',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  isDarkMode ? 'Dark Mode' : 'Light Mode',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showThemeChangeSnackbar(bool isDarkMode) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              isDarkMode ? 'Dark mode enabled' : 'Light mode enabled',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$feature Coming Soon'),
        content: Text('The $feature feature will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _clearData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This action will:'),
            SizedBox(height: 8),
            Text('• Delete all your personal data'),
            Text('• Remove all glucose records'),
            Text('• Remove all meal records'),
            Text('• Clear app preferences'),
            Text('• Close the application'),
            SizedBox(height: 16),
            Text(
              'This action cannot be undone!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performClearData();
            },
            child: const Text(
              'Clear All Data',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This will permanently:'),
            SizedBox(height: 8),
            Text('• Delete your user account'),
            Text('• Remove all your personal information'),
            Text('• Delete all glucose records'),
            Text('• Delete all meal records'),
            Text('• Delete all emergency contacts'),
            Text('• Remove all app settings'),
            SizedBox(height: 16),
            Text(
              'This action is irreversible and cannot be undone!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You will be logged out and returned to the login screen.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _confirmDeleteAccount();
            },
            child: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final TextEditingController confirmController = TextEditingController();
    bool isDeleteEnabled = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Confirm Account Deletion'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Are you absolutely sure you want to delete your account?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Type "DELETE" in the box below to confirm:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Type DELETE here',
                  ),
                  onChanged: (value) {
                    setState(() {
                      isDeleteEnabled = value.trim().toUpperCase() == 'DELETE';
                    });
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  isDeleteEnabled ? '✓ Confirmation text matches' : 'Type DELETE to confirm',
                  style: TextStyle(
                    color: isDeleteEnabled ? Colors.green : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isDeleteEnabled
                    ? () {
                        Navigator.pop(context);
                        _performDeleteAccount();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete Account'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _performDeleteAccount() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          title: Text('Deleting Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Please wait while we delete your account...'),
            ],
          ),
        ),
      );

      final userService = UserService();
      final authService = AuthService();
      final dbHelper = DatabaseHelper();
      
      // Get current user ID
      final currentUserId = await authService.getCurrentUserId();
      
      if (currentUserId != null) {
        // Delete ALL user data including related records using the new method
        await dbHelper.deleteUserData(currentUserId);
      }
      
      // Clear all app data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Logout
      await authService.logout();
      userService.clearUserData();

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Show success message and navigate to login
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Account Deleted'),
          content: const Text('Your account and all associated data have been permanently deleted.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToLogin();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to delete account: $e'),
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

  void _navigateToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _performClearData() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          title: Text('Clearing Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Please wait while we clear all your data...'),
            ],
          ),
        ),
      );

      final authService = AuthService();
      final userService = UserService();
      final dbHelper = DatabaseHelper();
      
      // Get current user ID
      final currentUserId = await authService.getCurrentUserId();
      
      if (currentUserId != null) {
        // Delete user-specific data only
        await dbHelper.deleteUserData(currentUserId);
      }
      
      // Clear app preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Logout
      await authService.logout();
      userService.clearUserData();

      if (!mounted) return;
      Navigator.pop(context);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Data Cleared Successfully'),
          content: const Text('All your data has been cleared. The app will now close.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _closeApp();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to clear data: $e'),
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

  void _closeApp() {
    SystemNavigator.pop();
  }
}