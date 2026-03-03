// lib/screens/result/result_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/scan_result.dart';
import '../../providers/scan_provider.dart';
import '../../theme/app_theme.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scan = context.read<ScanProvider>().currentResult;
    if (scan == null) {
      return Scaffold(
        body: Center(
          child: OutlinedButton(
            onPressed: () => context.go('/'),
            child: const Text('Return Home'),
          ),
        ),
      );
    }

    final skinColor = Color(scan.correctedRgb.toARGB());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Result'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMainSwatch(context, skinColor, scan),
              const SizedBox(height: 32),
              _buildColorDetails(context, scan),
              const SizedBox(height: 32),
              _buildPigmentBreakdown(context, scan.pigmentMix),
              const SizedBox(height: 32),
              if (scan.recommendedProducts.isNotEmpty) ...[
                _buildAmazonRecommendations(context, scan.recommendedProducts),
                const SizedBox(height: 32),
              ],
              _buildRecommendedShades(context, scan.recommendedShades, skinColor),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => context.go('/'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('Save & Close'),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'As an Amazon Associate, we earn from qualifying purchases.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.mutedText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainSwatch(BuildContext context, Color skinColor, ScanResult scan) {
    return Column(
      children: [
        Center(
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: skinColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.divider, width: 2),
              boxShadow: [
                BoxShadow(
                  color: skinColor.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Badge(label: scan.depth),
            const SizedBox(width: 8),
            _Badge(label: scan.undertone),
          ],
        ).animate().fadeIn(delay: 200.ms),
      ],
    );
  }

  Widget _buildColorDetails(BuildContext context, ScanResult scan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Color Profiles', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.divider, width: 0.8),
          ),
          child: Column(
            children: [
              _ValueRow(label: 'HEX', value: scan.hex.toUpperCase()),
              const Divider(height: 24),
              _ValueRow(label: 'RGB', value: '${scan.correctedRgb.r}, ${scan.correctedRgb.g}, ${scan.correctedRgb.b}'),
              const Divider(height: 24),
              _ValueRow(label: 'CMYK', value: scan.cmyk.formatted),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildPigmentBreakdown(BuildContext context, PigmentMix mix) {
    final items = [
      {'name': 'Yellow', 'val': mix.yellow, 'color': const Color(0xFFF5D76E)},
      {'name': 'Red', 'val': mix.red, 'color': const Color(0xFFE74C3C)},
      {'name': 'Blue', 'val': mix.blue, 'color': const Color(0xFF3498DB)},
      {'name': 'White', 'val': mix.white, 'color': const Color(0xFFF0EDE8)},
      {'name': 'Black', 'val': mix.black, 'color': const Color(0xFF2C2C2C)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pigment Mix', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.divider, width: 0.8),
          ),
          child: Column(
            children: items.map((item) {
              final val = item['val'] as double;
              if (val == 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: item['color'] as Color,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.divider, width: 0.5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(item['name'] as String, style: Theme.of(context).textTheme.bodyMedium),
                    const Spacer(),
                    Text('${val.toStringAsFixed(1)}%', style: Theme.of(context).textTheme.labelLarge),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildRecommendedShades(BuildContext context, List<String> shades, Color skinColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Shade Recommendations', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        ...shades.asMap().entries.map((e) {
          final shadeColor = _shadeVariant(skinColor, e.key);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider, width: 0.8),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: shadeColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.divider, width: 0.5),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(e.value, style: Theme.of(context).textTheme.labelLarge),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.mutedText),
              ],
            ),
          );
        }),
      ],
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildAmazonRecommendations(BuildContext context, List<RecommendedProduct> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Perfect Matches', style: Theme.of(context).textTheme.headlineMedium),
            _Badge(label: 'AMAZON', color: const Color(0xFFFF9900)),
          ],
        ),
        const SizedBox(height: 16),
        ...products.map((p) => _ProductCard(product: p)),
      ],
    ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1);
  }

  Color _shadeVariant(Color base, int i) {
    final factor = 1.0 + (i - 1) * 0.05;
    return Color.fromARGB(
      255,
      (base.red * factor).round().clamp(0, 255),
      (base.green * factor).round().clamp(0, 255),
      (base.blue * factor).round().clamp(0, 255),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color? color;
  const _Badge({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? AppTheme.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: baseColor.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color != null ? color?.withOpacity(0.8) : AppTheme.accentDark,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final RecommendedProduct product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(int.parse(product.hexReference.replaceAll('#', '0xFF'))),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider, width: 0.5),
                ),
                child: const Icon(Icons.shopping_bag_outlined, color: Colors.white24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.accentDark,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.shadeName,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontSize: 15,
                            height: 1.2,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.priceRange,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.mutedText,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final uri = Uri.parse(product.affiliateUrl);
              if (await canLaunchUrl(uri)) {
                // Track click in background
                context.read<ScanProvider>().trackAffiliateClick(product.id);
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_cart_outlined, size: 18),
                const SizedBox(width: 8),
                Text('Buy on Amazon', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  final String label, value;
  const _ValueRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.mutedText)),
        Text(value, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}
