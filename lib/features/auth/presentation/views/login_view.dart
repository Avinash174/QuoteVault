import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/snackbar_utils.dart'; // Added
import '../../../home/presentation/views/main_screen.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _isSignIn = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = AuthService();

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // EMAIL AUTH
  // ---------------------------------------------------------------------------

  Future<void> _handleAuth() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      SnackbarUtils.showWarning(
        context,
        'Missing Fields',
        'Please enter email and password',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isSignIn) {
        await _authService.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await _authService.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (mounted) {
          SnackbarUtils.showSuccess(
            context,
            'Success',
            'Account created successfully!',
          );
        }
      }

      if (mounted) {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Authentication Failed',
          e.message ?? 'An error occurred',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Error', e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // SOCIAL AUTH
  // ---------------------------------------------------------------------------

  Future<void> _handleSocialAuth(Future<void> Function() authMethod) async {
    setState(() => _isLoading = true);
    try {
      await authMethod();
      if (mounted) {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Social Login Failed',
          e.message ?? 'An error occurred',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(context, 'Error', e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // FORGOT PASSWORD
  // ---------------------------------------------------------------------------

  Future<void> _handleForgotPassword() async {
    final emailController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Reset Password',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        content: TextField(
          controller: emailController,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: 'Email',
            hintStyle: const TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? Colors.white24 : Colors.black12,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () async {
              if (emailController.text.trim().isEmpty) {
                if (mounted) {
                  SnackbarUtils.showError(
                    context,
                    'Input Error',
                    'Please enter your email',
                  );
                }
                return;
              }

              Navigator.pop(context);

              try {
                await _authService.resetPassword(
                  email: emailController.text.trim(),
                );

                if (mounted) {
                  SnackbarUtils.showSuccess(
                    context,
                    'Email Sent',
                    'Password reset email sent',
                  );
                }
              } catch (e) {
                if (mounted) {
                  SnackbarUtils.showError(context, 'Error', e.toString());
                }
              }
            },
            child: const Text(
              'Send Link',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Image.asset('assets/icon/app_logo.png', height: 80, width: 80),
              const SizedBox(height: 16),
              const Text(
                'ThoughtVault',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              _buildSegmentedControl(),
              const SizedBox(height: 32),

              _buildLabel('Email'),
              _buildTextField(
                controller: _emailController,
                hint: 'name@example.com',
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLabel('Password'),
                  if (_isSignIn)
                    GestureDetector(
                      onTap: _handleForgotPassword,
                      child: const Text(
                        'Forgot?',
                        style: TextStyle(color: AppColors.accent),
                      ),
                    ),
                ],
              ),
              _buildTextField(
                controller: _passwordController,
                hint: 'Password',
                isPassword: true,
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _isSignIn ? 'Sign In' : 'Create Account',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),

              const Divider(color: Colors.white10),
              const SizedBox(height: 24),

              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: _socialButton(
                      icon: FontAwesomeIcons.google,
                      label: 'Google',
                      onTap: () =>
                          _handleSocialAuth(_authService.signInWithGoogle),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (Theme.of(context).platform == TargetPlatform.iOS)
                    // Removed Apple Sign In per user request
                    const SizedBox.shrink(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isSignIn = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isSignIn ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      color: _isSignIn ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isSignIn = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isSignIn ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Create',
                    style: TextStyle(
                      color: !_isSignIn ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && _obscurePassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              )
            : null,
      ),
    );
  }

  Widget _socialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onTap,
        icon: FaIcon(icon, color: foregroundColor),
        label: Text(label, style: TextStyle(color: foregroundColor)),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
