import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_io/io.dart' as io;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../provider/rms_bridge_data_providers.dart';
import '../../provider/rms_bridge_supabase_sync_provider.dart';
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

  Future<void> _openLookupsDialog(_LookupKind kind) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _LookupsDialog(kind: kind),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(rmsSessionProvider);
    final isAuthenticated = session.isAuthenticated;
    final showChecking = session.isChecking;
    final showLogin = !isAuthenticated && !showChecking;

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
          if (showChecking)
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadii.r12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.s20),
                child: Row(
                  children: [
                    SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Text(
                        AppStrings.rmsBridgeCheckingSession,
                        style: TextStyle(
                          fontSize: AppFontSizes.body12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                  onTap: () => _openLookupsDialog(_LookupKind.clients),
                ),
                _ActionCard(
                  title: AppStrings.rmsBridgeSyncSuppliersTitle,
                  subtitle: AppStrings.rmsBridgeSyncSuppliersSubtitle,
                  icon: Icons.storefront_outlined,
                  onTap: () => _openLookupsDialog(_LookupKind.suppliers),
                ),
                _ActionCard(
                  title: AppStrings.rmsBridgeSyncHotelsTitle,
                  subtitle: AppStrings.rmsBridgeSyncHotelsSubtitle,
                  icon: Icons.hotel_outlined,
                  onTap: () => _openLookupsDialog(_LookupKind.hotels),
                ),
                _ActionCard(
                  title: AppStrings.rmsBridgeSyncNationalitiesTitle,
                  subtitle: AppStrings.rmsBridgeSyncNationalitiesSubtitle,
                  icon: Icons.flag_outlined,
                  onTap: () => _openLookupsDialog(_LookupKind.nationalities),
                ),
                _ActionCard(
                  title: AppStrings.rmsBridgeSyncExtraServiceTypesTitle,
                  subtitle: AppStrings.rmsBridgeSyncExtraServiceTypesSubtitle,
                  icon: Icons.miscellaneous_services_outlined,
                  onTap: () =>
                      _openLookupsDialog(_LookupKind.extraServiceTypes),
                ),
                _ActionCard(
                  title: AppStrings.rmsBridgeSyncRoutesTitle,
                  subtitle: AppStrings.rmsBridgeSyncRoutesSubtitle,
                  icon: Icons.route_outlined,
                  onTap: () => _openLookupsDialog(_LookupKind.routes),
                ),
                _ActionCard(
                  title: AppStrings.rmsBridgeSyncVehicleTypesTitle,
                  subtitle: AppStrings.rmsBridgeSyncVehicleTypesSubtitle,
                  icon: Icons.directions_car_outlined,
                  onTap: () => _openLookupsDialog(_LookupKind.vehicleTypes),
                ),
                _ActionCard(
                  title: AppStrings.rmsBridgeSyncTermsTitle,
                  subtitle: AppStrings.rmsBridgeSyncTermsSubtitle,
                  icon: Icons.description_outlined,
                  onTap: () =>
                      _openLookupsDialog(_LookupKind.termsAndConditions),
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

enum _LookupKind {
  clients,
  suppliers,
  hotels,
  nationalities,
  extraServiceTypes,
  routes,
  vehicleTypes,
  termsAndConditions,
  tripTypes,
}

typedef _LookupExportItem = ({
  String key,
  int? id,
  String? code,
  String name,
  String label,
  int? nationalityId,
});

class _LookupsDialog extends ConsumerStatefulWidget {
  const _LookupsDialog({required this.kind});

  final _LookupKind kind;

  @override
  ConsumerState<_LookupsDialog> createState() => _LookupsDialogState();
}

class _LookupsDialogState extends ConsumerState<_LookupsDialog> {
  bool _isRefreshing = false;

  Future<void> _refreshLookups() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      ref.invalidate(rmsBridgeCreateOrEditLookupsProvider(''));
      ref.invalidate(rmsBridgeAdditionalLookupsProvider);
      await ref.read(rmsBridgeCreateOrEditLookupsProvider('').future);
      await ref.read(rmsBridgeAdditionalLookupsProvider.future);
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kind = widget.kind;
    final createAsync = ref.watch(rmsBridgeCreateOrEditLookupsProvider(''));
    final additionalAsync = ref.watch(rmsBridgeAdditionalLookupsProvider);

    final itemsAsync = switch (kind) {
      _LookupKind.clients => createAsync.whenData(
        (lookups) => lookups.clients
            .map(
              (e) => (
                key: e.id.toString(),
                id: e.id,
                code: e.code,
                name: e.name,
                label: e.label,
                nationalityId: e.nationalityId,
              ),
            )
            .toList(growable: false),
      ),
      _LookupKind.suppliers => createAsync.whenData(
        (lookups) => lookups.suppliers
            .map(
              (e) => (
                key: e.id.toString(),
                id: e.id,
                code: e.code,
                name: e.name,
                label: e.label,
                nationalityId: e.nationalityId,
              ),
            )
            .toList(growable: false),
      ),
      _LookupKind.hotels => createAsync.whenData(
        (lookups) => lookups.hotels
            .map(
              (e) => (
                key: e.id.toString(),
                id: e.id,
                code: e.code,
                name: e.name,
                label: e.label,
                nationalityId: null,
              ),
            )
            .toList(growable: false),
      ),
      _LookupKind.nationalities => additionalAsync.whenData(
        (lookups) => lookups.nationalities
            .map(
              (e) => (
                key: (e.id?.toString() ?? e.key),
                id: e.id,
                code: e.code,
                name: e.name,
                label: e.label,
                nationalityId: null,
              ),
            )
            .toList(growable: false),
      ),
      _LookupKind.extraServiceTypes => additionalAsync.whenData(
        (lookups) => lookups.extraServiceTypes
            .map(
              (e) => (
                key: e.key,
                id: e.id,
                code: e.code,
                name: e.name,
                label: e.label,
                nationalityId: null,
              ),
            )
            .toList(growable: false),
      ),
      _LookupKind.routes => additionalAsync.whenData(
        (lookups) => lookups.routes
            .map(
              (e) => (
                key: e.key,
                id: e.id,
                code: e.code,
                name: e.name,
                label: e.label,
                nationalityId: null,
              ),
            )
            .toList(growable: false),
      ),
      _LookupKind.vehicleTypes => additionalAsync.whenData(
        (lookups) => lookups.vehicleTypes
            .map(
              (e) => (
                key: e.key,
                id: e.id,
                code: e.code,
                name: e.name,
                label: e.label,
                nationalityId: null,
              ),
            )
            .toList(growable: false),
      ),
      _LookupKind.termsAndConditions => additionalAsync.whenData(
        (lookups) => lookups.termsAndConditions
            .map(
              (e) => (
                key: e.key,
                id: e.id,
                code: e.code,
                name: e.name,
                label: e.label,
                nationalityId: null,
              ),
            )
            .toList(growable: false),
      ),
      _LookupKind.tripTypes => additionalAsync.whenData(
        (lookups) => lookups.tripTypes
            .map(
              (e) => (
                key: e.key,
                id: e.id,
                code: e.code,
                name: e.name,
                label: e.label,
                nationalityId: null,
              ),
            )
            .toList(growable: false),
      ),
    };

    final exportedItems = itemsAsync.asData?.value;

    return AppDialog(
      maxWidth: 560,
      title: Text(
        switch (kind) {
          _LookupKind.clients => AppStrings.rmsBridgeSyncClientsTitle,
          _LookupKind.suppliers => AppStrings.rmsBridgeSyncSuppliersTitle,
          _LookupKind.hotels => AppStrings.rmsBridgeSyncHotelsTitle,
          _LookupKind.nationalities =>
            AppStrings.rmsBridgeSyncNationalitiesTitle,
          _LookupKind.extraServiceTypes =>
            AppStrings.rmsBridgeSyncExtraServiceTypesTitle,
          _LookupKind.routes => AppStrings.rmsBridgeSyncRoutesTitle,
          _LookupKind.vehicleTypes => AppStrings.rmsBridgeSyncVehicleTypesTitle,
          _LookupKind.termsAndConditions => AppStrings.rmsBridgeSyncTermsTitle,
          _LookupKind.tripTypes => AppStrings.rmsBridgeSyncTripTypesTitle,
        },
        style: const TextStyle(
          fontSize: AppFontSizes.title14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      content: itemsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.s24),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Text(
          e.toString(),
          style: const TextStyle(
            fontSize: AppFontSizes.body12,
            color: AppColors.danger,
          ),
        ),
        data: (loadedItems) {
          final listHeight = (MediaQuery.sizeOf(context).height * 0.6).clamp(
            280.0,
            520.0,
          );

          final list = DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppRadii.r8),
            ),
            child: SizedBox(
              height: listHeight,
              child: ListView.separated(
                itemCount: loadedItems.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.border),
                itemBuilder: (_, index) {
                  final item = loadedItems[index];
                  final subtitleParts = <String>[
                    if ((item.code ?? '').trim().isNotEmpty) item.code!.trim(),
                    if (item.id != null) 'ID: ${item.id}',
                    'Key: ${item.key}',
                    if (item.nationalityId != null)
                      'Nationality: ${item.nationalityId}',
                  ];
                  return ListTile(
                    dense: true,
                    visualDensity: const VisualDensity(vertical: -4),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s12,
                    ),
                    title: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: AppFontSizes.body12,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: subtitleParts.isEmpty
                        ? null
                        : Text(
                            subtitleParts.join(' • '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: AppFontSizes.label11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                  );
                },
              ),
            ),
          );

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${AppStrings.rmsBridgeItemsCountLabel}: ${loadedItems.length}',
                      style: const TextStyle(
                        fontSize: AppFontSizes.body12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s12),
              if (_isRefreshing) ...[
                const LinearProgressIndicator(minHeight: 2),
                const SizedBox(height: AppSpacing.s10),
              ],
              Stack(
                children: [
                  list,
                  if (_isRefreshing)
                    Positioned.fill(
                      child: ColoredBox(
                        color: AppColors.white.withValues(alpha: 0.6),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
      actions: [
        OutlinedButton(
          onPressed: _isRefreshing ? null : _refreshLookups,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            backgroundColor: AppColors.tableHeader,
            minimumSize: const Size(110, AppHeights.button32),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            side: const BorderSide(color: AppColors.inputBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.r8),
            ),
          ),
          child: _isRefreshing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(AppStrings.rmsBridgeRefresh),
        ),
        OutlinedButton(
          onPressed: (exportedItems == null || exportedItems.isEmpty)
              ? null
              : () async {
                  await _exportCsv(context, kind, exportedItems);
                },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            backgroundColor: AppColors.tableHeader,
            minimumSize: const Size(130, AppHeights.button32),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            side: const BorderSide(color: AppColors.inputBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.r8),
            ),
          ),
          child: const Text(AppStrings.rmsBridgeExportExcel),
        ),
        ElevatedButton(
          onPressed: (exportedItems == null || exportedItems.isEmpty)
              ? null
              : () async {
                  await _exportJson(context, kind, exportedItems);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(130, AppHeights.button32),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.r8),
            ),
          ),
          child: const Text(AppStrings.rmsBridgeExportJson),
        ),
        OutlinedButton(
          onPressed: (exportedItems == null || exportedItems.isEmpty)
              ? null
              : () async {
                  await showDialog<void>(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => _SupabaseSyncDialog(
                      kind: kind,
                      sourceItems: exportedItems,
                    ),
                  );
                },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            backgroundColor: AppColors.tableHeader,
            minimumSize: const Size(150, AppHeights.button32),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            side: const BorderSide(color: AppColors.inputBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.r8),
            ),
          ),
          child: const Text(AppStrings.rmsBridgeSupabaseSync),
        ),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            backgroundColor: AppColors.tableHeader,
            minimumSize: const Size(110, AppHeights.button32),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            side: const BorderSide(color: AppColors.inputBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.r8),
            ),
          ),
          child: const Text(AppStrings.cancel),
        ),
      ],
    );
  }

  Future<void> _exportJson(
    BuildContext context,
    _LookupKind kind,
    List<_LookupExportItem> items,
  ) async {
    final data = items
        .map(
          (e) => <String, Object?>{
            'key': e.key,
            'id': e.id,
            'code': e.code,
            'name': e.name,
            'label': e.label,
            'nationalityId': e.nationalityId,
          },
        )
        .toList(growable: false);
    final text = const JsonEncoder.withIndent('  ').convert(data);
    final bytes = utf8.encode(text);
    await _saveBytes(
      context,
      fileName: 'rms_${_kindName(kind)}.json',
      bytes: bytes,
    );
  }

  Future<void> _exportCsv(
    BuildContext context,
    _LookupKind kind,
    List<_LookupExportItem> items,
  ) async {
    final csv = _toCsv(items);
    final bytes = utf8.encode(csv);
    await _saveBytes(
      context,
      fileName: 'rms_${_kindName(kind)}.csv',
      bytes: bytes,
    );
  }

  String _kindName(_LookupKind kind) {
    return switch (kind) {
      _LookupKind.clients => 'clients',
      _LookupKind.suppliers => 'suppliers',
      _LookupKind.hotels => 'hotels',
      _LookupKind.nationalities => 'nationalities',
      _LookupKind.extraServiceTypes => 'extra_service_types',
      _LookupKind.routes => 'routes',
      _LookupKind.vehicleTypes => 'vehicle_types',
      _LookupKind.termsAndConditions => 'terms_and_conditions',
      _LookupKind.tripTypes => 'trip_types',
    };
  }

  String _toCsv(List<_LookupExportItem> items) {
    final buffer = StringBuffer();
    buffer.writeln('key,id,code,name,label,nationalityId');
    for (final item in items) {
      buffer
        ..write(_escapeCsv(item.key))
        ..write(',')
        ..write(item.id ?? '')
        ..write(',')
        ..write(_escapeCsv(item.code ?? ''))
        ..write(',')
        ..write(_escapeCsv(item.name))
        ..write(',')
        ..write(_escapeCsv(item.label))
        ..write(',')
        ..writeln(item.nationalityId ?? '');
    }
    return buffer.toString();
  }

  String _escapeCsv(String value) {
    final normalized = value.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final needsQuotes =
        normalized.contains(',') ||
        normalized.contains('"') ||
        normalized.contains('\n');
    if (!needsQuotes) return normalized;
    final escaped = normalized.replaceAll('"', '""');
    return '"$escaped"';
  }

  Future<void> _saveBytes(
    BuildContext context, {
    required String fileName,
    required List<int> bytes,
  }) async {
    if (kIsWeb) {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
      return;
    }

    final extension = _fileExtension(fileName);
    final outputFile = await FilePicker.saveFile(
      dialogTitle: AppStrings.saveFileDialogTitle,
      fileName: fileName,
      type: extension == null ? FileType.any : FileType.custom,
      allowedExtensions: extension == null ? null : [extension],
    );
    if (outputFile == null) {
      return;
    }
    await io.File(outputFile).writeAsBytes(bytes);
  }

  String? _fileExtension(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot <= 0 || dot == fileName.length - 1) {
      return null;
    }
    final ext = fileName.substring(dot + 1).trim();
    if (ext.isEmpty) return null;
    return ext;
  }
}

class _SupabaseSyncDialog extends ConsumerStatefulWidget {
  const _SupabaseSyncDialog({required this.kind, required this.sourceItems});

  final _LookupKind kind;
  final List<_LookupExportItem> sourceItems;

  @override
  ConsumerState<_SupabaseSyncDialog> createState() =>
      _SupabaseSyncDialogState();
}

class _SupabaseSyncDialogState extends ConsumerState<_SupabaseSyncDialog> {
  late final List<RmsBridgeSupabaseSyncCandidate> _candidates;
  late final RmsBridgeSupabaseSyncRequest _request;
  bool _isRefreshing = false;

  RmsBridgeSupabaseSyncTarget _supabaseTargetForKind(_LookupKind kind) {
    return switch (kind) {
      _LookupKind.clients => const RmsBridgeSupabaseSyncTarget(
        tableName: 'clients',
        mode: RmsBridgeSupabaseSyncMode.codeBased,
      ),
      _LookupKind.suppliers => const RmsBridgeSupabaseSyncTarget(
        tableName: 'suppliers',
        mode: RmsBridgeSupabaseSyncMode.codeBased,
      ),
      _LookupKind.hotels => const RmsBridgeSupabaseSyncTarget(
        tableName: 'hotels',
        mode: RmsBridgeSupabaseSyncMode.codeBased,
      ),
      _LookupKind.nationalities => const RmsBridgeSupabaseSyncTarget(
        tableName: 'nationalities',
        mode: RmsBridgeSupabaseSyncMode.keyBased,
        identifierField: 'id',
        labelField: 'name',
      ),
      _LookupKind.extraServiceTypes => const RmsBridgeSupabaseSyncTarget(
        tableName: 'reservation_service_types',
        mode: RmsBridgeSupabaseSyncMode.keyBased,
      ),
      _LookupKind.routes => const RmsBridgeSupabaseSyncTarget(
        tableName: 'routes',
        mode: RmsBridgeSupabaseSyncMode.keyBased,
      ),
      _LookupKind.vehicleTypes => const RmsBridgeSupabaseSyncTarget(
        tableName: 'vehicle_types',
        mode: RmsBridgeSupabaseSyncMode.keyBased,
      ),
      _LookupKind.termsAndConditions => const RmsBridgeSupabaseSyncTarget(
        tableName: 'terms_and_conditions',
        mode: RmsBridgeSupabaseSyncMode.keyBased,
      ),
      _LookupKind.tripTypes => const RmsBridgeSupabaseSyncTarget(
        tableName: 'trip_types',
        mode: RmsBridgeSupabaseSyncMode.keyBased,
      ),
    };
  }

  @override
  void initState() {
    super.initState();
    _candidates = widget.sourceItems
        .map(
          (e) => RmsBridgeSupabaseSyncCandidate(
            key: e.key,
            code: e.code,
            name: e.name,
            label: e.label,
          ),
        )
        .toList(growable: false);
    _request = RmsBridgeSupabaseSyncRequest(
      target: _supabaseTargetForKind(widget.kind),
      candidates: _candidates,
    );
  }

  Future<bool> _confirmSync(
    BuildContext context,
    RmsBridgeSupabaseSyncPreview preview,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AppDialog(
          maxWidth: 520,
          title: const Text(
            AppStrings.rmsBridgeSupabaseSyncConfirmTitle,
            style: TextStyle(
              fontSize: AppFontSizes.title14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppStrings.rmsBridgeSupabaseSyncConfirmMessage,
                style: TextStyle(
                  fontSize: AppFontSizes.body12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s10),
              Text(
                '${AppStrings.rmsBridgeSupabaseInsertLabel}: ${preview.insertCount}',
                style: const TextStyle(
                  fontSize: AppFontSizes.body12,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.s6),
              Text(
                '${AppStrings.rmsBridgeSupabaseUpdateLabel}: ${preview.updateCount}',
                style: const TextStyle(
                  fontSize: AppFontSizes.body12,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.s6),
              Text(
                '${AppStrings.rmsBridgeSupabaseSkipLabel}: ${preview.skipCount}',
                style: const TextStyle(
                  fontSize: AppFontSizes.body12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text(AppStrings.rmsBridgeSupabaseApplySyncButton),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _showSyncResult(
    BuildContext context,
    RmsBridgeSupabaseSyncApplyResult result,
  ) async {
    final failureItems = result.failureItems;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AppDialog(
          maxWidth: 520,
          title: const Text(
            AppStrings.rmsBridgeSupabaseSyncResultTitle,
            style: TextStyle(
              fontSize: AppFontSizes.title14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${AppStrings.rmsBridgeSupabaseInsertLabel}: ${result.inserted}',
                style: const TextStyle(
                  fontSize: AppFontSizes.body12,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.s6),
              Text(
                '${AppStrings.rmsBridgeSupabaseUpdateLabel}: ${result.updated}',
                style: const TextStyle(
                  fontSize: AppFontSizes.body12,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.s6),
              Text(
                '${AppStrings.rmsBridgeSupabaseSkipLabel}: ${result.skipped}',
                style: const TextStyle(
                  fontSize: AppFontSizes.body12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.s6),
              Text(
                '${AppStrings.rmsBridgeSupabaseErrorsLabel}: ${result.errors}',
                style: TextStyle(
                  fontSize: AppFontSizes.body12,
                  color: result.errors > 0
                      ? AppColors.danger
                      : AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (failureItems.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.s10),
                const Text(
                  AppStrings.rmsBridgeSupabaseSampleErrorsLabel,
                  style: TextStyle(
                    fontSize: AppFontSizes.body12,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.s6),
                for (final item in failureItems)
                  _SupabaseSyncChangeRow(
                    name: item.name,
                    code: (item.identifier ?? '').trim().isEmpty
                        ? null
                        : item.identifier,
                    dotColor: AppColors.danger,
                    badgeLabel: AppStrings.rmsBridgeSupabaseErrorLabel,
                    badgeTooltip: item.message,
                  ),
              ],
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppStrings.close),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final kind = widget.kind;
    final modelName = switch (kind) {
      _LookupKind.clients => AppStrings.rmsBridgeModelClients,
      _LookupKind.suppliers => AppStrings.rmsBridgeModelSuppliers,
      _LookupKind.hotels => AppStrings.rmsBridgeModelHotels,
      _LookupKind.nationalities => AppStrings.rmsBridgeModelNationalities,
      _LookupKind.extraServiceTypes =>
        AppStrings.rmsBridgeModelExtraServiceTypes,
      _LookupKind.routes => AppStrings.rmsBridgeModelRoutes,
      _LookupKind.vehicleTypes => AppStrings.rmsBridgeModelVehicleTypes,
      _LookupKind.termsAndConditions =>
        AppStrings.rmsBridgeModelTermsAndConditions,
      _LookupKind.tripTypes => AppStrings.rmsBridgeModelTripTypes,
    };
    final previewAsync = ref.watch(
      rmsBridgeSupabaseSyncPreviewProvider(_request),
    );
    final applyState = ref.watch(rmsBridgeSupabaseSyncApplyProvider);

    return AppDialog(
      maxWidth: 620,
      title: Text(
        '${AppStrings.rmsBridgeSupabaseSyncDialogTitle} - $modelName',
        style: const TextStyle(
          fontSize: AppFontSizes.title14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      content: previewAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.s24),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Text(
          e.toString(),
          style: const TextStyle(
            fontSize: AppFontSizes.body12,
            color: AppColors.danger,
          ),
        ),
        data: (preview) {
          String formatDate(DateTime? value) {
            if (value == null) return '—';
            return DateFormat('yyyy-MM-dd HH:mm').format(value.toLocal());
          }

          final codeUniqueValue = preview.isCodeUniqueLikely ? 'Yes' : 'No';
          final failedByKey = <String, String>{};
          final lastFailureItems =
              applyState.lastResult?.failureItems ?? const [];
          for (final item in lastFailureItems) {
            final identifier = (item.identifier ?? '').trim();
            final key = identifier.isNotEmpty
                ? 'i:$identifier'
                : 'n:${item.name.trim().toLowerCase()}';
            failedByKey[key] = item.message;
          }

          final body = LayoutBuilder(
            builder: (context, constraints) {
              final fallbackHeight = (MediaQuery.sizeOf(context).height * 0.72)
                  .clamp(360.0, 620.0);
              final maxWidth = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : 620.0;
              final dialogHeight = constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : fallbackHeight;
              final headerMaxHeight = (dialogHeight * 0.45).clamp(160.0, 280.0);
              final metricCellWidth = ((maxWidth - (AppSpacing.s12 * 3)) / 4)
                  .clamp(120.0, 220.0);

              final header = SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: AppSpacing.s12,
                      runSpacing: AppSpacing.s8,
                      children: [
                        _SupabaseSyncMetricCell(
                          width: metricCellWidth,
                          label: AppStrings.rmsBridgeSupabaseTableLabel,
                          value: preview.tableName,
                          tooltip: AppStrings.rmsBridgeSupabaseTableTooltip,
                        ),
                        _SupabaseSyncMetricCell(
                          width: metricCellWidth,
                          label: AppStrings.rmsBridgeSupabaseRecordsLabel,
                          value: '${preview.supabaseItemsCount}',
                          tooltip: AppStrings.rmsBridgeSupabaseRecordsTooltip,
                        ),
                        _SupabaseSyncMetricCell(
                          width: metricCellWidth,
                          label:
                              AppStrings.rmsBridgeSupabasePendingRecordsLabel,
                          value: '${preview.pendingCount}',
                          tooltip:
                              AppStrings.rmsBridgeSupabasePendingRecordsTooltip,
                        ),
                        _SupabaseSyncMetricCell(
                          width: metricCellWidth,
                          label: AppStrings.rmsBridgeSupabaseLastSyncUserLabel,
                          value: preview.lastSyncUser,
                          tooltip:
                              AppStrings.rmsBridgeSupabaseLastSyncUserTooltip,
                        ),
                        _SupabaseSyncMetricCell(
                          width: metricCellWidth,
                          label: AppStrings.rmsBridgeSupabaseLastSyncAtLabel,
                          value: formatDate(preview.lastSyncAt),
                          tooltip:
                              AppStrings.rmsBridgeSupabaseLastSyncAtTooltip,
                        ),
                        _SupabaseSyncMetricCell(
                          width: metricCellWidth,
                          label: AppStrings.rmsBridgeSupabaseLatestRowAtLabel,
                          value: formatDate(preview.latestRowCreatedAt),
                          tooltip:
                              AppStrings.rmsBridgeSupabaseLatestRowAtTooltip,
                        ),
                        _SupabaseSyncMetricCell(
                          width: metricCellWidth,
                          label: AppStrings.rmsBridgeSupabaseInsertLabel,
                          value: '${preview.insertCount}',
                          tooltip: AppStrings.rmsBridgeSupabaseInsertTooltip,
                        ),
                        _SupabaseSyncMetricCell(
                          width: metricCellWidth,
                          label: AppStrings.rmsBridgeSupabaseUpdateLabel,
                          value: '${preview.updateCount}',
                          tooltip: AppStrings.rmsBridgeSupabaseUpdateTooltip,
                        ),
                        _SupabaseSyncMetricCell(
                          width: metricCellWidth,
                          label: AppStrings.rmsBridgeSupabaseSkipLabel,
                          value: '${preview.skipCount}',
                          tooltip: AppStrings.rmsBridgeSupabaseSkipTooltip,
                        ),
                        _SupabaseSyncMetricCell(
                          width: metricCellWidth,
                          label: AppStrings.rmsBridgeSupabaseConflictsLabel,
                          value: '${preview.conflictsCount}',
                          tooltip: AppStrings.rmsBridgeSupabaseConflictsTooltip,
                        ),
                        _SupabaseSyncMetricCell(
                          width: metricCellWidth,
                          label: AppStrings.rmsBridgeSupabaseCodeUniqueLabel,
                          value: codeUniqueValue,
                          tooltip:
                              AppStrings.rmsBridgeSupabaseCodeUniqueTooltip,
                        ),
                        _SupabaseSyncMetricCell(
                          width: metricCellWidth,
                          label: AppStrings.rmsBridgeSupabaseNullCodesLabel,
                          value: '${preview.nullCodesCount}',
                          tooltip: AppStrings.rmsBridgeSupabaseNullCodesTooltip,
                        ),
                        _SupabaseSyncMetricCell(
                          width: metricCellWidth,
                          label:
                              AppStrings.rmsBridgeSupabaseDuplicateCodesLabel,
                          value: '${preview.duplicateCodesCount}',
                          tooltip:
                              AppStrings.rmsBridgeSupabaseDuplicateCodesTooltip,
                        ),
                      ],
                    ),
                  ],
                ),
              );

              final entries = <_SupabaseSyncListEntry>[
                if (preview.issueItems.isNotEmpty)
                  const _SupabaseSyncListEntry.header(
                    AppStrings.rmsBridgeSupabaseIssuesSectionTitle,
                  ),
                for (final issue in preview.issueItems)
                  _SupabaseSyncListEntry.issue(issue),
                const _SupabaseSyncListEntry.header(
                  AppStrings.rmsBridgeSupabasePendingSectionTitle,
                ),
                if (preview.pendingItems.isEmpty)
                  const _SupabaseSyncListEntry.message(
                    AppStrings.rmsBridgeSupabaseNoPendingRecords,
                  )
                else
                  for (final item in preview.pendingItems)
                    _SupabaseSyncListEntry.pending(item),
              ];

              final listSection = DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppRadii.r8),
                ),
                child: ListView.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, index) {
                    final current = entries[index];
                    final next = entries[index + 1];
                    if (current.isHeader || next.isHeader) {
                      return const SizedBox(height: 0);
                    }
                    return const Divider(height: 1, color: AppColors.border);
                  },
                  itemBuilder: (_, index) {
                    final entry = entries[index];
                    if (entry.header != null) {
                      final titleColor =
                          entry.header ==
                              AppStrings.rmsBridgeSupabaseIssuesSectionTitle
                          ? AppColors.danger
                          : AppColors.textPrimary;
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.s12,
                          AppSpacing.s10,
                          AppSpacing.s12,
                          AppSpacing.s6,
                        ),
                        child: Text(
                          entry.header!,
                          style: TextStyle(
                            fontSize: AppFontSizes.body12,
                            color: titleColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );
                    }

                    if (entry.message != null) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.s12,
                          AppSpacing.s6,
                          AppSpacing.s12,
                          AppSpacing.s12,
                        ),
                        child: Text(
                          entry.message!,
                          style: const TextStyle(
                            fontSize: AppFontSizes.body12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }

                    final pendingItem = entry.pendingItem;
                    if (pendingItem != null) {
                      final identifier = (pendingItem.identifier ?? '').trim();
                      final isUpdate =
                          pendingItem.action ==
                          RmsBridgeSupabaseSyncAction.update;
                      final key = identifier.isNotEmpty
                          ? 'i:$identifier'
                          : 'n:${pendingItem.name.trim().toLowerCase()}';
                      final failureMessage = failedByKey[key];
                      final dotColor = failureMessage != null
                          ? AppColors.danger
                          : (isUpdate ? AppColors.warning : AppColors.success);
                      final badgeLabel = failureMessage != null
                          ? AppStrings.rmsBridgeSupabaseErrorLabel
                          : (isUpdate
                                ? AppStrings.rmsBridgeSupabaseUpdateLabel
                                : AppStrings.rmsBridgeSupabaseInsertLabel);
                      final badgeTooltip =
                          failureMessage ??
                          (isUpdate
                              ? [
                                  AppStrings
                                      .rmsBridgeSupabaseUpdateActionTooltip,
                                  '${AppStrings.rmsBridgeSupabaseTooltipFieldLabel}: ${AppStrings.rmsBridgeSupabaseFieldName}',
                                  '${AppStrings.rmsBridgeSupabaseTooltipFromLabel}: ${pendingItem.existingName ?? '—'}',
                                  '${AppStrings.rmsBridgeSupabaseTooltipToLabel}: ${pendingItem.name}',
                                ].join('\n')
                              : [
                                  AppStrings
                                      .rmsBridgeSupabaseInsertActionTooltip,
                                  if (identifier.isNotEmpty) identifier,
                                ].join('\n'));
                      return _SupabaseSyncChangeRow(
                        name: pendingItem.name,
                        code: identifier.isEmpty ? null : identifier,
                        dotColor: dotColor,
                        badgeLabel: badgeLabel,
                        badgeTooltip: badgeTooltip,
                      );
                    }

                    final issueItem = entry.issueItem!;
                    final identifier = (issueItem.identifier ?? '').trim();
                    return _SupabaseSyncChangeRow(
                      name: issueItem.name,
                      code: identifier.isEmpty ? null : identifier,
                      dotColor: AppColors.danger,
                      badgeLabel: AppStrings.rmsBridgeSupabaseConflictLabel,
                      badgeTooltip: [
                        AppStrings.rmsBridgeSupabaseConflictActionTooltip,
                        issueItem.reason,
                      ].join('\n'),
                    );
                  },
                ),
              );

              return SizedBox(
                height: dialogHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: headerMaxHeight),
                      child: header,
                    ),
                    const SizedBox(height: AppSpacing.s10),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: AppSpacing.s10),
                    Expanded(child: listSection),
                  ],
                ),
              );
            },
          );
          return Stack(
            children: [
              body,
              if (_isRefreshing)
                Positioned.fill(
                  child: ColoredBox(
                    color: AppColors.white.withValues(alpha: 0.6),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          );
        },
      ),
      actions: [
        OutlinedButton(
          onPressed: _isRefreshing
              ? null
              : () async {
                  setState(() => _isRefreshing = true);
                  try {
                    final _ = await ref.refresh(
                      rmsBridgeSupabaseSyncPreviewProvider(_request).future,
                    );
                  } finally {
                    if (mounted) setState(() => _isRefreshing = false);
                  }
                },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            backgroundColor: AppColors.tableHeader,
            minimumSize: const Size(110, AppHeights.button32),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            side: const BorderSide(color: AppColors.inputBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.r8),
            ),
          ),
          child: _isRefreshing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(AppStrings.rmsBridgeRefresh),
        ),
        Builder(
          builder: (context) {
            final tooltipMessage = previewAsync.maybeWhen(
              data: (preview) {
                if (applyState.isSyncing) return '';
                if (!preview.isSupabaseConfigured) {
                  return preview.configurationIssue ??
                      AppStrings.rmsBridgeSupabaseNotConfiguredHint;
                }
                if (preview.issueItems.isNotEmpty) {
                  return AppStrings.rmsBridgeSupabaseSyncDisabledIssuesTooltip;
                }
                if (preview.pendingItems.isEmpty) {
                  return AppStrings
                      .rmsBridgeSupabaseSyncDisabledNoChangesTooltip;
                }
                return '';
              },
              orElse: () => '',
            );

            final isDisabled = previewAsync.maybeWhen(
              data: (preview) =>
                  applyState.isSyncing ||
                  !preview.isSupabaseConfigured ||
                  preview.issueItems.isNotEmpty ||
                  preview.pendingItems.isEmpty,
              orElse: () => true,
            );

            return Tooltip(
              message: tooltipMessage,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: previewAsync.maybeWhen(
                      data: (preview) {
                        if (isDisabled) return null;
                        return () async {
                          final confirmed = await _confirmSync(
                            context,
                            preview,
                          );
                          if (!context.mounted) return;
                          if (!confirmed) return;
                          final result = await ref
                              .read(rmsBridgeSupabaseSyncApplyProvider.notifier)
                              .apply(_request);
                          if (!context.mounted) return;
                          if (result != null) {
                            ref.invalidate(
                              rmsBridgeSupabaseSyncPreviewProvider(_request),
                            );
                            await _showSyncResult(context, result);
                          }
                        };
                      },
                      orElse: () => null,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(130, AppHeights.button32),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.r8),
                      ),
                    ),
                    child: applyState.isSyncing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            AppStrings.rmsBridgeSupabaseApplySyncButton,
                          ),
                  ),
                  if (!applyState.isSyncing &&
                      isDisabled &&
                      tooltipMessage.trim().isNotEmpty) ...[
                    const SizedBox(width: AppSpacing.s10),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final message = tooltipMessage.trim();
                        if (message.isEmpty) return;
                        await Clipboard.setData(ClipboardData(text: message));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              AppStrings.rmsBridgeCopiedToClipboard,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        backgroundColor: AppColors.tableHeader,
                        minimumSize: const Size(140, AppHeights.button32),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s12,
                        ),
                        side: const BorderSide(color: AppColors.inputBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.r8),
                        ),
                      ),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text(AppStrings.rmsBridgeCopyError),
                    ),
                  ],
                  if (applyState.isSyncing) ...[
                    const SizedBox(width: AppSpacing.s10),
                    const Text(
                      AppStrings.rmsBridgeSupabaseSyncingInlineMessage,
                      style: TextStyle(
                        fontSize: AppFontSizes.label11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            backgroundColor: AppColors.tableHeader,
            minimumSize: const Size(110, AppHeights.button32),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            side: const BorderSide(color: AppColors.inputBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.r8),
            ),
          ),
          child: const Text(AppStrings.close),
        ),
      ],
    );
  }
}

class _SupabaseSyncMetricCell extends StatelessWidget {
  const _SupabaseSyncMetricCell({
    required this.width,
    required this.label,
    required this.value,
    required this.tooltip,
  });

  final double width;
  final String label;
  final String value;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Tooltip(
        message: tooltip,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: AppFontSizes.label11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: AppFontSizes.body12,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupabaseSyncListEntry {
  final String? header;
  final String? message;
  final RmsBridgeSupabaseSyncPlannedItem? pendingItem;
  final RmsBridgeSupabaseSyncIssueItem? issueItem;

  const _SupabaseSyncListEntry.header(this.header)
    : message = null,
      pendingItem = null,
      issueItem = null;

  const _SupabaseSyncListEntry.message(this.message)
    : header = null,
      pendingItem = null,
      issueItem = null;

  const _SupabaseSyncListEntry.pending(this.pendingItem)
    : header = null,
      message = null,
      issueItem = null;

  const _SupabaseSyncListEntry.issue(this.issueItem)
    : header = null,
      message = null,
      pendingItem = null;

  bool get isHeader => header != null;
}

class _SupabaseSyncChangeRow extends StatelessWidget {
  const _SupabaseSyncChangeRow({
    required this.name,
    required this.code,
    required this.dotColor,
    required this.badgeLabel,
    required this.badgeTooltip,
  });

  final String name;
  final String? code;
  final Color dotColor;
  final String badgeLabel;
  final String badgeTooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s10,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppFontSizes.body12,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (code != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    code!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: AppFontSizes.label11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Tooltip(
            message: badgeTooltip,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: dotColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const SizedBox(width: 10, height: 10),
                ),
                const SizedBox(width: AppSpacing.s6),
                Text(
                  badgeLabel,
                  style: TextStyle(
                    fontSize: AppFontSizes.label11,
                    color: dotColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
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
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.r8),
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadii.r8),
              border: Border.all(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(AppRadii.r8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.s10),
                      child: Icon(icon, color: AppColors.primary, size: 22),
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
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
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
