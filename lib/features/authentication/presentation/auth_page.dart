import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_snackbar.dart';
import 'auth_provider.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLogin = true;
  bool _showForgotPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _showForgotPassword = false;
    });
    context.read<AuthProvider>().clearError();
  }

  void _showForgotPasswordForm() {
    setState(() {
      _showForgotPassword = true;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    if (_showForgotPassword) {
      await _handlePasswordReset(authProvider);
    } else if (_isLogin) {
      await _handleLogin(authProvider);
    } else {
      await _handleRegister(authProvider);
    }
  }

  Future<void> _handleLogin(AuthProvider authProvider) async {
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!success) return;

    showAppSnackBar('Logged in successfully.', isSuccess: true);
    if (mounted) _clearForm();
  }

  Future<void> _handleRegister(AuthProvider authProvider) async {
    final success = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      displayName: _nameController.text.trim(),
    );

    if (!success) return;

    showAppSnackBar('Account created successfully.', isSuccess: true);
    if (mounted) _clearForm();
  }

  Future<void> _handlePasswordReset(AuthProvider authProvider) async {
    final success = await authProvider.resetPassword(
      email: _emailController.text.trim(),
    );

    if (!success) return;

    showAppSnackBar(
      'Password reset email sent. Check your inbox.',
      isSuccess: true,
    );
    if (mounted) {
      setState(() {
        _showForgotPassword = false;
      });
      _clearForm();
    }
  }

  void _clearForm() {
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final errorMessage = authProvider.errorMessage;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppSpacing.xxl),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        boxShadow: AppShadows.soft,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (errorMessage != null) ...[
                            _buildErrorBanner(errorMessage),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                          if (_showForgotPassword)
                            _buildForgotPasswordForm(authProvider)
                          else
                            _buildAuthForm(authProvider),
                          const SizedBox(height: AppSpacing.xxl),
                          _buildSubmitButton(authProvider),
                          const SizedBox(height: AppSpacing.md),
                          _buildToggleModeButton(authProvider),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.primary0,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.remove_red_eye,
            size: 32,
            color: AppColors.primary300,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Eye Monitoring',
          textAlign: TextAlign.center,
          style: AppTypography.heading1(color: theme.colorScheme.onSurface),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _showForgotPassword
              ? 'Reset your password'
              : _isLogin
                  ? 'Welcome back! Please log in.'
                  : 'Create your account.',
          textAlign: TextAlign.center,
          style: AppTypography.body(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.errorText.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.errorText,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.body(color: AppColors.errorText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthForm(AuthProvider authProvider) {
    return Column(
      children: [
        if (!_isLogin) ...[
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (!_isLogin && (value == null || value.trim().isEmpty)) {
                return 'Please enter your name.';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'you@example.com',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your email.';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email.';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          textInputAction:
              _isLogin ? TextInputAction.done : TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Password',
            hintText: 'At least 6 characters',
            prefixIcon: Icon(Icons.lock_outline),
          ),
          validator: (value) {
            if (_showForgotPassword) return null;
            if (value == null || value.isEmpty) {
              return 'Please enter your password.';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters.';
            }
            return null;
          },
          onFieldSubmitted: _isLogin ? (_) => _submit() : null,
        ),
        if (!_isLogin) ...[
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Re-enter your password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password.';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match.';
              }
              return null;
            },
            onFieldSubmitted: (_) => _submit(),
          ),
        ],
        if (_isLogin) ...[
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: authProvider.isLoading ? null : _showForgotPasswordForm,
              child: const Text('Forgot Password?'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildForgotPasswordForm(AuthProvider authProvider) {
    return Column(
      children: [
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'you@example.com',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your email.';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email.';
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Enter your email address and we\'ll send you a link to reset your password.',
          style: AppTypography.caption(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AuthProvider authProvider) {
    String buttonText;
    if (_showForgotPassword) {
      buttonText = 'Send Reset Link';
    } else if (_isLogin) {
      buttonText = 'Login';
    } else {
      buttonText = 'Create Account';
    }

    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: authProvider.isLoading ? null : _submit,
        child: authProvider.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(buttonText, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildToggleModeButton(AuthProvider authProvider) {
    if (_showForgotPassword) {
      return TextButton(
        onPressed: authProvider.isLoading
            ? null
            : () {
                setState(() {
                  _showForgotPassword = false;
                });
                authProvider.clearError();
              },
        child: const Text('Back to Login'),
      );
    }

    return TextButton(
      onPressed: authProvider.isLoading ? null : _toggleMode,
      child: Text(
        _isLogin
            ? "Don't have an account? Sign Up"
            : 'Already have an account? Login',
      ),
    );
  }
}
