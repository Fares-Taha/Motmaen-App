import 'package:flutter/material.dart';
import 'package:motmaen/services/database_helper.dart';
import 'package:motmaen/models/user_profile.dart';
import 'package:motmaen/services/auth_service.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _medicalConditionsController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _targetMinController = TextEditingController();
  final _targetMaxController = TextEditingController();
  final _caloriesController = TextEditingController();

  String _selectedGender = 'Male';
  bool _isLoading = false;

  final List<String> _genders = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    _targetMinController.text = '80';
    _targetMaxController.text = '120';
    _caloriesController.text = '2000';
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Color(0xFF28BAA8)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF28BAA8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF28BAA8), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF28BAA8), width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Create your account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                _buildFullNameField(),
                const SizedBox(height: 20),
                _buildEmailField(),
                const SizedBox(height: 20),
                _buildPasswordField(),
                const SizedBox(height: 20),
                _buildConfirmPasswordField(),
                const SizedBox(height: 20),
                _buildAgeField(),
                const SizedBox(height: 20),
                _buildGenderDropdown(),
                const SizedBox(height: 20),
                _buildWeightField(),
                const SizedBox(height: 20),
                _buildHeightField(),
                const SizedBox(height: 20),
                _buildPhoneField(),
                const SizedBox(height: 20),
                _buildHealthTargetsSection(),
                const SizedBox(height: 30),
                _buildSignupButton(),
                const SizedBox(height: 20),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullNameField() => _textField(
        label: 'Full Name',
        controller: _fullNameController,
        hint: 'Enter your full name',
        validator: (v) => v!.isEmpty ? 'Please enter your full name' : null,
      );

  Widget _buildEmailField() => _textField(
        label: 'Email',
        controller: _emailController,
        hint: 'Enter your email',
        validator: (v) {
          if (v == null || v.isEmpty) return 'Please enter your email';
          if (!v.contains('@')) return 'Please enter a valid email';
          return null;
        },
      );

  Widget _buildPasswordField() => _textField(
        label: 'Password',
        controller: _passwordController,
        hint: 'Enter your password',
        obscure: true,
        validator: (v) {
          if (v == null || v.isEmpty) return 'Please enter your password';
          if (v.length < 6) return 'Password must be at least 6 characters';
          return null;
        },
      );

  Widget _buildConfirmPasswordField() => _textField(
        label: 'Confirm Password',
        controller: _confirmPasswordController,
        hint: 'Confirm your password',
        obscure: true,
        validator: (v) {
          if (v == null || v.isEmpty) return 'Please confirm your password';
          if (v != _passwordController.text) return 'Passwords do not match';
          return null;
        },
      );

  Widget _buildAgeField() => _textField(
        label: 'Age',
        controller: _ageController,
        hint: 'Enter your age',
        keyboard: TextInputType.number,
        validator: (v) {
          if (v == null || v.isEmpty) return 'Please enter your age';
          final age = int.tryParse(v);
          if (age == null || age < 1 || age > 120) return 'Invalid age';
          return null;
        },
      );

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gender', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          items: _genders
              .map((g) => DropdownMenuItem(value: g, child: Text(g)))
              .toList(),
          onChanged: (v) => setState(() => _selectedGender = v!),
          decoration: _inputDecoration('Gender'),
        ),
      ],
    );
  }

  Widget _buildWeightField() => _textField(
        label: 'Weight (kg)',
        controller: _weightController,
        hint: 'Enter your weight',
        keyboard: TextInputType.number,
        suffix: 'kg',
        validator: (v) {
          if (v == null || v.isEmpty) return 'Please enter your weight';
          final w = double.tryParse(v);
          if (w == null || w <= 0) return 'Invalid weight';
          return null;
        },
      );

  Widget _buildHeightField() => _textField(
        label: 'Height (cm)',
        controller: _heightController,
        hint: 'Enter your height',
        keyboard: TextInputType.number,
        suffix: 'cm',
        validator: (v) {
          if (v == null || v.isEmpty) return 'Please enter your height';
          final h = double.tryParse(v);
          if (h == null || h <= 0) return 'Invalid height';
          return null;
        },
      );

  Widget _buildPhoneField() => _textField(
        label: 'Phone Number (Optional)',
        controller: _phoneController,
        hint: 'Enter your phone number',
        keyboard: TextInputType.phone,
      );

  Widget _buildHealthTargetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Health Targets',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _textField(
              label: 'Min Glucose (mg/dL)',
              controller: _targetMinController,
              hint: '80',
              keyboard: TextInputType.number,
            )),
            const SizedBox(width: 16),
            Expanded(
                child: _textField(
              label: 'Max Glucose (mg/dL)',
              controller: _targetMaxController,
              hint: '120',
              keyboard: TextInputType.number,
            )),
          ],
        ),
        const SizedBox(height: 16),
        _textField(
          label: 'Daily Calories Target',
          controller: _caloriesController,
          hint: '2000',
          keyboard: TextInputType.number,
        ),
      ],
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? suffix,
    bool obscure = false,
    int maxLines = 1,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboard,
          maxLines: maxLines,
          decoration: _inputDecoration(hint).copyWith(suffixText: suffix),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildSignupButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signup,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          backgroundColor: const Color(0xFF28BAA8),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
            : const Text('Create Account',
                style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }

  Widget _buildLoginLink() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Already have an account?"),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false, // This removes all previous routes
              );
            },
            child: const Text('Login',
                style: TextStyle(color: Color(0xFF28BAA8))),
          ),
        ],
      );

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final emailExists =
          await DatabaseHelper().doesEmailExist(_emailController.text);

      if (emailExists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('This email is already registered.'),
          backgroundColor: Colors.orange,
        ));
        return;
      }

      final user = UserProfile(
        fullName: _fullNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        targetGlucoseMin: double.parse(_targetMinController.text),
        targetGlucoseMax: double.parse(_targetMaxController.text),
        dailyCaloriesTarget: int.parse(_caloriesController.text),
        memberSince: DateTime.now(),
        phoneNumber:
            _phoneController.text.isEmpty ? null : _phoneController.text,
        emergencyContact: _emergencyContactController.text.isEmpty
            ? null
            : _emergencyContactController.text,
        medicalConditions: _medicalConditionsController.text.isEmpty
            ? null
            : _medicalConditionsController.text,
        medications: _medicationsController.text.isEmpty
            ? null
            : _medicationsController.text,
      );

      // Clear any cached authentication data before creating new user
      final authService = AuthService();
      authService.clearCache(); // Clear memory cache
      await authService.logout(); // Clear persistent storage
      
      final userId = await DatabaseHelper().insertUser(user);
      await authService.login(userId); // Login with new user

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Account created successfully!'),
          backgroundColor: Colors.green));
          
      // Clear the entire navigation stack and go to dashboard
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error creating account: $e'),
          backgroundColor: Colors.red));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _phoneController.dispose();
    _emergencyContactController.dispose();
    _medicalConditionsController.dispose();
    _medicationsController.dispose();
    _targetMinController.dispose();
    _targetMaxController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }
}
