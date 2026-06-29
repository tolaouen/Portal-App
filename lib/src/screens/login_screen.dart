import 'package:flutter/material.dart';

import 'register_screen.dart';
import '../state/store_scope.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  Future<void> _submitLogin(BuildContext context) async {
    final controller = StoreScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final username = _emailController.text.trim();
    final password = _passwordController.text;
    final success = await controller.login(
      username: username,
      password: password,
    );

    if (!context.mounted) {
      return;
    }

    if (!success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            controller.authErrorMessage ??
                'Login failed. Please check your credentials.',
          ),
        ),
      );
      return;
    }

    messenger.showSnackBar(const SnackBar(content: Text('Welcome back!')));
    controller.setSelectedTab(0);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = StoreScope.of(context);
    return Scaffold(
      backgroundColor: AppTheme.mist,
      appBar: AppBar(
        backgroundColor: AppTheme.mist,
        leading: Navigator.of(context).canPop() ? const BackButton() : null,
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
                  borderRadius: BorderRadius.circular(0),
                ),
                child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 6),
                        const Text(
                          'Welcome Back!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Thank for to be a customer guy.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 34),
                        const _AuthLabel(text: 'Email'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.none,
                          autocorrect: false,
                          enableSuggestions: false,
                          autofillHints: const [
                            AutofillHints.username,
                            AutofillHints.email,
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: 'Your email address',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const _AuthLabel(text: 'Password'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          autocorrect: false,
                          enableSuggestions: false,
                          autofillHints: const [AutofillHints.password],
                          onFieldSubmitted: (_) => _submitLogin(context),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter password';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
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
                                : () => _submitLogin(context),
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
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("If you don't have account. "),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Sign up',
                                style: TextStyle(
                                  color: Color(0xFF4E89EF),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthLabel extends StatelessWidget {
  const _AuthLabel({required this.text});

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
