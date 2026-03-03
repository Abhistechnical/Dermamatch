// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/scan_result.dart';
import '../../providers/auth_provider.dart';
import '../../providers/scan_provider.dart';
import '../../services/payment_service.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PaymentService _payService = PaymentService();

  @override
  void initState() {
    super.initState();
    _payService.init();
    _payService.onSuccess = (payId, credits) async {
      await context.read<AuthProvider>().refreshProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: AppTheme.success,
          content: Text('$credits credits added! Payment ID: $payId',
              style: GoogleFonts.inter(color: Colors.white)),
        ));
      }
    };
    _payService.onFailure = (err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: AppTheme.error,
        content: Text(err, style: GoogleFonts.inter(color: Colors.white)),
      ));
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScanProvider>().loadHistory();
    });
  }

  @override
  void dispose() {
    _payService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final scan = context.watch<ScanProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.go('/upload'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await auth.signOut();
              if (mounted) context.go('/');
            },
            child: Text('Sign Out',
                style: GoogleFonts.inter(
                  color: AppTheme.error,
                  fontSize: 13,
                )),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Profile Card
            LuxuryCard(
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.goldLight, AppTheme.gold],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        (user?.email.substring(0, 1).toUpperCase()) ?? 'U',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(user?.email ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.deepNavy,
                      )),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
                    ),
                    child: Text(
                      (user?.planType ?? 'free').toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.gold,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(),

            const SizedBox(height: 16),

            // Credits Card
            LuxuryCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.stars_rounded, color: AppTheme.gold),
                    const SizedBox(width: 8),
                    Text('Scan Credits',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.deepNavy,
                        )),
                    const Spacer(),
                    Text('${user?.credits ?? 0}',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.gold,
                        )),
                  ]),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text('Top up credits',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.deepNavy,
                      )),
                  const SizedBox(height: 12),
                  Row(
                    children: PaymentService.packs.map((pack) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _payService.purchaseCredits(
                            pack: pack,
                            userEmail: user?.email ?? '',
                            userName: user?.email.split('@').first ?? 'User',
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.goldLight, AppTheme.gold],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(children: [
                              Text('${pack.credits}',
                                  style: GoogleFonts.cormorantGaramond(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  )),
                              Text('scans',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  )),
                              const SizedBox(height: 4),
                              Text(pack.label,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  )),
                            ]),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 20),

            // Scan History
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Scan History',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: AppTheme.gold),
                  onPressed: () => scan.loadHistory(refresh: true),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (scan.history.isEmpty)
              LuxuryCard(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(children: [
                      Icon(Icons.history_rounded,
                          color: AppTheme.divider, size: 48),
                      const SizedBox(height: 12),
                      Text('No scans yet',
                          style: GoogleFonts.inter(
                            color: AppTheme.mutedText,
                            fontWeight: FontWeight.w500,
                          )),
                      const SizedBox(height: 8),
                      GoldButton(
                        text: 'Analyze Now',
                        onPressed: () => context.go('/upload'),
                        width: 160,
                      ),
                    ]),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: scan.history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _ScanHistoryTile(
                  scan: scan.history[i],
                  onTap: () {
                    scan.setCurrentResult(scan.history[i]);
                    context.go('/result');
                  },
                ).animate().fadeIn(delay: (i * 50).ms),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ScanHistoryTile extends StatelessWidget {
  final ScanResult scan;
  final VoidCallback onTap;

  const _ScanHistoryTile({required this.scan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final skinColor = Color(scan.correctedRgb.toARGB());
    return GestureDetector(
      onTap: onTap,
      child: LuxuryCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: skinColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: skinColor.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(scan.hex,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.deepNavy,
                        )),
                    const SizedBox(width: 8),
                    _Badge(scan.undertone),
                    const SizedBox(width: 6),
                    _Badge(scan.depth),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(scan.createdAt),
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppTheme.mutedText),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.mutedText),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppTheme.gold,
            fontWeight: FontWeight.w500,
          )),
    );
  }
}
