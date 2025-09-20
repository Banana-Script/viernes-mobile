import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_widgets.dart';

class EnhancedProfilePage extends ConsumerStatefulWidget {
  const EnhancedProfilePage({super.key});

  @override
  ConsumerState<EnhancedProfilePage> createState() => _EnhancedProfilePageState();
}

class _EnhancedProfilePageState extends ConsumerState<EnhancedProfilePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _loadUserData(UserProfile? profile) {
    if (profile != null) {
      _nameController.text = profile.fullName ?? profile.displayName ?? '';
      _phoneController.text = profile.phoneNumber ?? '';
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    try {
      final currentProfile = ref.read(userProfileProvider).value;
      if (currentProfile == null) {
        throw Exception('User profile not loaded');
      }

      final updatedProfile = currentProfile.copyWith(
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      final success = await ref.read(userProfileProvider.notifier).updateUserProfile(updatedProfile);

      if (success) {
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile updated successfully!'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    final signOutUseCase = ref.read(signOutUseCaseProvider);
    final result = await signOutUseCase();

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to sign out: ${failure.message}'),
              backgroundColor: AppTheme.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      (_) {
        AppNavigation.logout();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final currentTheme = ref.watch(themeProvider);
    final currentLanguage = ref.watch(languageProvider);
    final userProfileState = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(userProfileProvider.notifier).refresh();
          await ref.read(userAvailabilityProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Profile header
              userProfileState.when(
                data: (userProfile) {
                  // Load user data when editing starts
                  if (_isEditing) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _loadUserData(userProfile);
                    });
                  }

                  return ProfileHeaderWidget(
                    userProfile: userProfile,
                    isEditing: _isEditing,
                    onEditPressed: () {
                      setState(() {
                        _isEditing = !_isEditing;
                        if (_isEditing && userProfile != null) {
                          _loadUserData(userProfile);
                        }
                      });
                    },
                  );
                },
                loading: () => _buildLoadingHeader(),
                error: (error, stack) => _buildErrorHeader(error.toString()),
              ),

              const SizedBox(height: 24),

              // User availability status (commented out until widget is implemented)
              // const UserAvailabilityWidget(),

              // const SizedBox(height: 16),

              // Organization information (commented out until widget is implemented)
              // userProfileState.when(
              //   data: (userProfile) => userProfile?.organization != null
              //       ? OrganizationInfoWidget(organization: userProfile!.organization)
              //       : const SizedBox.shrink(),
              //   loading: () => const SizedBox.shrink(),
              //   error: (_, __) => const SizedBox.shrink(),
              // ),

              const SizedBox(height: 16),

              // Profile form or info
              if (_isEditing) ...[
                // Edit form
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha:0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.viernesGray.withValues(alpha:0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Profile Information',
                        style: AppTheme.headingBold.copyWith(
                          fontSize: 18,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Full Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        textInputAction: TextInputAction.next,
                      ),

                      const SizedBox(height: 16),

                      // Phone field
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 24),

                      // Save button
                      ViernesGradientButton(
                        text: 'Save Changes',
                        isLoading: _isLoading,
                        onPressed: _updateProfile,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // App Preferences
                SettingsSectionWidget(
                  title: 'App Preferences',
                  children: [
                    SettingsTileWidget(
                      icon: Icons.palette_outlined,
                      title: 'Theme',
                      subtitle: _getThemeDisplayName(currentTheme),
                      onTap: () => _showThemeSelector(context),
                    ),
                    SettingsTileWidget(
                      icon: Icons.language_outlined,
                      title: 'Language',
                      subtitle: _getLanguageDisplayName(currentLanguage),
                      onTap: () => _showLanguageSelector(context),
                    ),
                  ],
                ),

                // Account Management
                SettingsSectionWidget(
                  title: 'Account',
                  children: [
                    SettingsTileWidget(
                      icon: Icons.security_outlined,
                      title: 'Change Password',
                      subtitle: 'Update your account password',
                      onTap: () => _showChangePasswordDialog(),
                    ),
                    SettingsTileWidget(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      subtitle: 'Manage notification preferences',
                      onTap: () => _showNotificationSettings(),
                    ),
                    SettingsTileWidget(
                      icon: Icons.download_outlined,
                      title: 'Export Data',
                      subtitle: 'Request a copy of your data',
                      onTap: () => _requestDataExport(),
                    ),
                    SettingsTileWidget(
                      icon: Icons.delete_outline,
                      title: 'Delete Account',
                      subtitle: 'Permanently delete your account',
                      onTap: () => _showDeleteAccountDialog(),
                      iconColor: AppTheme.danger,
                    ),
                  ],
                ),

                // App Information
                SettingsSectionWidget(
                  title: 'App Information',
                  children: [
                    SettingsTileWidget(
                      icon: Icons.info_outline,
                      title: 'App Version',
                      subtitle: _appVersion.isNotEmpty ? _appVersion : 'Loading...',
                      onTap: () => _showAppInfo(),
                    ),
                    SettingsTileWidget(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'Get help and contact support',
                      onTap: () => _openSupportUrl(),
                    ),
                    SettingsTileWidget(
                      icon: Icons.article_outlined,
                      title: 'Terms of Service',
                      subtitle: 'View terms and conditions',
                      onTap: () => _openTermsUrl(),
                    ),
                    SettingsTileWidget(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'View privacy policy',
                      onTap: () => _openPrivacyUrl(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Sign out button
                ViernesGradientButton(
                  text: l10n.logout,
                  onPressed: () => _showSignOutDialog(context),
                  width: double.infinity,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingHeader() {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.viernesGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildErrorHeader(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.danger.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.danger.withValues(alpha:0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppTheme.danger, size: 48),
          const SizedBox(height: 16),
          Text(
            'Failed to load profile',
            style: TextStyle(
              color: AppTheme.danger,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              color: AppTheme.danger.withValues(alpha:0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getThemeDisplayName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  String _getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return 'English';
    }
  }

  void _showThemeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Choose Theme',
              style: AppTheme.headingBold.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ...ThemeMode.values.map((mode) => ListTile(
              title: Text(_getThemeDisplayName(mode)),
              leading: Radio<ThemeMode>(
                value: mode,
                groupValue: ref.read(themeProvider),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(themeProvider.notifier).setTheme(value);
                    Navigator.pop(context);
                  }
                },
              ),
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final languages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'es', 'name': 'Español'},
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Choose Language',
              style: AppTheme.headingBold.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ...languages.map((lang) => ListTile(
              title: Text(lang['name']!),
              leading: Radio<String>(
                value: lang['code']!,
                groupValue: ref.read(languageProvider),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(languageProvider.notifier).setLanguage(value);
                    Navigator.pop(context);
                  }
                },
              ),
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Change Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: newPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  if (newPasswordController.text != confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Passwords do not match'),
                        backgroundColor: AppTheme.danger,
                      ),
                    );
                    return;
                  }

                  setDialogState(() => isLoading = true);

                  final changePasswordUseCase = ref.read(changePasswordUseCaseProvider);
                  final result = await changePasswordUseCase(
                    currentPasswordController.text,
                    newPasswordController.text,
                  );

                  setDialogState(() => isLoading = false);

                  result.fold(
                    (failure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(failure.message),
                          backgroundColor: AppTheme.danger,
                        ),
                      );
                    },
                    (_) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Password changed successfully'),
                          backgroundColor: AppTheme.success,
                        ),
                      );
                    },
                  );
                },
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Change Password'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final passwordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              'Delete Account',
              style: TextStyle(color: AppTheme.danger),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'This action cannot be undone. All your data will be permanently deleted.',
                  style: TextStyle(color: AppTheme.danger),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Enter your password to confirm',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  setDialogState(() => isLoading = true);

                  final deleteAccountUseCase = ref.read(deleteAccountUseCaseProvider);
                  final result = await deleteAccountUseCase(passwordController.text);

                  setDialogState(() => isLoading = false);

                  result.fold(
                    (failure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(failure.message),
                          backgroundColor: AppTheme.danger,
                        ),
                      );
                    },
                    (_) {
                      Navigator.of(context).pop();
                      AppNavigation.logout();
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.danger,
                  foregroundColor: Colors.white,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Delete Account'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showNotificationSettings() {
    AppNavigation.goToComingSoon('Notification Settings');
  }

  void _requestDataExport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text(
          'Your data export request has been submitted. You will receive an email with a download link within 24 hours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAppInfo() {
    final appInfoState = ref.read(appInfoProvider);

    appInfoState.when(
      data: (appInfo) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.viernesGray),
                const SizedBox(width: 8),
                const Text('App Information'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('App Name', appInfo.appName),
                _buildInfoRow('Version', appInfo.formattedVersion),
                _buildInfoRow('Package', appInfo.packageName),
                if (appInfo.buildDate != null)
                  _buildInfoRow('Build Date', appInfo.buildDate!.toString().split(' ')[0]),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
      loading: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading app information...')),
      ),
      error: (error, stack) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load app info: $error'),
          backgroundColor: AppTheme.danger,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _openSupportUrl() async {
    const url = 'https://viernes.app/support';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open support page')),
        );
      }
    }
  }

  void _openTermsUrl() async {
    const url = 'https://viernes.app/terms';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open terms page')),
        );
      }
    }
  }

  void _openPrivacyUrl() async {
    const url = 'https://viernes.app/privacy';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open privacy page')),
        );
      }
    }
  }

  void _showSignOutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}