import 'package:flutter/material.dart';

import '../auth/models/register_request.dart';
import '../state/store_controller.dart';
import '../state/store_scope.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = StoreScope.of(context);

    return Scaffold(
      backgroundColor: AppTheme.mist,
      appBar: AppBar(
        backgroundColor: AppTheme.mist,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Create new account.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const _RegisterLabel(text: 'Email'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        decoration: const InputDecoration(
                          hintText: 'Your email address',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _RegisterLabel(text: 'First name'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _firstNameController,
                        validator: _validateName,
                        decoration: const InputDecoration(
                          hintText: 'Your first name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _RegisterLabel(text: 'Last name'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _lastNameController,
                        validator: _validateName,
                        decoration: const InputDecoration(
                          hintText: 'Your last name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _RegisterLabel(text: 'Password'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: _validatePassword,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _RegisterLabel(text: 'Confirm Password'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Confirm password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(
                                () => _obscureConfirmPassword =
                                    !_obscureConfirmPassword,
                              );
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        height: 56,
                        child: FilledButton(
                          onPressed: controller.isBusy
                              ? null
                              : () => _submit(controller),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF4E89EF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: controller.isBusy
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                  ),
                                )
                              : const Text(
                                  'Sign up',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Login',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF4E89EF),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter email';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _submit(StoreController controller) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final username = _buildUsername(firstName, lastName, email);
    final request = RegisterRequest(
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      password: _passwordController.text,
      verifyPassword: _confirmPasswordController.text,
    );

    final success = await controller.register(request);
    if (!mounted) {
      return;
    }
    if (!success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            controller.authErrorMessage ??
                'Registration failed. Please check your input.',
          ),
        ),
      );
      return;
    }

    if (!mounted) {
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Your account for $firstName has been created successfully.',
        ),
      ),
    );
    controller.setSelectedTab(0);
    navigator.popUntil((route) => route.isFirst);
  }

  String _buildUsername(String firstName, String lastName, String email) {
    final combined = '$firstName $lastName'
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '');
    if (combined.isNotEmpty) {
      return combined;
    }
    final emailPrefix = email.split('@').first.trim().toLowerCase();
    if (emailPrefix.isNotEmpty) {
      return emailPrefix;
    }
    return 'user';
  }
}

class _RegisterLabel extends StatelessWidget {
  const _RegisterLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: AppTheme.dark,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        children: [
          TextSpan(text: text),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.redAccent),
          ),
        ],
      ),
    );
  }
}
