import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:privacy_ai/core/theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Privacy shield icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.3),
                      AppColors.primary.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Privacy AI',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Your private AI companion',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              // Privacy promises
              _buildPromise(context, Icons.lock_rounded, 'Everything stays on your device'),
              const SizedBox(height: 16),
              _buildPromise(context, Icons.wifi_off_rounded, 'Zero network calls — ever'),
              const SizedBox(height: 16),
              _buildPromise(context, Icons.visibility_rounded, 'You see everything we learn'),
              const SizedBox(height: 16),
              _buildPromise(context, Icons.delete_outline_rounded, 'Delete anything, anytime'),
              const Spacer(flex: 3),
              // Get Started button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/device-scan'),
                  child: const Text('Get Started'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'All data stays on device. You own everything.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.privacyBadge,
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

  Widget _buildPromise(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
