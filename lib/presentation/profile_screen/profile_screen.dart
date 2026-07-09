import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:dio/dio.dart';
import '../../core/profile_notifier.dart';
import '../../core/auth_service.dart';
import '../../core/profile_service.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();

  // Driver-specific controllers
  final _vehicleRegNoController = TextEditingController();
  final _experienceController = TextEditingController();

  // Profile image URL
  String _profileImageUrl = '';

  String _selectedGender = 'Male';
  String _userRole = 'patient';
  bool _isEditing = false;
  bool _isLoading = true;
  bool _isSaving = false;

  // Driver-specific fields
  String _vehicleType = 'Basic Life Support';
  bool _isOnline = false;

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  final List<String> _vehicleTypes = [
    'Basic Life Support',
    'Advanced Life Support',
    'Neonatal Ambulance',
    'Patient Transport',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    _vehicleRegNoController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final data = await ProfileService.instance.getProfile();
      final user = data['user'] as Map<String, dynamic>?;
      final driverProfile = data['driverProfile'] as Map<String, dynamic>?;

      if (user != null && mounted) {
        setState(() {
          _fullNameController.text = user['fullName']?.toString() ?? '';
          _contactController.text = user['phone']?.toString() ?? '';
          _emailController.text = user['email']?.toString() ?? '';
          _addressController.text = user['address']?.toString() ?? '';
          _pincodeController.text = user['pincode']?.toString() ?? '';
          _selectedGender = user['gender']?.toString() ?? 'Male';
          _profileImageUrl = user['profileImageUrl']?.toString() ?? '';
          _userRole = user['role']?.toString() ?? 'patient';

          if (driverProfile != null) {
            _vehicleRegNoController.text = driverProfile['vehicleRegNo']?.toString() ?? '';
            _vehicleType = driverProfile['vehicleType']?.toString() ?? 'Basic Life Support';
            _experienceController.text = driverProfile['experience']?.toString() ?? '';
            _isOnline = driverProfile['isOnline'] == true;
          }
        });
      }
    } on DioException catch (e) {
      debugPrint('[ProfileScreen] Error loading profile: ${e.message}');
      // Fallback to auth service cached data
      if (mounted) {
        setState(() {
          _fullNameController.text = AuthService.instance.fullName ?? '';
          _contactController.text = AuthService.instance.phone ?? '';
          _emailController.text = AuthService.instance.email ?? '';
          _profileImageUrl = AuthService.instance.profileImageUrl ?? '';
          _userRole = AuthService.instance.role ?? 'patient';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      await ProfileService.instance.updateProfile(
        fullName: _fullNameController.text.trim(),
        phone: _contactController.text.trim(),
        address: _addressController.text.trim(),
        pincode: _pincodeController.text.trim(),
        gender: _selectedGender,
        vehicleRegNo: _userRole == 'driver' ? _vehicleRegNoController.text.trim() : null,
        vehicleType: _userRole == 'driver' ? _vehicleType : null,
        experience: _userRole == 'driver' ? _experienceController.text.trim() : null,
        isOnline: _userRole == 'driver' ? _isOnline : null,
      );

      ProfileNotifier.instance.notifyProfileUpdated();
      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile updated successfully',
              style: GoogleFonts.plusJakartaSans(fontSize: 14),
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        final message = e.response?.data is Map
            ? (e.response!.data as Map)['message'] ?? 'Failed to update profile'
            : 'Network error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.toString(), style: GoogleFonts.plusJakartaSans(fontSize: 14)),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppTheme.surfaceLight,
          elevation: 0,
          title: Text(
            'My Profile',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A1A),
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceLight,
        elevation: 0,
        title: Text(
          'My Profile',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        actions: [
          if (!_isEditing)
            TextButton.icon(
              onPressed: _toggleEdit,
              icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.primary),
              label: Text(
                'Edit',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primary,
                ),
              ),
            )
          else
            TextButton(
              onPressed: _toggleEdit,
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 25.w,
                          height: 25.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.primary, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withAlpha(40),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _profileImageUrl.isNotEmpty
                                ? Image.network(
                                    _profileImageUrl,
                                    fit: BoxFit.cover,
                                    semanticLabel: 'Profile photo',
                                    errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(),
                                  )
                                : _buildAvatarFallback(),
                          ),
                        ),
                        if (_isEditing)
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Photo upload coming soon',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                  margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                                ),
                              );
                            },
                            child: Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      _fullNameController.text.isNotEmpty ? _fullNameController.text : 'User',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16.sp > 20 ? 20 : 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        _userRole == 'driver' ? 'Driver' : 'Patient',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Personal Information Card
              _buildSectionCard(
                title: 'Personal Information',
                icon: Icons.person_outline_rounded,
                children: [
                  _buildTextField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    icon: Icons.badge_outlined,
                    enabled: _isEditing,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
                  ),
                  SizedBox(height: 2.h),
                  _buildGenderField(),
                ],
              ),

              SizedBox(height: 2.h),

              // Contact Information Card
              _buildSectionCard(
                title: 'Contact Information',
                icon: Icons.contact_phone_outlined,
                children: [
                  _buildTextField(
                    controller: _contactController,
                    label: 'Contact Number',
                    icon: Icons.phone_outlined,
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Contact number is required' : null,
                  ),
                  SizedBox(height: 2.h),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.email_outlined,
                    enabled: false, // Email can't be changed
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // Address Card
              _buildSectionCard(
                title: 'Permanent Residence Address',
                icon: Icons.home_outlined,
                children: [
                  _buildTextField(
                    controller: _addressController,
                    label: 'Permanent Residence Address',
                    icon: Icons.location_on_outlined,
                    enabled: _isEditing,
                    maxLines: 3,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Address is required' : null,
                  ),
                  SizedBox(height: 2.h),
                  _buildTextField(
                    controller: _pincodeController,
                    label: 'Pincode',
                    icon: Icons.pin_drop_outlined,
                    enabled: _isEditing,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Pincode is required';
                      if (v.trim().length != 6 || int.tryParse(v.trim()) == null) {
                        return 'Enter a valid 6-digit pincode';
                      }
                      return null;
                    },
                  ),
                ],
              ),

              // Driver-specific section
              if (_userRole == 'driver') ...[
                SizedBox(height: 2.h),
                _buildSectionCard(
                  title: 'Vehicle Information',
                  icon: Icons.local_shipping_outlined,
                  children: [
                    _buildTextField(
                      controller: _vehicleRegNoController,
                      label: 'Vehicle Reg. No.',
                      icon: Icons.directions_car_outlined,
                      enabled: _isEditing,
                    ),
                    SizedBox(height: 2.h),
                    _buildVehicleTypeField(),
                    SizedBox(height: 2.h),
                    _buildTextField(
                      controller: _experienceController,
                      label: 'Experience',
                      icon: Icons.work_outline_rounded,
                      enabled: _isEditing,
                    ),
                  ],
                ),
              ],

              SizedBox(height: 3.h),

              // Save Button
              if (_isEditing)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 1.8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(
                            'Save Changes',
                            style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),

              SizedBox(height: 3.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      color: AppTheme.primaryContainer,
      child: Icon(Icons.person_rounded, size: 14.w, color: AppTheme.primary),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primary),
              SizedBox(width: 2.w),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: enabled ? const Color(0xFF1A1A1A) : const Color(0xFF555555),
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon, size: 20,
          color: enabled ? AppTheme.primary : const Color(0xFF9E9E9E),
        ),
        filled: true,
        fillColor: enabled ? const Color(0xFFF7F7F7) : const Color(0xFFF0F0F0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF9E9E9E),
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.wc_outlined, size: 20,
                color: _isEditing ? AppTheme.primary : const Color(0xFF9E9E9E)),
            SizedBox(width: 2.w),
            Text('Gender', style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF9E9E9E))),
          ],
        ),
        SizedBox(height: 1.h),
        if (!_isEditing)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Text(_selectedGender, style: GoogleFonts.plusJakartaSans(
                fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF555555))),
          )
        else
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: _genderOptions.map((gender) {
              final isSelected = _selectedGender == gender;
              return GestureDetector(
                onTap: () => setState(() => _selectedGender = gender),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : const Color(0xFFDDDDDD),
                    ),
                  ),
                  child: Text(gender, style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF555555),
                  )),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildVehicleTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_shipping_outlined, size: 20,
                color: _isEditing ? AppTheme.primary : const Color(0xFF9E9E9E)),
            SizedBox(width: 2.w),
            Text('Vehicle Type', style: GoogleFonts.plusJakartaSans(
                fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF9E9E9E))),
          ],
        ),
        SizedBox(height: 1.h),
        if (!_isEditing)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: Text(_vehicleType, style: GoogleFonts.plusJakartaSans(
                fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF555555))),
          )
        else
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: _vehicleTypes.map((type) {
              final isSelected = _vehicleType == type;
              return GestureDetector(
                onTap: () => setState(() => _vehicleType = type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : const Color(0xFFDDDDDD),
                    ),
                  ),
                  child: Text(type, style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF555555),
                  )),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
