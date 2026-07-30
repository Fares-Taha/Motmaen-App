// profile_screen.dart - FIXED with user data isolation (design unchanged)
import 'package:flutter/material.dart';
import 'package:motmaen/services/user_service.dart';
import 'package:motmaen/services/auth_service.dart';
import 'package:motmaen/services/image_picker_service.dart';
import 'dart:io';
import 'app_settings_screen.dart';
import 'emergency_contact_screen.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'about_screen.dart';
import 'medical_information_screen.dart';
import 'help_support_screen.dart';
import 'package:motmaen/models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  final ImagePickerService _imagePickerService = ImagePickerService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    await _userService.loadCurrentUser();
    setState(() {
      _isLoading = false;
    });
  }

  void _refreshProfile() {
    setState(() {
      _isLoading = true;
    });
    _loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    userProfile: _userService.currentUser!,
                    onProfileUpdated: _refreshProfile,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userService.currentUser == null
              ? _buildNoUserFound()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 10),
                      _buildProfileOptions(),
                      const SizedBox(height: 10),
                      _buildMedicalInfo(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildNoUserFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No User Profile Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please complete your profile setup',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SignupScreen()),
                (route) => false,
              );
            },
            child: const Text('Complete Profile Setup'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final user = _userService.currentUser!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _changeProfilePhoto,
              child: Stack(
                children: [
                  _buildProfileAvatar(user),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        color: Color(0xFF28BAA8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProfileStat('Age', '${user.age}'),
                _buildProfileStat('Weight', '${user.weight} kg'),
                _buildProfileStat('Height', '${user.height} cm'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildProfileStat('Target Glucose', '${user.targetGlucoseMin}-${user.targetGlucoseMax} mg/dL'),
                _buildProfileStat('Daily Calories', '${user.dailyCaloriesTarget} kcal'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(UserProfile user) {
    if (user.profilePhotoPath != null && user.profilePhotoPath!.isNotEmpty) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: FileImage(File(user.profilePhotoPath!)),
      );
    } else {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Color(0xFF28BAA8),
        child: Icon(
          Icons.person,
          size: 50,
          color: Colors.white,
        ),
      );
    }
  }

  Widget _buildProfileStat(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMedicalInfo() {
    final user = _userService.currentUser!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medical Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (user.medicalConditions != null && user.medicalConditions!.isNotEmpty)
              _buildInfoRow('Conditions', user.medicalConditions!),
            if (user.medications != null && user.medications!.isNotEmpty)
              _buildInfoRow('Medications', user.medications!),
            if (user.allergies != null && user.allergies!.isNotEmpty)
              _buildInfoRow('Allergies', user.allergies!),
            if (user.bloodType != null && user.bloodType!.isNotEmpty)
              _buildInfoRow('Blood Type', user.bloodType!),
            if (user.insuranceInfo != null && user.insuranceInfo!.isNotEmpty)
              _buildInfoRow('Insurance', user.insuranceInfo!),
            if (user.doctorName != null && user.doctorName!.isNotEmpty)
              _buildInfoRow('Doctor', user.doctorName!),
            if (user.doctorPhone != null && user.doctorPhone!.isNotEmpty)
              _buildInfoRow('Doctor Phone', user.doctorPhone!),
            if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
              _buildInfoRow('Phone', user.phoneNumber!),
            if (user.emergencyContact != null && user.emergencyContact!.isNotEmpty)
              _buildInfoRow('Emergency Contact', user.emergencyContact!),
            _buildInfoRow('Member Since', _formatDate(user.memberSince)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions() {
    return Card(
      child: Column(
        children: [
          _buildProfileOption(
            'Edit Profile',
            Icons.edit,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(
                    userProfile: _userService.currentUser!,
                    onProfileUpdated: _refreshProfile,
                  ),
                ),
              );
            },
          ),
          _buildProfileOption(
            'Medical Information',
            Icons.medical_information,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MedicalInformationScreen(
                    onMedicalInfoUpdated: _refreshProfile,
                  ),
                ),
              );
            },
          ),
          _buildProfileOption(
            'Emergency Contacts',
            Icons.emergency,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EmergencyContactScreen()),
              );
            },
          ),
          _buildProfileOption(
            'App Settings',
            Icons.settings,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppSettingsScreen()),
              );
            },
          ),
          _buildProfileOption(
            'Help & Support',
            Icons.help_outline,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
              );
            },
          ),
          _buildProfileOption(
            'About Motmaen',
            Icons.info_outline,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
          _buildProfileOption(
            'Logout',
            Icons.logout,
            _logout,
            isLogout: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(String title, IconData icon, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : Color(0xFF28BAA8),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : null,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _changeProfilePhoto() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhotoWithCamera();
              },
            ),
            if (_userService.currentUser?.profilePhotoPath != null &&
                _userService.currentUser!.profilePhotoPath!.isNotEmpty)
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'Remove Photo',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePhoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final File? image = await _imagePickerService.pickImageFromGallery();
      if (image != null) {
        await _updateProfilePhoto(image.path);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _takePhotoWithCamera() async {
    try {
      final File? photo = await _imagePickerService.takePhotoWithCamera();
      if (photo != null) {
        await _updateProfilePhoto(photo.path);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to take photo: $e');
    }
  }

  Future<void> _updateProfilePhoto(String imagePath) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedUser = _userService.currentUser!.copyWith(
        profilePhotoPath: imagePath,
      );
      
      final success = await _userService.updateUserProfile(updatedUser);
      if (success) {
        await _userService.loadCurrentUser();
        _showSuccessSnackBar('Profile photo updated successfully');
      } else {
        _showErrorSnackBar('Failed to update profile photo');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update profile photo: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeProfilePhoto() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedUser = _userService.currentUser!.copyWith(
        profilePhotoPath: '',
      );
      
      final success = await _userService.updateUserProfile(updatedUser);
      if (success) {
        await _userService.loadCurrentUser();
        _showSuccessSnackBar('Profile photo removed');
      } else {
        _showErrorSnackBar('Failed to remove profile photo');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to remove profile photo: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performLogout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.logout();
      _userService.clearUserData();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during logout: $e'),
          backgroundColor: Colors.red,
        ),
      );
      
      setState(() {
        _isLoading = false;
      });
    }
  }
}