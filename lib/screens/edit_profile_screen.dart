// edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:motmaen/models/user_profile.dart';
import 'package:motmaen/services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile userProfile;
  final VoidCallback onProfileUpdated;

  const EditProfileScreen({
    super.key,
    required this.userProfile,
    required this.onProfileUpdated,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _phoneController = TextEditingController();
  final _targetMinController = TextEditingController();
  final _targetMaxController = TextEditingController();
  final _caloriesController = TextEditingController();

  String _selectedGender = 'Male';
  final UserService _userService = UserService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final user = widget.userProfile;
    _fullNameController.text = user.fullName;
    _emailController.text = user.email;
    _ageController.text = user.age.toString();
    _weightController.text = user.weight.toString();
    _heightController.text = user.height.toString();
    _phoneController.text = user.phoneNumber ?? '';
    _targetMinController.text = user.targetGlucoseMin.toString();
    _targetMaxController.text = user.targetGlucoseMax.toString();
    _caloriesController.text = user.dailyCaloriesTarget.toString();
    _selectedGender = user.gender;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildPersonalInfoSection(),
                    const SizedBox(height: 10),
                    _buildTargetsSection(),
                    const SizedBox(height: 15),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTextField(_fullNameController, 'Full Name', 'Enter your full name', isRequired: true),
            const SizedBox(height: 16),
            _buildTextField(_emailController, 'Email', 'Enter your email', isEmail: true, isRequired: true),
            const SizedBox(height: 16),
            _buildTextField(_ageController, 'Age', 'Enter your age', isNumber: true, isRequired: true),
            const SizedBox(height: 16),
            _buildGenderDropdown(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(_weightController, 'Weight (kg)', 'Enter weight', isNumber: true, isRequired: true),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(_heightController, 'Height (cm)', 'Enter height', isNumber: true, isRequired: true),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(_phoneController, 'Phone Number (Optional)', 'Enter phone number', isRequired: false),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Health Targets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(_targetMinController, 'Min Glucose', '80', isNumber: true, isRequired: true),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(_targetMaxController, 'Max Glucose', '120', isNumber: true, isRequired: true),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(_caloriesController, 'Daily Calories Target', '2000', isNumber: true, isRequired: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {
    bool isNumber = false, 
    bool isEmail = false, 
    int maxLines = 1,
    bool isRequired = true
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      validator: isRequired ? (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (isEmail && !value.contains('@')) {
          return 'Please enter a valid email';
        }
        if (isNumber) {
          final num = double.tryParse(value);
          if (num == null || num <= 0) {
            return 'Please enter a valid number';
          }
        }
        return null;
      } : null,
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      items: ['Male', 'Female'].map((String gender) {
        return DropdownMenuItem<String>(
          value: gender,
          child: Text(gender),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedGender = newValue!;
        });
      },
      decoration: const InputDecoration(
        labelText: 'Gender',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedUser = widget.userProfile.copyWith(
        fullName: _fullNameController.text,
        email: _emailController.text,
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        targetGlucoseMin: double.parse(_targetMinController.text),
        targetGlucoseMax: double.parse(_targetMaxController.text),
        dailyCaloriesTarget: int.parse(_caloriesController.text),
        phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
      );

      final success = await _userService.updateUserProfile(updatedUser);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onProfileUpdated();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _phoneController.dispose();
    _targetMinController.dispose();
    _targetMaxController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }
}