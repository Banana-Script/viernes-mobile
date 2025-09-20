import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_providers.dart';

/// Professional user profile header with avatar and user information
class ProfileHeaderWidget extends ConsumerWidget {
  final UserProfile? userProfile;
  final bool isEditing;
  final VoidCallback onEditPressed;

  const ProfileHeaderWidget({
    super.key,
    required this.userProfile,
    required this.isEditing,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.viernesGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.viernesGray.withValues(alpha:0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile avatar with edit functionality
          _ProfileAvatarWidget(
            userProfile: userProfile,
            isEditing: isEditing,
          ),

          const SizedBox(height: 16),

          // User name
          Text(
            userProfile?.preferredDisplayName ?? 'User',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // User email
          if (userProfile?.email != null) ...[
            Text(
              userProfile!.email!,
              style: TextStyle(
                color: Colors.white.withValues(alpha:0.8),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],

          // Organization information
          if (userProfile?.organization?.name != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                userProfile!.organization!.name!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Role information
          if (userProfile?.role?.name != null) ...[
            Text(
              userProfile!.role!.name!,
              style: TextStyle(
                color: Colors.white.withValues(alpha:0.9),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Edit profile button
          TextButton.icon(
            onPressed: onEditPressed,
            icon: Icon(
              isEditing ? Icons.close : Icons.edit,
              color: Colors.white,
              size: 16,
            ),
            label: Text(
              isEditing ? 'Cancel' : 'Edit Profile',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha:0.2),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Profile avatar widget with edit capability
class _ProfileAvatarWidget extends ConsumerStatefulWidget {
  final UserProfile? userProfile;
  final bool isEditing;

  const _ProfileAvatarWidget({
    required this.userProfile,
    required this.isEditing,
  });

  @override
  ConsumerState<_ProfileAvatarWidget> createState() => _ProfileAvatarWidgetState();
}

class _ProfileAvatarWidgetState extends ConsumerState<_ProfileAvatarWidget> {
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _isUploading = true;
        });

        final updateAvatarUseCase = ref.read(updateUserAvatarUseCaseProvider);
        final result = await updateAvatarUseCase(File(image.path));

        result.fold(
          (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(failure.message),
                  backgroundColor: AppTheme.danger,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          (downloadUrl) {
            // Refresh user profile to show new avatar
            ref.read(userProfileProvider.notifier).refresh();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Profile photo updated successfully!'),
                  backgroundColor: AppTheme.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile photo: $e'),
            backgroundColor: AppTheme.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Avatar
        CircleAvatar(
          radius: 48,
          backgroundColor: Colors.white.withValues(alpha:0.2),
          backgroundImage: widget.userProfile?.photoURL != null
              ? NetworkImage(widget.userProfile!.photoURL!)
              : null,
          child: widget.userProfile?.photoURL == null
              ? Text(
                  widget.userProfile?.initials ?? 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                )
              : null,
        ),

        // Loading indicator
        if (_isUploading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha:0.5),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              ),
            ),
          ),

        // Edit button (only show when editing)
        if (widget.isEditing && !_isUploading)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.camera_alt,
                  color: AppTheme.viernesGray,
                  size: 16,
                ),
                onPressed: _pickAndUploadImage,
                tooltip: 'Change profile photo',
              ),
            ),
          ),
      ],
    );
  }
}

/// Settings section widget for organizing profile settings
class SettingsSectionWidget extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSectionWidget({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              title,
              style: AppTheme.headingBold.copyWith(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

/// Settings tile widget for individual settings items
class SettingsTileWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? iconColor;

  const SettingsTileWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppTheme.viernesGray,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

/// Organization info widget for displaying organization details
class OrganizationInfoWidget extends StatelessWidget {
  final UserOrganization? organization;

  const OrganizationInfoWidget({
    super.key,
    required this.organization,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (organization == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha:0.2),
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
          Row(
            children: [
              Icon(
                Icons.business,
                color: AppTheme.viernesGray,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Organization',
                style: AppTheme.headingBold.copyWith(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Organization name
          if (organization!.name != null) ...[
            _buildInfoRow(
              context,
              'Name',
              organization!.name!,
            ),
          ],

          // Organization description
          if (organization!.description != null) ...[
            _buildInfoRow(
              context,
              'Description',
              organization!.description!,
            ),
          ],

          // Organization timezone
          if (organization!.timezone != null) ...[
            _buildInfoRow(
              context,
              'Timezone',
              organization!.timezone!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status badge widget for displaying user status
class StatusBadgeWidget extends StatelessWidget {
  final UserStatus? status;

  const StatusBadgeWidget({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    if (status == null) return const SizedBox.shrink();

    final isActive = status!.isActive;
    final color = isActive ? AppTheme.success : AppTheme.danger;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha:0.3),
        ),
      ),
      child: Text(
        status!.description,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}