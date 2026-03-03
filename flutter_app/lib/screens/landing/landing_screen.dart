// lib/screens/landing/landing_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              _buildHero(context),
              _buildFeatures(context),
              _buildCTA(context),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.goldLight, AppTheme.gold],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.face_retouching_natural,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text('DermaMatch',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepNavy,
                  )),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text('Sign In',
                    style: GoogleFonts.inter(
                      color: AppTheme.darkText,
                      fontWeight: FontWeight.w500,
                    )),
              ),
              const SizedBox(width: 8),
              GoldButton(
                text: 'Get Started',
                onPressed: () => context.go('/register'),
                width: 130,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.gold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.gold,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text('AI-Powered Skin Analysis',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.goldDark,
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

          const SizedBox(height: 28),

          Text(
            'Your Perfect\nFoundation Match',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 52,
              fontWeight: FontWeight.w700,
              color: AppTheme.deepNavy,
              height: 1.1,
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),

          const SizedBox(height: 20),

          Text(
            'Upload a selfie. Our AI analyzes your unique skin tone,\ndetects undertone & depth, then returns an exact\npigment formula and foundation recommendations.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppTheme.mutedText,
              height: 1.7,
            ),
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 40),

          GoldButton(
            text: '✦  Analyze My Skin Tone',
            onPressed: () => context.go('/register'),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

          const SizedBox(height: 16),

          Text('3 free scans on signup · No credit card required',
              style:
                  GoogleFonts.inter(fontSize: 12, color: AppTheme.mutedText)),

          const SizedBox(height: 60),

          // Hero Color Swatch Preview
          _buildColorSwatchPreview().animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildColorSwatchPreview() {
    final shades = [
      const Color(0xFFFFDFC4),
      const Color(0xFFF0C27F),
      const Color(0xFFCB9651),
      const Color(0xFF9B6740),
      const Color(0xFF7D4727),
      const Color(0xFF4A2510),
    ];
    return Column(
      children: [
        Text('Across all skin tones',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.mutedText,
              letterSpacing: 1,
            )),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: shades.asMap().entries.map((e) {
            return Align(
              widthFactor: e.key == 0 ? 1.0 : 0.85,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: e.value,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.cream, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: e.value.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFeatures(BuildContext context) {
    final features = [
      _Feature('🎨', 'Exact Color Formula',
          'HEX, CMYK, RYB & Pigment mixing ratios'),
      _Feature('✦', 'Undertone Detection',
          'Warm, Cool, Neutral, or Olive classification'),
      _Feature('💄', 'Shade Recommendations',
          '3 perfect foundation shade names matched to you'),
      _Feature('🔒', 'Secure & Private',
          'Your photos are analyzed and never stored'),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What You Get',
              style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: features
                .map((f) => LuxuryCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(f.icon, style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: 12),
                          Text(f.title,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.deepNavy,
                              )),
                          const SizedBox(height: 4),
                          Text(f.desc,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.mutedText,
                                height: 1.4,
                              )),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildCTA(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.deepNavy, const Color(0xFF2D2D4E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text('Ready to find your perfect match?',
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              )),
          const SizedBox(height: 12),
          Text(
              'Join thousands of beauty enthusiasts who use DermaMatch AI everyday.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 14, color: Colors.white60, height: 1.6)),
          const SizedBox(height: 28),
          GoldButton(
            text: 'Start Free Analysis',
            onPressed: () => context.go('/register'),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text('© 2026 DermaMatch AI · All rights reserved',
          style: GoogleFonts.inter(fontSize: 12, color: AppTheme.mutedText)),
    );
  }
}

class _Feature {
  final String icon, title, desc;
  const _Feature(this.icon, this.title, this.desc);
}
