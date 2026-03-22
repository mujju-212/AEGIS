import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:privacy_ai/core/theme/app_colors.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _rigorousModeEnabled = false;
  bool _autoDeleteOldData = true;
  double _retentionDays = 90;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // AI Model section
          _buildSectionHeader(context, 'AI Model'),
          _buildSettingCard(
            context,
            icon: Icons.psychology_rounded,
            title: 'Current Model',
            subtitle: 'TinyLlama 1.1B • 637 MB',
            trailing: OutlinedButton(
              onPressed: () {},
              child: const Text('Change'),
            ),
          ),
          const SizedBox(height: 8),
          _buildSettingCard(
            context,
            icon: Icons.memory_rounded,
            title: 'Model Status',
            subtitle: 'Idle • Last active 5 min ago',
            trailing: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.positive,
              ),
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Privacy & Data'),
          _buildToggleCard(
            context,
            icon: Icons.auto_delete_rounded,
            title: 'Auto-delete old data',
            subtitle: 'Remove events older than ${_retentionDays.round()} days',
            value: _autoDeleteOldData,
            onChanged: (v) => setState(() => _autoDeleteOldData = v),
          ),
          if (_autoDeleteOldData) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Retention period',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          )),
                      Text('${_retentionDays.round()} days',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                  Slider(
                    value: _retentionDays,
                    min: 7,
                    max: 365,
                    divisions: 10,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _retentionDays = v),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Notifications'),
          _buildToggleCard(
            context,
            icon: Icons.notifications_rounded,
            title: 'Pattern alerts',
            subtitle: 'Notify when new patterns are detected',
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Rigorous Mode'),
          _buildToggleCard(
            context,
            icon: Icons.shield_rounded,
            title: 'Enable Rigorous Mode',
            subtitle: 'Activate when risk score exceeds 80',
            value: _rigorousModeEnabled,
            onChanged: (v) {
              setState(() => _rigorousModeEnabled = v);
              if (v) context.push('/rigorous-mode');
            },
          ),

          const SizedBox(height: 24),
          _buildSectionHeader(context, 'About'),
          _buildSettingCard(
            context,
            icon: Icons.info_outline_rounded,
            title: 'Privacy AI',
            subtitle: 'Version 1.0.0 • Phase 1 Foundation',
            trailing: null,
          ),
          const SizedBox(height: 8),
          _buildSettingCard(
            context,
            icon: Icons.code_rounded,
            title: 'Open Source',
            subtitle: 'Built with Flutter + llama.cpp',
            trailing: null,
          ),

          const SizedBox(height: 24),
          // Privacy badge
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.privacyBadge.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded,
                    color: AppColors.privacyBadge, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zero network permissions',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.privacyBadge,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'This app cannot connect to the internet by design',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                )),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                )),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  Widget _buildToggleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                )),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                )),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
