// medical_information_screen.dart - FIXED with user data isolation (design unchanged)
import 'package:flutter/material.dart';
import 'package:motmaen/services/database_helper.dart';
import 'package:motmaen/models/user_profile.dart';
import 'package:motmaen/services/user_service.dart';

class MedicalInformationScreen extends StatefulWidget {
  final VoidCallback? onMedicalInfoUpdated;
  
  const MedicalInformationScreen({super.key, this.onMedicalInfoUpdated});

  @override
  State<MedicalInformationScreen> createState() => _MedicalInformationScreenState();
}

class _MedicalInformationScreenState extends State<MedicalInformationScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();
  
  final _medicalConditionsController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _insuranceController = TextEditingController();
  final _doctorNameController = TextEditingController();
  final _doctorPhoneController = TextEditingController();
  
  bool _isLoading = true;
  bool _isEditing = false;
  UserProfile? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadMedicalInfo();
  }

  Future<void> _loadMedicalInfo() async {
    try {
      // Use UserService to get current user with proper user isolation
      await _userService.loadCurrentUser();
      final user = _userService.currentUser;
      
      if (user != null) {
        _currentUser = user;
        _medicalConditionsController.text = user.medicalConditions ?? '';
        _medicationsController.text = user.medications ?? '';
        _allergiesController.text = user.allergies ?? '';
        _bloodTypeController.text = user.bloodType ?? '';
        _insuranceController.text = user.insuranceInfo ?? '';
        _doctorNameController.text = user.doctorName ?? '';
        _doctorPhoneController.text = user.doctorPhone ?? '';
      }
    } catch (e) {
      print('Error loading medical info: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Information'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _startEditing,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEmergencyCard(),
                    const SizedBox(height: 10),
                    _buildMedicalConditionsSection(),
                    const SizedBox(height: 10),
                    _buildMedicationsSection(),
                    const SizedBox(height: 10),
                    _buildAllergiesSection(),
                    const SizedBox(height: 10),
                    _buildDoctorInfoSection(),
                    const SizedBox(height: 10),
                    if (_isEditing) _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmergencyCard() {
    return Card(
      color: Colors.red.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emergency, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  'Emergency Medical Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'This information will be shown in the Emergency Contacts screen for medical personnel.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            _buildEmergencyInfoItem('Blood Type', _bloodTypeController, 'Not specified'),
            _buildEmergencyInfoItem('Allergies', _allergiesController, 'None known'),
            _buildEmergencyInfoItem('Medical Conditions', _medicalConditionsController, 'None specified'),
            _buildEmergencyInfoItem('Current Medications', _medicationsController, 'None specified'),
            _buildEmergencyInfoItem('Insurance', _insuranceController, 'Not specified'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyInfoItem(String label, TextEditingController controller, String placeholder) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
          Expanded(
            child: Text(
              controller.text.isEmpty ? placeholder : controller.text,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalConditionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medical Conditions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'List any chronic or significant medical conditions',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _medicalConditionsController,
              maxLines: 4,
              readOnly: !_isEditing,
              decoration: const InputDecoration(
                hintText: 'e.g., Type 2 Diabetes, Hypertension, Asthma...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Medications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Include medication names and dosages',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _medicationsController,
              maxLines: 4,
              readOnly: !_isEditing,
              decoration: const InputDecoration(
                hintText: 'e.g., Metformin 500mg twice daily, Lisinopril 10mg daily...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergiesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Allergies & Sensitivities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'List any allergies to medications, food, or environmental factors',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _allergiesController,
              maxLines: 3,
              readOnly: !_isEditing,
              decoration: const InputDecoration(
                hintText: 'e.g., Penicillin, Peanuts, Latex...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medical Provider & Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Contact information for your primary healthcare provider',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _doctorNameController,
              readOnly: !_isEditing,
              decoration: const InputDecoration(
                labelText: 'Primary Doctor Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _doctorPhoneController,
              readOnly: !_isEditing,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Doctor Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bloodTypeController,
              readOnly: !_isEditing,
              decoration: const InputDecoration(
                labelText: 'Blood Type',
                border: OutlineInputBorder(),
                hintText: 'e.g., O+, A-, AB+...',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _insuranceController,
              readOnly: !_isEditing,
              decoration: const InputDecoration(
                labelText: 'Insurance Information',
                border: OutlineInputBorder(),
                hintText: 'Insurance company and policy number',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _cancelEditing,
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveMedicalInfo,
            child: const Text('Save Changes'),
          ),
        ),
      ],
    );
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    // Reload original data
    _loadMedicalInfo();
    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _saveMedicalInfo() async {
    if (_currentUser != null) {
      try {
        final updatedUser = _currentUser!.copyWith(
          medicalConditions: _medicalConditionsController.text.isEmpty ? null : _medicalConditionsController.text,
          medications: _medicationsController.text.isEmpty ? null : _medicationsController.text,
          allergies: _allergiesController.text.isEmpty ? null : _allergiesController.text,
          bloodType: _bloodTypeController.text.isEmpty ? null : _bloodTypeController.text,
          insuranceInfo: _insuranceController.text.isEmpty ? null : _insuranceController.text,
          doctorName: _doctorNameController.text.isEmpty ? null : _doctorNameController.text,
          doctorPhone: _doctorPhoneController.text.isEmpty ? null : _doctorPhoneController.text,
        );

        // Update in database
        final result = await _databaseHelper.updateUser(updatedUser);
        
        if (result > 0) {
          // Also update in UserService to keep everything in sync
          await _userService.updateUserProfile(updatedUser);
          await _userService.loadCurrentUser();
          
          setState(() {
            _currentUser = updatedUser;
            _isEditing = false;
          });

          // Call the callback to notify parent about the update
          if (widget.onMedicalInfoUpdated != null) {
            widget.onMedicalInfoUpdated!();
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Medical information saved successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save medical information'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save medical information: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _medicalConditionsController.dispose();
    _medicationsController.dispose();
    _allergiesController.dispose();
    _bloodTypeController.dispose();
    _insuranceController.dispose();
    _doctorNameController.dispose();
    _doctorPhoneController.dispose();
    super.dispose();
  }
}