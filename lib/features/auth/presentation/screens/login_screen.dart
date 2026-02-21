import 'package:artio/core/design_system/app_gradients.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/design_system/app_typography.dart';
import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/auth/presentation/widgets/social_login_buttons.dart';
import 'package:artio/routing/routes/app_routes.dart';
import 'package:artio/shared/widgets/gradient_button.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:artio/utils/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Login screen with animated gradient background, branded logo,
/// styled form fields, and social login section.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final isAuthenticating =
        ref.read(authViewModelProvider) is AuthStateAuthenticating;
    Log.d(
      '[LoginScreen] Sign In tapped — isAuthenticating=$isAuthenticating, validating form...',
    );
    if (_formKey.currentState!.validate()) {
      Log.d('[LoginScreen] Form valid → calling signInWithEmail');
      ref
          .read(authViewModelProvider.notifier)
          .signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
          );
    } else {
      Log.d('[LoginScreen] Form invalid → validation errors shown');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState is AuthStateAuthenticating;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Log.d('[LoginScreen] build — authState: $authState, isLoading: $isLoading');

    ref.listen<AuthState>(authViewModelProvider, (_, state) {
      if (state is AuthStateError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isDark ? AppGradients.backgroundGradient : null,
          color: isDark ? null : AppColors.lightBackground,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Logo & Branding ─────────────────────────────────
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: AppGradients.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x403DD598),
                            blurRadius: 24,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'A',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Title
                  const GradientText(
                    'Welcome to Artio',
                    style: AppTypography.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Art Made Simple',
                    style: AppTypography.bodySecondary(context),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── Form Fields ─────────────────────────────────────
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () =>
                          const ForgotPasswordRoute().push<void>(context),
                      child: const Text('Forgot Password?'),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Sign In Button ──────────────────────────────────
                  GradientButton(
                    onPressed: isLoading ? null : _handleLogin,
                    isLoading: isLoading,
                    label: 'Sign In',
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Social Login ────────────────────────────────────
                  const SocialLoginButtons(),

                  const SizedBox(height: AppSpacing.lg),

                  // ── Register Link ───────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: AppTypography.bodySecondary(context),
                      ),
                      TextButton(
                        onPressed: () =>
                            const RegisterRoute().push<void>(context),
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
