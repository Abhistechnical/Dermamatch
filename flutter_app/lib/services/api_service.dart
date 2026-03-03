// lib/services/api_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/scan_result.dart';

class ApiService {
  static String get _baseUrl =>
      dotenv.env['COLOR_ENGINE_URL'] ?? 'http://localhost:8000';

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Analyze a face image using the Python FastAPI color engine.
  Future<ScanResult> analyzeFace(File imageFile) async {
    final uri = Uri.parse('$_baseUrl/analyze');
    debugPrint('ApiService: Starting analysis at $uri');
    debugPrint('ApiService: Headers: ${dotenv.env['API_KEY'] != null ? "API_KEY present" : "No API_KEY"}');

    final request = http.MultipartRequest('POST', uri)
      ..headers['X-API-Key'] = dotenv.env['API_KEY'] ?? ''
      ..headers['Bypass-Tunnel-Reminder'] = 'true'
      ..files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

    try {
      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);

      debugPrint('ApiService: Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ScanResult.fromJson(json);
      } else {
        throw Exception('Analysis failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('ApiService Error: $e');
      rethrow;
    }
  }

  /// Track an affiliate link click.
  Future<void> trackAffiliateClick(String productId) async {
    final uid = _supabase.auth.currentUser?.id;
    final uri = Uri.parse('$_baseUrl/affiliate/track-click');

    try {
      await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': dotenv.env['API_KEY'] ?? '',
        },
        body: jsonEncode({
          'product_id': productId,
          'user_id': uid ?? '',
        }),
      );
    } catch (e) {
      debugPrint('ApiService: Failed to track click: $e');
    }
  }

  /// Save scan to Supabase `scans` table and return the stored result.
  Future<ScanResult> saveScan(ScanResult result) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) throw Exception('Not authenticated');

    final row = {
      'user_id': uid,
      'raw_rgb': '${result.rawRgb.r}, ${result.rawRgb.g}, ${result.rawRgb.b}',
      'corrected_rgb': '${result.correctedRgb.r}, ${result.correctedRgb.g}, ${result.correctedRgb.b}',
      'hex': result.hex,
      'undertone': result.undertone,
      'depth': result.depth,
      'pigment_mix_json': result.pigmentMix.toJson(),
      'cmyk': result.cmyk.toJson(),
      'ryb': result.ryb.toJson(),
      'recommended_shades': result.recommendedShades,
      'recommended_products_json':
          result.recommendedProducts.map((e) => e.toJson()).toList(),
    };

    final data = await _supabase.from('scans').insert(row).select().single();

    // Create new result with DB ID
    return ScanResult(
      id: data['id'],
      userId: data['user_id'],
      depth: result.depth,
      undertone: result.undertone,
      rawRgb: result.rawRgb,
      correctedRgb: result.correctedRgb,
      hex: result.hex,
      cmyk: result.cmyk,
      ryb: result.ryb,
      pigmentMix: result.pigmentMix,
      recommendedShades: result.recommendedShades,
      recommendedProducts: result.recommendedProducts,
      createdAt: DateTime.parse(data['created_at']),
    );
  }

  /// Fetch previous scans for the current user.
  Future<List<ScanResult>> fetchScans({int page = 0, int limit = 20}) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return [];

    final data = await _supabase
        .from('scans')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .range(page * limit, (page + 1) * limit - 1);

    return (data as List).map((row) {
      final pigmentRaw = row['pigment_mix_json'];
      final cmykRaw = row['cmyk'];
      final rybRaw = row['ryb'];
      return ScanResult.fromJson({
        'id': row['id'],
        'user_id': row['user_id'],
        'depth': row['depth'],
        'undertone': row['undertone'],
        'raw_rgb': row['raw_rgb'],
        'corrected_rgb': row['corrected_rgb'],
        'hex': row['hex'],
        'cmyk': cmykRaw is String ? jsonDecode(cmykRaw) : cmykRaw,
        'ryb': rybRaw is String ? jsonDecode(rybRaw) : rybRaw,
        'pigment_mix':
            pigmentRaw is String ? jsonDecode(pigmentRaw) : pigmentRaw,
        'recommended_shades': row['recommended_shades'] ?? [],
        'recommended_products': row['recommended_products_json'] is String
            ? jsonDecode(row['recommended_products_json'])
            : row['recommended_products_json'],
        'created_at': row['created_at'],
      });
    }).toList();
  }

  /// Fetch a single scan by id.
  Future<ScanResult?> fetchScan(String scanId) async {
    final data =
        await _supabase.from('scans').select().eq('id', scanId).maybeSingle();
    if (data == null) return null;
    return ScanResult.fromJson(data);
  }
}
