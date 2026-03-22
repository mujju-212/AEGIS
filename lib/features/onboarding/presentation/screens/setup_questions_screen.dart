import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:privacy_ai/core/theme/app_colors.dart';

class SetupQuestionsScreen extends StatefulWidget {
  const SetupQuestionsScreen({super.key});

  @override
  State<SetupQuestionsScreen> createState() => _SetupQuestionsScreenState();
}

class _SetupQuestionsScreenState extends State<SetupQuestionsScreen> {
  int _currentQuestion = 0;
  final Map<int, Set<int>> _answers = {};

  final List<_SetupQuestion> _questions = [
    _SetupQuestion(
      question: 'What would you like help with?',
      subtitle: 'Select all that apply',
      multiSelect: true,
      options: [
        'Reducing screen time',
        'Understanding my habits',
        'Improving sleep quality',
        'App usage awareness',
        'Digital wellbeing',
        'Just exploring',
      ],
    ),
    _SetupQuestion(
      question: 'How do you feel about your phone usage?',
      subtitle: 'Be honest — this stays on your device',
      multiSelect: false,
      options: [
        'I\'m in control',
        'Could be better',
        'I check it too much',
        'I want to change',
        'Not sure yet',
      ],
    ),
    _SetupQuestion(
      question: 'When are you most on your phone?',
      subtitle: 'Helps personalize insights',
      multiSelect: true,
      options: [
        'Morning (wake-up scrolling)',
        'During work/school',
        'Commute / breaks',
        'Evening / before bed',
        'Late night',
      ],
    ),
  ];

  void _toggleOption(int questionIndex, int optionIndex) {
    setState(() {
      _answers[questionIndex] ??= {};
      if (_questions[questionIndex].multiSelect) {
        if (_answers[questionIndex]!.contains(optionIndex)) {
          _answers[questionIndex]!.remove(optionIndex);
        } else {
          _answers[questionIndex]!.add(optionIndex);
        }
      } else {
        _answers[questionIndex] = {optionIndex};
      }
    });
  }

  void _next() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() => _currentQuestion++);
    } else {
      context.go('/permission-setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];
    final selected = _answers[_currentQuestion] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text('Setup (${_currentQuestion + 1}/${_questions.length})'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_currentQuestion > 0) {
              setState(() => _currentQuestion--);
            } else {
              context.go('/model-selection');
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress dots
            Row(
              children: List.generate(_questions.length, (i) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i <= _currentQuestion
                          ? AppColors.primary
                          : AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            Text(
              question.question,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              question.subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  final isSelected = selected.contains(index);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => _toggleOption(_currentQuestion, index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                question.options[index],
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: isSelected
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Icon(
                              question.multiSelect
                                  ? (isSelected
                                      ? Icons.check_box_rounded
                                      : Icons.check_box_outline_blank_rounded)
                                  : (isSelected
                                      ? Icons.radio_button_checked_rounded
                                      : Icons.radio_button_off_rounded),
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Privacy badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.privacyBadge.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_rounded, color: AppColors.privacyBadge, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Answers stored on-device only',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.privacyBadge,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (selected.isEmpty)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _next,
                      child: const Text('Skip'),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _next,
                      child: Text(
                        _currentQuestion < _questions.length - 1
                            ? 'Next'
                            : 'Continue',
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SetupQuestion {
  final String question;
  final String subtitle;
  final bool multiSelect;
  final List<String> options;

  const _SetupQuestion({
    required this.question,
    required this.subtitle,
    required this.multiSelect,
    required this.options,
  });
}
