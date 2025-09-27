import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppConstants.appName,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showSignOutDialog(context),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppConstants.largePadding),

                  // User info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome!',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppConstants.smallPadding),

                          if (user != null) ...[
                            _InfoRow(
                              label: 'Email',
                              value: user.email,
                            ),
                            const SizedBox(height: AppConstants.smallPadding),

                            if (user.displayName != null)
                              _InfoRow(
                                label: 'Name',
                                value: user.displayName!,
                              ),

                            const SizedBox(height: AppConstants.smallPadding),
                            _InfoRow(
                              label: 'User ID',
                              value: user.uid,
                            ),

                            const SizedBox(height: AppConstants.smallPadding),
                            Row(
                              children: [
                                Text(
                                  'Email Verified: ',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  user.emailVerified ? Icons.check_circle : Icons.cancel,
                                  color: user.emailVerified
                                      ? Colors.green
                                      : Theme.of(context).colorScheme.error,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  user.emailVerified ? 'Yes' : 'No',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: user.emailVerified
                                        ? Colors.green
                                        : Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.largePadding),

                  // Welcome message
                  Text(
                    'You have successfully signed in to ${AppConstants.appName}!',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppConstants.defaultPadding),

                  Text(
                    'This is your home screen where you can access all the app features.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),

                  // Sign out button
                  AuthButton(
                    text: 'Sign Out',
                    isOutlined: true,
                    isLoading: authProvider.status == AuthStatus.loading,
                    onPressed: () => _showSignOutDialog(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthProvider>().signOut();
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}