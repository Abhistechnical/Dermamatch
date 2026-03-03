// lib/screens/analysis/analysis_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/scan_provider.dart';
import '../../theme/app_theme.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  int _stepIndex = 0;

  static const _steps = [
    'Scanning face profile...',
    'Detecting skin regions...',
    'Normalizing lighting...',
    'Analyzing deep pigments...',
    'Identifying undertone...',
    'Finalizing skin formula...',
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) => _startAnalysis());
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _startAnalysis() async {
    try {
      final extra = GoRouterState.of(context).extra;
      final image = extra is File ? extra : null;

      if (image == null) {
        context.go('/upload');
        return;
      }

    for (int i = 0; i < _steps.length - 1; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) setState(() => _stepIndex = i + 1);
    }

      final scanProv = context.read<ScanProvider>();
      final result = await scanProv.analyze(image);

      if (mounted) {
        if (result != null) {
          context.go('/result');
        } else {
          _showError(scanProv.error ?? 'Analysis failed');
        }
      }
    } catch (e) {
      if (mounted) _showError('Critical error: $e');
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Analysis Failed', style: Theme.of(context).textTheme.displaySmall),
        content: Text(msg, style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/upload');
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAnalysisCircle(),
                const SizedBox(height: 64),
                Text(
                  'Analyzing Skin Tone',
                  style: Theme.of(context).textTheme.displayMedium,
                ).animate().fadeIn(duration: 600.ms),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: 400.ms,
                  child: Text(
                    _steps[_stepIndex],
                    key: ValueKey(_stepIndex),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.mutedText,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 64),
                _buildProgressDots(),
                const SizedBox(height: 48),
                Text(
                  'Our AI is processing your portrait\nto find the perfect pigment match.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.mutedText.withOpacity(0.6),
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisCircle() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, child) {
        return Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.surface,
            boxShadow: [
              BoxShadow(
                color: AppTheme.accent.withOpacity(0.1 + _pulseCtrl.value * 0.1),
                blurRadius: 30 + _pulseCtrl.value * 10,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: AppTheme.accent.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: const [
                    AppTheme.accent,
                    Colors.white,
                    AppTheme.accent,
                  ],
                  transform: GradientRotation(_pulseCtrl.value * 2 * 3.14159),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.face_retouching_natural,
                      size: 48,
                      color: AppTheme.accent,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_steps.length, (i) {
        final active = i == _stepIndex;
        final done = i < _stepIndex;
        return AnimatedContainer(
          duration: 300.ms,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: done || active ? AppTheme.accent : AppTheme.divider,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
