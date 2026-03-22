import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:privacy_ai/core/theme/app_colors.dart';

class AgentsScreen extends ConsumerWidget {
  const AgentsScreen({super.key});

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
                      'AI Agents',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Specialized assistants running on your device',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Active agents
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Active',
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
                child: _AgentCard(
                  name: 'Pattern Detective',
                  description:
                      'Continuously monitors usage patterns and detects '
                      'compulsive behaviors, habit loops, and app dependency signals.',
                  icon: Icons.search_rounded,
                  color: AppColors.primary,
                  status: 'Running',
                  statusColor: AppColors.positive,
                  patternsFound: 2,
                  lastActive: '2 minutes ago',
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _AgentCard(
                  name: 'Wellbeing Coach',
                  description:
                      'Provides personalized recommendations based on your '
                      'usage data. Suggests actionable habits and tracks progress.',
                  icon: Icons.favorite_rounded,
                  color: AppColors.positive,
                  status: 'Running',
                  statusColor: AppColors.positive,
                  patternsFound: null,
                  lastActive: '5 minutes ago',
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Available agents
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Available',
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
                child: _AgentCard(
                  name: 'Sleep Guardian',
                  description:
                      'Monitors pre-sleep phone usage and suggests '
                      'wind-down routines. Tracks correlation between phone '
                      'use and sleep quality.',
                  icon: Icons.bedtime_rounded,
                  color: AppColors.warning,
                  status: 'Inactive',
                  statusColor: AppColors.textMuted,
                  patternsFound: null,
                  lastActive: null,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _AgentCard(
                  name: 'Focus Mode',
                  description:
                      'Tracks app-switching during focus periods. '
                      'Identifies concentration breakers and suggests '
                      'distraction-free intervals.',
                  icon: Icons.center_focus_strong_rounded,
                  color: AppColors.danger,
                  status: 'Inactive',
                  statusColor: AppColors.textMuted,
                  patternsFound: null,
                  lastActive: null,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _AgentCard(
                  name: 'Notification Analyst',
                  description:
                      'Classifies notification patterns by urgency and source. '
                      'Identifies notification-driven compulsive checking.',
                  icon: Icons.notifications_active_rounded,
                  color: AppColors.primary,
                  status: 'Inactive',
                  statusColor: AppColors.textMuted,
                  patternsFound: null,
                  lastActive: null,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Privacy note
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.privacyBadge.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_rounded,
                          color: AppColors.privacyBadge, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'All agents run on-device using your local AI model. '
                          'No agent data ever leaves your phone.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.privacyBadge,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _AgentCard extends StatelessWidget {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String status;
  final Color statusColor;
  final int? patternsFound;
  final String? lastActive;

  const _AgentCard({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.status,
    required this.statusColor,
    this.patternsFound,
    this.lastActive,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'Running';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive
            ? color.withValues(alpha: 0.04)
            : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? color.withValues(alpha: 0.2)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: statusColor,
                          ),
                        ),
                        if (lastActive != null) ...[
                          Text(
                            ' • $lastActive',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Toggle
              Switch(
                value: isActive,
                onChanged: (_) {
                  // TODO: Toggle agent
                },
                activeThumbColor: color,
                inactiveTrackColor: AppColors.surfaceElevated,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          if (patternsFound != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.pattern_rounded,
                      color: AppColors.warning, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$patternsFound patterns detected',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
