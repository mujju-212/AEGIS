import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:privacy_ai/core/theme/app_colors.dart';

class RigorousModeScreen extends ConsumerStatefulWidget {
  const RigorousModeScreen({super.key});

  @override
  ConsumerState<RigorousModeScreen> createState() => _RigorousModeScreenState();
}

class _RigorousModeScreenState extends ConsumerState<RigorousModeScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _breathePhase = 0; // 0=inhale, 1=hold, 2=exhale
  Timer? _breatheTimer;
  int _secondsRemaining = 0;
  bool _isBreathing = false;

  final List<String> _reflectionPrompts = [
    'What were you doing just before reaching for your phone?',
    'How does your body feel right now?',
    'What emotion were you trying to satisfy?',
    'Is there something more meaningful you could do right now?',
    'When was the last time you felt truly present?',
  ];

  int _currentPromptIndex = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _breatheTimer?.cancel();
    super.dispose();
  }

  void _startBreathing() {
    setState(() {
      _isBreathing = true;
      _breathePhase = 0;
      _secondsRemaining = 4;
    });

    _breatheTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsRemaining--;
        if (_secondsRemaining <= 0) {
          _breathePhase = (_breathePhase + 1) % 3;
          switch (_breathePhase) {
            case 0:
              _secondsRemaining = 4; // inhale
              break;
            case 1:
              _secondsRemaining = 4; // hold
              break;
            case 2:
              _secondsRemaining = 6; // exhale
              break;
          }
        }
      });
    });
  }

  void _stopBreathing() {
    _breatheTimer?.cancel();
    setState(() {
      _isBreathing = false;
    });
  }

  String get _breatheLabel {
    switch (_breathePhase) {
      case 0:
        return 'Breathe In';
      case 1:
        return 'Hold';
      case 2:
        return 'Breathe Out';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0415), // Deep purple-black
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_rounded,
                            color: AppColors.danger, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Rigorous Mode Active',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48), // balance the close button
                ],
              ),

              const SizedBox(height: 30),

              // Pulsing risk score
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.danger.withValues(alpha: 0.3),
                            AppColors.danger.withValues(alpha: 0.05),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.danger.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '85',
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                              color: AppColors.danger,
                              fontWeight: FontWeight.bold,
                              fontSize: 42,
                            ),
                          ),
                          Text(
                            'Risk Score',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.danger.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // Message
              Text(
                'Your usage patterns suggest\nyou might need a break',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 30),

              // Breathing exercise
              _buildBreathingCard(context),

              const SizedBox(height: 16),

              // Reflection prompt
              _buildReflectionCard(context),

              const Spacer(),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.timer_rounded, size: 18),
                      label: const Text('Snooze 5 min'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.phone_locked_rounded, size: 18),
                      label: const Text('Lock & Leave'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreathingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1030),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.air_rounded, color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              Text(
                'Breathing Exercise',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_isBreathing) ...[
            // Animated circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              width: _breathePhase == 0
                  ? 80
                  : _breathePhase == 1
                      ? 80
                      : 50,
              height: _breathePhase == 0
                  ? 80
                  : _breathePhase == 1
                      ? 80
                      : 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.15),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
              ),
              child: Center(
                child: Text(
                  '$_secondsRemaining',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _breatheLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _stopBreathing,
              child: const Text('Stop',
                  style: TextStyle(color: Colors.white54)),
            ),
          ] else ...[
            Text(
              '4-4-6 breathing helps calm your nervous system',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startBreathing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                  foregroundColor: AppColors.accent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Start Breathing'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReflectionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1030),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded,
                  color: AppColors.warning, size: 18),
              const SizedBox(width: 8),
              Text(
                'Reflection',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentPromptIndex =
                        (_currentPromptIndex + 1) % _reflectionPrompts.length;
                  });
                },
                child: const Icon(Icons.refresh_rounded,
                    color: Colors.white30, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _reflectionPrompts[_currentPromptIndex],
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
