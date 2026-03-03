// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'DermaMatch AI',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: 20,
                letterSpacing: 1.2,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              _buildHeader(context),
              const SizedBox(height: 48),
              _buildMainCard(context),
              const SizedBox(height: 64),
              _buildFeatureList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          'Find Your Perfect Foundation',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge,
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
        const SizedBox(height: 12),
        Text(
          'Professional skin tone analysis\npowered by AI technology.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mutedText,
              ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
      ],
    );
  }

  Widget _buildMainCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withOpacity(0.08),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
        border: Border.all(color: AppTheme.divider, width: 0.8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.face_retouching_natural,
              size: 48,
              color: AppTheme.accent,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 32),
          Text(
            'Start Skin Analysis',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Upload or take a photo to get\nyour exact pigment formula.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 40),
          GoldButton(
            text: 'Analyze Now',
            onPressed: () => context.push('/upload'),
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildFeatureList(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _FeatureItem(icon: Icons.biotech_outlined, label: 'AI Powered'),
        _FeatureItem(icon: Icons.color_lens_outlined, label: 'Pigment Mix'),
        _FeatureItem(icon: Icons.check_circle_outline, label: '99% Accuracy'),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.accent, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}
