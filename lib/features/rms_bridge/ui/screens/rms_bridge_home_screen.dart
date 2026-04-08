import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../rms_auth/provider/rms_session_provider.dart';

class RmsBridgeHomeScreen extends ConsumerStatefulWidget {
  const RmsBridgeHomeScreen({super.key});

  @override
  ConsumerState<RmsBridgeHomeScreen> createState() =>
      _RmsBridgeHomeScreenState();
}

class _RmsBridgeHomeScreenState extends ConsumerState<RmsBridgeHomeScreen> {
  late final TextEditingController _userController;
  late final TextEditingController _passwordController;
  late final FocusNode _userFocusNode;
  bool _rememberMe = true;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _userController = TextEditingController();
    _passwordController = TextEditingController();
    _userFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    _userFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
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
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(rmsSessionProvider);
    final isAuthenticated = session.isAuthenticated;
    final showLogin = !isAuthenticated;

    return SingleChildScrollView(
      padding: AppInsets.pageDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BridgeHeader(
            isAuthenticated: isAuthenticated,
            fullName: session.user?.fullName,
            userName: session.user?.userName,
            emailAddress: session.user?.emailAddress,
            userId: session.user?.id,
            onLogout: isAuthenticated
                ? () async {
                    await ref.read(rmsSessionProvider.notifier).logout();
                    if (!mounted) {
                      return;
                    }
                    _userFocusNode.requestFocus();
                  }
                : null,
          ),
          const SizedBox(height: AppSpacing.s12),
          if (showLogin)
            _LoginCard(
              userController: _userController,
              passwordController: _passwordController,
              userFocusNode: _userFocusNode,
              rememberMe: _rememberMe,
              isPasswordVisible: _isPasswordVisible,
              isSubmitting: session.isSubmitting,
              errorMessage: session.errorMessage,
              onToggleRememberMe: (v) =>
                  setState(() => _rememberMe = v ?? false),
              onTogglePasswordVisibility: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
              onSubmit: session.isSubmitting ? null : _submitLogin,
              onOpenFullLogin: () => context.go('/rms-login'),
            ),
          if (isAuthenticated) ...[
            const SizedBox(height: AppSpacing.s12),
            Wrap(
              spacing: AppSpacing.s12,
              runSpacing: AppSpacing.s12,
              children: [
                _ActionCard(
                  title: AppStrings.rmsBridgeImportReservationTitle,
                  subtitle: AppStrings.rmsBridgeImportReservationSubtitle,
                  icon: Icons.download_outlined,
                  onTap: () => context.go('/rms-bridge/import'),
                ),
                _ActionCard(
                  title: AppStrings.rmsBridgeSyncClientsTitle,
                  subtitle: AppStrings.rmsBridgeSyncClientsSubtitle,
                  icon: Icons.people_outline,
                  onTap: null,
                  isEnabled: false,
                ),
                _ActionCard(
                  title: AppStrings.rmsBridgeSyncSuppliersTitle,
                  subtitle: AppStrings.rmsBridgeSyncSuppliersSubtitle,
                  icon: Icons.storefront_outlined,
                  onTap: null,
                  isEnabled: false,
                ),
                _ActionCard(
                  title: AppStrings.rmsBridgeSyncHotelsTitle,
                  subtitle: AppStrings.rmsBridgeSyncHotelsSubtitle,
                  icon: Icons.hotel_outlined,
                  onTap: null,
                  isEnabled: false,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BridgeHeader extends StatelessWidget {
  const _BridgeHeader({
    required this.isAuthenticated,
    required this.fullName,
    required this.userName,
    required this.emailAddress,
    required this.userId,
    required this.onLogout,
  });

  final bool isAuthenticated;
  final String? fullName;
  final String? userName;
  final String? emailAddress;
  final int? userId;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final statusText = isAuthenticated
        ? AppStrings.rmsBridgeSessionConnected
        : AppStrings.rmsBridgeSessionDisconnected;
    final statusColor = isAuthenticated ? AppColors.success : AppColors.danger;
    final displayName = (fullName ?? '').trim().isNotEmpty
        ? fullName!.trim()
        : (userName ?? '').trim();
    final initials = displayName.isNotEmpty
        ? displayName
              .split(RegExp(r'\s+'))
              .where((p) => p.trim().isNotEmpty)
              .take(2)
              .map((p) => p.trim().characters.first.toUpperCase())
              .join()
        : '';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.r8),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.rmsBridgeDashboardTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s6),
                      Text(
                        AppStrings.rmsBridgeDashboardSubtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isAuthenticated)
                  SizedBox(
                    height: 36,
                    child: OutlinedButton.icon(
                      onPressed: onLogout,
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text(AppStrings.rmsBridgeLogoutButton),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.s10),
            DecoratedBox(
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadii.r6),
                border: Border.all(color: statusColor.withValues(alpha: 0.25)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s10,
                  vertical: AppSpacing.s6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: statusColor),
                    const SizedBox(width: AppSpacing.s8),
                    Text(
                      statusText,
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium?.copyWith(color: statusColor),
                    ),
                  ],
                ),
              ),
            ),
            if (isAuthenticated && displayName.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primarySurfaceAlt,
                      borderRadius: BorderRadius.circular(AppRadii.r20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SizedBox(
                      height: 34,
                      width: 34,
                      child: Center(
                        child: Text(
                          initials,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.s2),
                        Wrap(
                          spacing: AppSpacing.s10,
                          runSpacing: AppSpacing.s4,
                          children: [
                            if ((emailAddress ?? '').trim().isNotEmpty)
                              Text(
                                emailAddress!.trim(),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            if ((userName ?? '').trim().isNotEmpty)
                              Text(
                                '@${userName!.trim()}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            if (userId != null)
                              Text(
                                '#$userId',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.userController,
    required this.passwordController,
    required this.userFocusNode,
    required this.rememberMe,
    required this.isPasswordVisible,
    required this.isSubmitting,
    required this.errorMessage,
    required this.onToggleRememberMe,
    required this.onTogglePasswordVisibility,
    required this.onSubmit,
    required this.onOpenFullLogin,
  });

  final TextEditingController userController;
  final TextEditingController passwordController;
  final FocusNode userFocusNode;
  final bool rememberMe;
  final bool isPasswordVisible;
  final bool isSubmitting;
  final String? errorMessage;
  final ValueChanged<bool?> onToggleRememberMe;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback? onSubmit;
  final VoidCallback onOpenFullLogin;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.r8),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.rmsBridgeRmsLoginTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onOpenFullLogin,
                  child: const Text(AppStrings.rmsBridgeOpenRmsLoginButton),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primarySurfaceAlt,
                borderRadius: BorderRadius.circular(AppRadii.r6),
                border: Border.all(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.s10),
                    Expanded(
                      child: Text(
                        AppStrings.rmsBridgeLoginRequiredMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            TextField(
              controller: userController,
              focusNode: userFocusNode,
              decoration: InputDecoration(
                hintText: AppStrings.loginUsernameHint,
                filled: true,
                fillColor: AppColors.light,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.r6),
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
              controller: passwordController,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                hintText: AppStrings.loginPasswordHint,
                filled: true,
                fillColor: AppColors.light,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.r6),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                suffixIcon: IconButton(
                  onPressed: onTogglePasswordVisibility,
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
              onSubmitted: (_) => onSubmit?.call(),
            ),
            const SizedBox(height: AppSpacing.s12),
            Row(
              children: [
                Checkbox(value: rememberMe, onChanged: onToggleRememberMe),
                Text(
                  AppStrings.loginRememberMe,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: AppSpacing.s6),
              Text(
                errorMessage!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.danger),
              ),
            ],
            const SizedBox(height: AppSpacing.s12),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.r6),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                        ),
                      )
                    : const Text(AppStrings.loginButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isEnabled = true,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.r8),
          onTap: isEnabled ? onTap : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadii.r8),
              border: Border.all(
                color: isEnabled
                    ? AppColors.border
                    : AppColors.border.withValues(alpha: 0.55),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: isEnabled
                          ? AppColors.primarySurface
                          : AppColors.light,
                      borderRadius: BorderRadius.circular(AppRadii.r8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.s10),
                      child: Icon(
                        icon,
                        color: isEnabled
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: isEnabled
                        ? AppColors.textSecondary
                        : AppColors.border,
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
