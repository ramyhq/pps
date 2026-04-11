import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/rms_api/rms_api_config.dart';
import '../../../../core/rms_api/rms_dio_provider.dart';
import '../../provider/rms_session_provider.dart';

class RmsLoginScreen extends ConsumerStatefulWidget {
  const RmsLoginScreen({super.key});

  @override
  ConsumerState<RmsLoginScreen> createState() => _RmsLoginScreenState();
}

class _RmsLoginScreenState extends ConsumerState<RmsLoginScreen> {
  late final TextEditingController _userController;
  late final TextEditingController _passwordController;
  bool _rememberMe = true;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _userController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _userController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      return;
    }
    await ref
        .read(rmsSessionProvider.notifier)
        .login(
          usernameOrEmailAddress: username,
          password: password,
          rememberMe: _rememberMe,
        );

    if (!mounted) {
      return;
    }

    final session = ref.read(rmsSessionProvider);
    if (session.isAuthenticated) {
      context.go('/rms-bridge');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(rmsRuntimeBootstrapProvider);

    final session = ref.watch(rmsSessionProvider);

    final cardWidth = MediaQuery.sizeOf(context).width >= 720 ? 500.0 : 360.0;
    const logoUrl = '$rmsBaseUrl/Common/Images/RMS-logo.svg';
    const bgUrl =
        '$rmsBaseUrl/metronic/assets/media/svg/illustrations/mecca.svg';

    return Scaffold(
      backgroundColor: AppColors.light,
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.network(
              bgUrl,
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                AppColors.light.withValues(alpha: 0.85),
                BlendMode.srcATop,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: cardWidth),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadii.r8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.s16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: SizedBox(
                              height: 70,
                              child: SvgPicture.network(
                                logoUrl,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s16),
                          Text(
                            AppStrings.loginTitle,
                            style: AppTextStyles.heading.copyWith(fontSize: 24),
                          ),
                          if (session.isAuthenticated) ...[
                            const SizedBox(height: AppSpacing.s12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => ref
                                        .read(rmsSessionProvider.notifier)
                                        .logout(),
                                    icon: const Icon(Icons.logout),
                                    label: const Text(
                                      AppStrings.rmsBridgeLogoutButton,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.s12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => context.go('/rms-bridge'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: AppColors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppRadii.r6,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      AppStrings.rmsBridgeOpenDashboardButton,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: AppSpacing.s16),
                          TextField(
                            controller: _userController,
                            decoration: InputDecoration(
                              hintText: AppStrings.loginUsernameHint,
                              filled: true,
                              fillColor: AppColors.light,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadii.r6,
                                ),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          TextField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              hintText: AppStrings.loginPasswordHint,
                              filled: true,
                              fillColor: AppColors.light,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadii.r6,
                                ),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () =>
                                      _isPasswordVisible = !_isPasswordVisible,
                                ),
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                            ),
                            onSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: AppSpacing.s12),
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (v) =>
                                    setState(() => _rememberMe = v ?? false),
                              ),
                              Text(
                                AppStrings.loginRememberMe,
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              const TextButton(
                                onPressed: null,
                                child: Text(AppStrings.loginForgotPassword),
                              ),
                            ],
                          ),
                          if (session.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.s8,
                              ),
                              child: Text(
                                session.errorMessage!,
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.danger,
                                ),
                              ),
                            ),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: session.isSubmitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.r6,
                                  ),
                                ),
                              ),
                              child: session.isSubmitting
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      AppStrings.loginButton,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
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
        ],
      ),
    );
  }
}
