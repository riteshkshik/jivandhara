import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_export.dart';
import 'widgets/auth_form_widget.dart';
import 'widgets/role_selector_widget.dart';
import 'widgets/auth_hero_widget.dart';

enum UserRole { patient, driver, admin }

enum AuthMode { signIn, signUp }

class SignUpLoginScreen extends StatefulWidget {
  const SignUpLoginScreen({super.key});

  @override
  State<SignUpLoginScreen> createState() => _SignUpLoginScreenState();
}

class _SignUpLoginScreenState extends State<SignUpLoginScreen> {
  // TODO: Replace with [Riverpod/Bloc] for production
  UserRole _selectedRole = UserRole.patient;
  AuthMode _authMode = AuthMode.signIn;

  void _onRoleChanged(UserRole role) {
    setState(() => _selectedRole = role);
  }

  void _onAuthModeToggle() {
    setState(() {
      _authMode = _authMode == AuthMode.signIn
          ? AuthMode.signUp
          : AuthMode.signIn;
    });
  }

  void _onSubmit() {
    context.go('/home-screen');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        top: false,
        child: isTablet ? _buildTabletLayout(theme) : _buildPhoneLayout(theme),
      ),
    );
  }

  Widget _buildPhoneLayout(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(children: [AuthHeroWidget(), _buildFormPanel(theme)]),
    );
  }

  Widget _buildTabletLayout(ThemeData theme) {
    return Center(
      child: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            children: [
              const SizedBox(height: 32),
              _buildLogo(theme),
              const SizedBox(height: 32),
              _buildFormPanel(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.emergency_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Jivandhara',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Emergency Ambulance Service',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildFormPanel(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _authMode == AuthMode.signIn ? 'Welcome back' : 'Create account',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              _authMode == AuthMode.signIn
                  ? 'Sign in to access emergency services'
                  : 'Register to get started with Jivandhara',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            RoleSelectorWidget(
              selectedRole: _selectedRole,
              onRoleChanged: _onRoleChanged,
            ),
            const SizedBox(height: 20),
            AuthFormWidget(
              authMode: _authMode,
              selectedRole: _selectedRole,
              onSubmit: _onSubmit,
            ),
            const SizedBox(height: 20),
            _buildAuthToggle(theme),
            const SizedBox(height: 16),
            _buildDemoCredentials(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthToggle(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _authMode == AuthMode.signIn
              ? "Don't have an account? "
              : "Already have an account? ",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        GestureDetector(
          onTap: _onAuthModeToggle,
          child: Text(
            _authMode == AuthMode.signIn ? 'Sign Up' : 'Sign In',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDemoCredentials(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Demo Credentials',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _credentialRow(
            theme,
            'Patient',
            'priya.sharma@jivandhara.in',
            'Jivandhara@2024',
          ),
          const SizedBox(height: 6),
          _credentialRow(
            theme,
            'Driver',
            'rajan.patel@jivandhara.in',
            'Driver@2024',
          ),
          const SizedBox(height: 6),
          _credentialRow(theme, 'Admin', 'admin@jivandhara.in', 'Admin@2024'),
        ],
      ),
    );
  }

  Widget _credentialRow(
    ThemeData theme,
    String role,
    String email,
    String password,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            role,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            email,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
