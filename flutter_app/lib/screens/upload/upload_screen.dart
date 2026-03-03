// lib/screens/upload/upload_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/scan_provider.dart';
import '../../theme/app_theme.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _image;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _analyze() async {
    if (_image == null) return;

    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) {
      context.go('/login');
      return;
    }
    if (!user.hasCredits) {
      _showNoCreditsDialog();
      return;
    }

    // Deduct credit
    final ok = await auth.deductCredit();
    if (!ok || !mounted) return;

    // Navigate to analysis (which triggers the scan)
    context.go('/analysis', extra: _image);
  }

  void _showNoCreditsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('No Credits Left',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppTheme.deepNavy,
            )),
        content: Text('Purchase credits to continue your skin analysis.',
            style: GoogleFonts.inter(color: AppTheme.mutedText)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/profile');
            },
            child: const Text('Buy Credits'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        title: const Text('Analyze Skin Tone'),
        leading: const SizedBox(),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/profile'),
            icon: const Icon(Icons.person_outline,
                size: 18, color: AppTheme.gold),
            label: Text('Profile',
                style: GoogleFonts.inter(color: AppTheme.gold, fontSize: 13)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Credit Badge
              if (user != null)
                LuxuryCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.gold.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.stars_rounded,
                            color: AppTheme.gold, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${user.credits} Scans Remaining',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.deepNavy)),
                          Text(user.planType.toUpperCase(),
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppTheme.gold,
                                  letterSpacing: 1)),
                        ],
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.go('/profile'),
                        child: Text('Get more',
                            style: GoogleFonts.inter(
                              color: AppTheme.gold,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ],
                  ),
                ).animate().fadeIn(),

              const SizedBox(height: 28),

              // Upload Zone
              GestureDetector(
                onTap: () => _showPickerSheet(),
                child: AnimatedContainer(
                  duration: 300.ms,
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    color: _image != null
                        ? Colors.transparent
                        : AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _image != null ? AppTheme.gold : AppTheme.divider,
                      width: _image != null ? 2 : 1,
                    ),
                  ),
                  child: _image != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.file(_image!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: GestureDetector(
                                onTap: () => setState(() => _image = null),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: AppTheme.gold.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add_a_photo_outlined,
                                  color: AppTheme.gold, size: 32),
                            ),
                            const SizedBox(height: 16),
                            Text('Upload a Face Photo',
                                style: GoogleFonts.cormorantGaramond(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.deepNavy,
                                )),
                            const SizedBox(height: 8),
                            Text('Tap to take a selfie or choose from gallery',
                                style: GoogleFonts.inter(
                                    fontSize: 13, color: AppTheme.mutedText)),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.divider),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Text('JPG, PNG up to 10MB',
                                  style: GoogleFonts.inter(
                                      fontSize: 12, color: AppTheme.mutedText)),
                            ),
                          ],
                        ),
                ),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 28),

              // Tips
              LuxuryCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.tips_and_updates_outlined,
                          color: AppTheme.gold, size: 18),
                      const SizedBox(width: 8),
                      Text('Tips for best results',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.deepNavy,
                          )),
                    ]),
                    const SizedBox(height: 12),
                    for (final tip in _tips) _TipRow(tip),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 32),

              GoldButton(
                text: _image == null
                    ? 'Select a Photo First'
                    : '✦  Analyze My Skin Tone',
                onPressed: _image == null ? null : _analyze,
                icon: _image != null ? null : null,
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 12),
              Text('1 credit per scan',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.mutedText,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  static const _tips = [
    'Face the camera directly, looking straight ahead',
    'Use natural lighting — avoid harsh shadows',
    'Remove glasses, heavy makeup, or filters',
    'Ensure your full face is visible and in frame',
  ];

  void _showPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.camera_alt_outlined, color: AppTheme.gold),
              ),
              title: Text('Take a Selfie',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
              trailing:
                  const Icon(Icons.chevron_right, color: AppTheme.mutedText),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library_outlined,
                    color: AppTheme.gold),
              ),
              title: Text('Choose from Gallery',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
              trailing:
                  const Icon(Icons.chevron_right, color: AppTheme.mutedText),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String text;
  const _TipRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline,
              color: AppTheme.success, size: 16),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.mutedText,
                    height: 1.4,
                  ))),
        ],
      ),
    );
  }
}
