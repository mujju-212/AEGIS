import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:privacy_ai/core/constants/settings_keys.dart';
import 'package:privacy_ai/core/providers.dart';
import 'package:privacy_ai/core/services/model/model_download_service.dart';
import 'package:privacy_ai/core/services/model/model_registry.dart';
import 'package:privacy_ai/core/theme/app_colors.dart';

class ModelDownloadScreen extends ConsumerStatefulWidget {
  const ModelDownloadScreen({super.key});

  @override
  ConsumerState<ModelDownloadScreen> createState() => _ModelDownloadScreenState();
}

class _ModelDownloadScreenState extends ConsumerState<ModelDownloadScreen> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    final db = ref.read(databaseServiceProvider);
    final modelId = db.readSetting<String>(SettingsKeys.selectedModelId);
    if (modelId == null) {
      setState(() => _error = 'No model selected.');
      return;
    }

    final model = ModelRegistry.byId(modelId);
    final fileName = model.downloadUrl.split('/').last;
    final downloader = ModelDownloadService();

    setState(() {
      _isDownloading = true;
      _error = null;
    });

    try {
      final result = await downloader.download(
        model.downloadUrl,
        fileName: fileName,
        onProgress: (received, total) {
          if (total <= 0) return;
          setState(() => _progress = received / total);
        },
      );

      await db.saveSetting(SettingsKeys.selectedModelPath, result.filePath);
      await db.saveSetting(SettingsKeys.modelReady, true);

      if (mounted) {
        context.go('/setup-questions');
      }
    } catch (e) {
      setState(() => _error = 'Download failed: $e');
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.read(databaseServiceProvider);
    final modelId = db.readSetting<String>(SettingsKeys.selectedModelId);
    final model = modelId != null ? ModelRegistry.byId(modelId) : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloading model'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _isDownloading ? null : () => context.go('/model-selection'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preparing your AI model',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'This is a one-time download. It will run fully offline after this.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (model != null) ...[
              const SizedBox(height: 12),
              Text(
                '${model.name} • ${model.size}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
            const SizedBox(height: 32),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                backgroundColor: AppColors.surfaceCard,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${(_progress * 100).toStringAsFixed(0)}% complete',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.danger,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _startDownload,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
