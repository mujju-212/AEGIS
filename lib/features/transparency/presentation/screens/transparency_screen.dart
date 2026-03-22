import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacy_ai/core/theme/app_colors.dart';

class TransparencyScreen extends ConsumerWidget {
  const TransparencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Data',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Full transparency — see everything stored on your device',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Storage overview
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _StorageOverviewCard(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Data categories
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'What\'s stored',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _DataCategoryCard(
                  icon: Icons.bar_chart_rounded,
                  title: 'Usage Events',
                  description: 'App opens, screen time, pickups',
                  count: '2,847 events',
                  size: '1.2 MB',
                  color: AppColors.primary,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _DataCategoryCard(
                  icon: Icons.pattern_rounded,
                  title: 'Detected Patterns',
                  description: 'Habit loops, compulsive behaviors',
                  count: '12 patterns',
                  size: '48 KB',
                  color: AppColors.warning,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _DataCategoryCard(
                  icon: Icons.auto_awesome_rounded,
                  title: 'AI Insights',
                  description: 'Generated observations and recommendations',
                  count: '8 insights',
                  size: '24 KB',
                  color: AppColors.positive,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _DataCategoryCard(
                  icon: Icons.settings_rounded,
                  title: 'Settings & Preferences',
                  description: 'Your choices and configuration',
                  count: '24 values',
                  size: '4 KB',
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Privacy guarantee
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _PrivacyGuaranteeCard(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Danger zone
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _DangerZoneCard(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _StorageOverviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storage_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Storage Used',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                '1.3 MB',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'of encrypted data',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: 0.02,
              minHeight: 6,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.lock_rounded,
                      color: AppColors.positive, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'AES-256 encrypted',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.positive,
                    ),
                  ),
                ],
              ),
              Text(
                'Retention: 90 days',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DataCategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String count;
  final String size;
  final Color color;

  const _DataCategoryCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.count,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
                const SizedBox(height: 2),
                Text(description, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                )),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(count, style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
              )),
              const SizedBox(height: 2),
              Text(size, style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textMuted,
              )),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }
}

class _PrivacyGuaranteeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.privacyBadge.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.privacyBadge.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_rounded,
                  color: AppColors.privacyBadge, size: 22),
              const SizedBox(width: 8),
              Text(
                'Privacy Guarantee',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.privacyBadge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGuarantee(context, '✓', 'Zero network permissions — app cannot connect to internet'),
          const SizedBox(height: 6),
          _buildGuarantee(context, '✓', 'All data encrypted with AES-256 on your device'),
          const SizedBox(height: 6),
          _buildGuarantee(context, '✓', 'AI model runs 100% locally — no cloud inference'),
          const SizedBox(height: 6),
          _buildGuarantee(context, '✓', 'You can delete any or all data at any time'),
          const SizedBox(height: 6),
          _buildGuarantee(context, '✓', 'Screen content is never read or stored'),
        ],
      ),
    );
  }

  Widget _buildGuarantee(BuildContext context, String check, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          check,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.positive,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _DangerZoneCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_rounded, color: AppColors.danger, size: 20),
              const SizedBox(width: 8),
              Text(
                'Data Management',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildDeleteOption(context, 'Delete last 24 hours', Icons.today_rounded),
          const SizedBox(height: 8),
          _buildDeleteOption(context, 'Delete by app', Icons.apps_rounded),
          const SizedBox(height: 8),
          _buildDeleteOption(context, 'Delete all patterns', Icons.pattern_rounded),
          const SizedBox(height: 8),
          _buildDeleteOption(context, 'Full data wipe', Icons.delete_forever_rounded),
        ],
      ),
    );
  }

  Widget _buildDeleteOption(BuildContext context, String label, IconData icon) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Confirm: $label'),
            content: Text(
              'This action cannot be undone. '
              'The selected data will be permanently deleted from your device.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.danger, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
