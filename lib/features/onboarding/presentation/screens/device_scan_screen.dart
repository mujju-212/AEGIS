import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:privacy_ai/core/theme/app_colors.dart';

class DeviceScanScreen extends StatefulWidget {
  const DeviceScanScreen({super.key});

  @override
  State<DeviceScanScreen> createState() => _DeviceScanScreenState();
}

class _DeviceScanScreenState extends State<DeviceScanScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  final List<_ScanStep> _steps = [
    _ScanStep('Checking available RAM', Icons.memory_rounded),
    _ScanStep('Measuring storage space', Icons.storage_rounded),
    _ScanStep('Detecting processor capabilities', Icons.developer_board_rounded),
    _ScanStep('Evaluating battery health', Icons.battery_charging_full_rounded),
    _ScanStep('Determining optimal model size', Icons.psychology_rounded),
  ];

  int _currentStep = 0;
  bool _scanComplete = false;

  // Simulated device info
  final Map<String, String> _deviceInfo = {};

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _progressController.addListener(() {
      final step = (_progressAnimation.value * _steps.length).floor();
      if (step != _currentStep && step < _steps.length) {
        setState(() => _currentStep = step);
      }
    });
    _startScan();
  }

  Future<void> _startScan() async {
    _progressController.forward();
    // Simulate device detection
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _deviceInfo['RAM'] = '6 GB');
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _deviceInfo['Storage'] = '12.4 GB free');
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _deviceInfo['CPU'] = 'ARM v8 (8 cores)');
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _deviceInfo['Battery'] = '87% health');
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _deviceInfo['Recommended'] = 'TinyLlama 1.1B';
      _scanComplete = true;
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Scan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/welcome'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analyzing your device',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Finding the best AI model for your hardware',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            // Progress bar
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _scanComplete ? 1.0 : _progressAnimation.value,
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceCard,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _scanComplete ? AppColors.positive : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _scanComplete
                          ? 'Scan complete!'
                          : _steps[_currentStep].label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _scanComplete
                            ? AppColors.positive
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            // Scan steps
            Expanded(
              child: ListView.builder(
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  final isDone = index < _currentStep || _scanComplete;
                  final isCurrent = index == _currentStep && !_scanComplete;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDone
                                ? AppColors.positive.withValues(alpha: 0.15)
                                : isCurrent
                                    ? AppColors.primary.withValues(alpha: 0.15)
                                    : AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isDone ? Icons.check_rounded : _steps[index].icon,
                            color: isDone
                                ? AppColors.positive
                                : isCurrent
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _steps[index].label,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: isDone || isCurrent
                                      ? AppColors.textPrimary
                                      : AppColors.textMuted,
                                ),
                              ),
                              if (_deviceInfo.isNotEmpty && index < _deviceInfo.length)
                                Text(
                                  _deviceInfo.values.elementAt(index),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.positive,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Result card
            if (_scanComplete) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.positive.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.positive.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.positive,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your device is ready!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.positive,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Recommended: TinyLlama 1.1B',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/model-selection'),
                  child: const Text('Continue'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScanStep {
  final String label;
  final IconData icon;
  const _ScanStep(this.label, this.icon);
}
