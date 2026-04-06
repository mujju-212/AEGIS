import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:privacy_ai/core/constants/settings_keys.dart';
import 'package:privacy_ai/core/providers.dart';
import 'package:privacy_ai/core/services/model/model_registry.dart';
import 'package:privacy_ai/core/theme/app_colors.dart';

class ModelSelectionScreen extends ConsumerStatefulWidget {
  const ModelSelectionScreen({super.key});

  @override
  State<ModelSelectionScreen> createState() => _ModelSelectionScreenState();
}

class _ModelSelectionScreenState extends ConsumerState<ModelSelectionScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final db = ref.read(databaseServiceProvider);
    final tierName = db.readSetting<String>(SettingsKeys.deviceTier) ?? DeviceTier.mid.name;
    final tier = DeviceTier.values.firstWhere(
      (t) => t.name == tierName,
      orElse: () => DeviceTier.mid,
    );
    final models = ModelRegistry.forTier(tier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose AI Model'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/device-scan'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select your AI model',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Runs entirely on your device. No cloud. No data leaves.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: models.length,
                itemBuilder: (context, index) {
                  final model = models[index];
                  final isSelected = index == _selectedIndex;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    model.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (model.badge != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _badgeColor(model.badge).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      model.badge!,
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: _badgeColor(model.badge),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked_rounded
                                      : Icons.radio_button_off_rounded,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textMuted,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              model.description,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildSpec(context, 'Size', model.size),
                                const SizedBox(width: 24),
                                _buildSpec(context, 'RAM', model.ram),
                                const SizedBox(width: 24),
                                _buildSpec(context, 'Speed', model.speed),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Privacy note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.privacyBadge.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_rounded,
                    color: AppColors.privacyBadge,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Model runs 100% on-device. No internet needed.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.privacyBadge,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final selected = models[_selectedIndex];
                  await db.saveSetting(SettingsKeys.selectedModelId, selected.id);
                  await db.saveSetting(SettingsKeys.modelReady, false);
                  context.go('/model-download');
                },
                child: Text('Download ${models[_selectedIndex].name}'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSpec(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _badgeColor(String? badge) {
    switch (badge) {
      case 'Recommended':
        return AppColors.positive;
      case 'Smartest':
        return AppColors.primary;
      case 'Fastest':
        return AppColors.warning;
      default:
        return AppColors.textMuted;
    }
  }
}
