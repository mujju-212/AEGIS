import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:privacy_ai/core/theme/app_colors.dart';
import 'package:privacy_ai/core/providers.dart';
import 'package:privacy_ai/core/constants/settings_keys.dart';
import 'package:privacy_ai/core/services/model/model_registry.dart';

class OnboardingCompleteScreen extends ConsumerWidget {
  const OnboardingCompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(databaseServiceProvider);
    final modelId = db.readSetting<String>(SettingsKeys.selectedModelId);
    final model = modelId != null ? ModelRegistry.byId(modelId) : null;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Success animation placeholder
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.positive.withValues(alpha: 0.3),
                      AppColors.positive.withValues(alpha: 0.1),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 72,
                  color: AppColors.positive,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'You\'re all set!',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Your private AI companion is ready',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              // Summary cards
              _buildSummaryItem(
                context,
                Icons.psychology_rounded,
                'AI Model',
                model != null
                    ? '${model.name} — running on your device'
                    : 'Local model — running on your device',
              ),
              const SizedBox(height: 12),
              _buildSummaryItem(
                context,
                Icons.lock_rounded,
                'Privacy',
                'All data encrypted & stored locally',
              ),
              const SizedBox(height: 12),
              _buildSummaryItem(
                context,
                Icons.insights_rounded,
                'Insights',
                'Pattern detection begins learning now',
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    db.saveSetting(SettingsKeys.onboardingComplete, true);
                    ref.read(isOnboardingCompleteProvider.notifier).state = true;
                    context.go('/home');
                  },
                  child: const Text('Start Using Privacy AI'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You can change any setting later in the app',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
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
