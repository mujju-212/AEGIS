import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:privacy_ai/core/theme/app_colors.dart';

class ModelSelectionScreen extends StatefulWidget {
  const ModelSelectionScreen({super.key});

  @override
  State<ModelSelectionScreen> createState() => _ModelSelectionScreenState();
}

class _ModelSelectionScreenState extends State<ModelSelectionScreen> {
  int _selectedIndex = 0;

  final List<_ModelOption> _models = [
    _ModelOption(
      name: 'TinyLlama 1.1B',
      description: 'Fastest, lowest resource usage. Great for most devices.',
      size: '~637 MB',
      ram: '~1.5 GB',
      speed: 'Very Fast',
      badge: 'Recommended',
      badgeColor: AppColors.positive,
    ),
    _ModelOption(
      name: 'Phi-2 2.7B',
      description: 'Smarter reasoning, still lightweight. Needs 4+ GB RAM.',
      size: '~1.6 GB',
      ram: '~3.0 GB',
      speed: 'Fast',
      badge: 'Balanced',
      badgeColor: AppColors.primary,
    ),
    _ModelOption(
      name: 'Gemma 2B',
      description: 'Google\'s compact model. Good quality, moderate resources.',
      size: '~1.4 GB',
      ram: '~2.5 GB',
      speed: 'Fast',
      badge: null,
      badgeColor: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                itemCount: _models.length,
                itemBuilder: (context, index) {
                  final model = _models[index];
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
                                      color: model.badgeColor!.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      model.badge!,
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: model.badgeColor,
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
                onPressed: () => context.go('/setup-questions'),
                child: Text('Download ${_models[_selectedIndex].name}'),
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
}

class _ModelOption {
  final String name;
  final String description;
  final String size;
  final String ram;
  final String speed;
  final String? badge;
  final Color? badgeColor;

  const _ModelOption({
    required this.name,
    required this.description,
    required this.size,
    required this.ram,
    required this.speed,
    this.badge,
    this.badgeColor,
  });
}
