import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:privacy_ai/core/theme/app_colors.dart';

class PermissionSetupScreen extends StatefulWidget {
  const PermissionSetupScreen({super.key});

  @override
  State<PermissionSetupScreen> createState() => _PermissionSetupScreenState();
}

class _PermissionSetupScreenState extends State<PermissionSetupScreen> {
  final Map<String, bool> _permissions = {
    'Usage Access': false,
    'Accessibility Service': false,
    'Notification Access': false,
    'Battery Optimization': false,
  };

  @override
  Widget build(BuildContext context) {
    final allGranted = _permissions.values.every((v) => v);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permissions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/setup-questions'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device permissions',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'These permissions let the AI understand your usage patterns. '
              'All data stays on-device.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildPermissionCard(
                    context,
                    icon: Icons.bar_chart_rounded,
                    title: 'Usage Access',
                    description:
                        'See which apps you use and for how long. Core to all insights.',
                    required_: true,
                  ),
                  const SizedBox(height: 12),
                  _buildPermissionCard(
                    context,
                    icon: Icons.accessibility_new_rounded,
                    title: 'Accessibility Service',
                    description:
                        'Detect rapid app switching and compulsive patterns. '
                        'Never reads screen content.',
                    required_: true,
                  ),
                  const SizedBox(height: 12),
                  _buildPermissionCard(
                    context,
                    icon: Icons.notifications_active_rounded,
                    title: 'Notification Access',
                    description:
                        'Count notification frequency per app. '
                        'Content is never read or stored.',
                    required_: false,
                  ),
                  const SizedBox(height: 12),
                  _buildPermissionCard(
                    context,
                    icon: Icons.battery_saver_rounded,
                    title: 'Battery Optimization',
                    description:
                        'Exclude from battery optimization for reliable '
                        'background monitoring.',
                    required_: false,
                  ),
                ],
              ),
            ),
            // Privacy assurance
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.privacyBadge.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield_rounded,
                          color: AppColors.privacyBadge, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Privacy guarantee',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.privacyBadge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• No screen content is ever read\n'
                    '• No data leaves your device\n'
                    '• Revoke any permission anytime in Settings',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/onboarding-complete'),
                child: Text(allGranted ? 'Continue' : 'Continue with selected'),
              ),
            ),
            if (!allGranted) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/onboarding-complete'),
                  child: const Text('Skip for now'),
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool required_,
  }) {
    final isGranted = _permissions[title] ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isGranted
            ? AppColors.positive.withValues(alpha: 0.05)
            : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isGranted
              ? AppColors.positive.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isGranted
                  ? AppColors.positive.withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isGranted ? AppColors.positive : AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (required_) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Required',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.warning,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 34,
                  child: isGranted
                      ? OutlinedButton.icon(
                          onPressed: () {
                            setState(() => _permissions[title] = false);
                          },
                          icon: const Icon(Icons.check_rounded, size: 16),
                          label: const Text('Granted'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.positive,
                            side: BorderSide(
                              color: AppColors.positive.withValues(alpha: 0.3),
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            // In real app: launch system permission intent
                            setState(() => _permissions[title] = true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text('Grant'),
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
