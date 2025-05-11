import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:menstrual_health_ai/constants/app_colors.dart';
import 'package:menstrual_health_ai/constants/text_styles.dart';
import 'package:menstrual_health_ai/models/user_data.dart';
import 'package:menstrual_health_ai/providers/user_data_provider.dart';
import 'package:menstrual_health_ai/widgets/animated_gradient_button.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _cycleLengthController = TextEditingController();
  final _periodLengthController = TextEditingController();
  
  DateTime? _birthDate;
  DateTime? _lastPeriodDate;
  bool _isLoading = false;
  List<String> _healthConditions = [];
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    final userData = Provider.of<UserDataProvider>(context, listen: false).userData;
    if (userData != null) {
      setState(() {
        _nameController.text = userData.name;
        _emailController.text = userData.email;
        _birthDate = userData.birthDate;
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(userData.birthDate);
        _heightController.text = userData.height.toString();
        _weightController.text = userData.weight.toString();
        _cycleLengthController.text = userData.cycleLength.toString();
        _periodLengthController.text = userData.periodLength.toString();
        _lastPeriodDate = userData.lastPeriodDate;
        _healthConditions = userData.healthConditions;
      });
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _cycleLengthController.dispose();
    _periodLengthController.dispose();
    super.dispose();
  }

  Future<void> _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
        
        // Calculate age from birthdate
        final now = DateTime.now();
        final birthDate = _birthDate ?? DateTime.now();
        int age = now.year - birthDate.year;
        if (now.month < birthDate.month || 
            (now.month == birthDate.month && now.day < birthDate.day)) {
          age--;
        }
        
        await userDataProvider.saveOnboardingData(
          name: _nameController.text,
          age: age,
          weight: double.tryParse(_weightController.text) ?? 0.0,
          height: double.tryParse(_heightController.text) ?? 0.0,
          cycleLength: int.tryParse(_cycleLengthController.text) ?? 28,
          periodLength: int.tryParse(_periodLengthController.text) ?? 5,
          lastPeriodDate: _lastPeriodDate ?? DateTime.now(),
          birthDate: _birthDate ?? DateTime.now(),
          email: _emailController.text,
          healthConditions: _healthConditions,
          symptoms: [],
          moods: [],
          notes: [],
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile updated successfully!"),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error updating profile: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _handleSavePressed() {
    _saveUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfilePicture(),
                  const SizedBox(height: 32),
                  _buildProfileForm(),
                  const SizedBox(height: 32),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // Show image picker
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Profile picture upload coming soon!"),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Change Profile Picture",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ).animate().fadeIn(duration: 600.ms),
    );
  }

  Widget _buildProfileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Personal Information",
          style: TextStyles.heading3,
        ),
        const SizedBox(height: 24),
        _buildTextField(
          label: "Full Name",
          controller: _nameController,
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your name";
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: "Email",
          controller: _emailController,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your email";
            }
            if (!value.contains('@')) {
              return "Please enter a valid email";
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: "Phone Number",
          controller: _phoneController,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: "Birthday",
          controller: _birthdayController,
          icon: Icons.cake_outlined,
          readOnly: true,
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _birthDate ?? DateTime(1990, 5, 15),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _birthDate = picked;
                _birthdayController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
              });
            }
          },
        ),
        const SizedBox(height: 24),
        Text(
          "Health Information",
          style: TextStyles.heading3,
        ),
        const SizedBox(height: 24),
        _buildTextField(
          label: "Height (cm)",
          controller: _heightController,
          icon: Icons.height,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your height";
            }
            if (double.tryParse(value) == null) {
              return "Please enter a valid number";
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: "Weight (kg)",
          controller: _weightController,
          icon: Icons.monitor_weight_outlined,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your weight";
            }
            if (double.tryParse(value) == null) {
              return "Please enter a valid number";
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        Text(
          "Cycle Information",
          style: TextStyles.heading3,
        ),
        const SizedBox(height: 24),
        _buildTextField(
          label: "Average Cycle Length (days)",
          controller: _cycleLengthController,
          icon: Icons.calendar_month_outlined,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your cycle length";
            }
            if (int.tryParse(value) == null) {
              return "Please enter a valid number";
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: "Average Period Length (days)",
          controller: _periodLengthController,
          icon: Icons.water_drop_outlined,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your period length";
            }
            if (int.tryParse(value) == null) {
              return "Please enter a valid number";
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: "Last Period Date",
          controller: TextEditingController(
            text: _lastPeriodDate != null 
                ? DateFormat('yyyy-MM-dd').format(_lastPeriodDate!) 
                : 'Not set'
          ),
          icon: Icons.event_outlined,
          readOnly: true,
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _lastPeriodDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _lastPeriodDate = picked;
              });
            }
          },
        ),
      ],
    ).animate().fadeIn(duration: 800.ms, delay: 200.ms);
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: AppColors.primary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return AnimatedGradientButton(
      onPressed: _isLoading ? null : _handleSavePressed,
      text: _isLoading ? "Saving..." : "Save Changes",
      isLoading: _isLoading,
      icon: Icons.check,
    ).animate().fadeIn(duration: 800.ms, delay: 400.ms);
  }
}
