// lib/models/scan_result.dart
class ScanResult {
  final String id;
  final String userId;
  final String depth;
  final String undertone;
  final RGBColor rawRgb;
  final RGBColor correctedRgb;
  final String hex;
  final CMYKColor cmyk;
  final RYBColor ryb;
  final PigmentMix pigmentMix;
  final int skinScore;
  final SkinMetrics? skinMetrics;
  final List<String> recommendedShades;
  final List<RecommendedProduct> recommendedProducts;
  final DateTime createdAt;

  ScanResult({
    required this.id,
    required this.userId,
    required this.depth,
    required this.undertone,
    required this.rawRgb,
    required this.correctedRgb,
    required this.hex,
    required this.cmyk,
    required this.ryb,
    required this.pigmentMix,
    this.skinScore = 0,
    this.skinMetrics,
    required this.recommendedShades,
    required this.recommendedProducts,
    required this.createdAt,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      depth: json['depth'] ?? '',
      undertone: json['undertone'] ?? '',
      rawRgb: _parseRGBColor(json['raw_rgb']),
      correctedRgb: _parseRGBColor(json['corrected_rgb']),
      hex: json['hex'] ?? '#000000',
      cmyk: CMYKColor.fromJson(json['cmyk'] ?? {}),
      ryb: RYBColor.fromJson(json['ryb'] ?? {}),
      pigmentMix: PigmentMix.fromJson(json['pigment_mix'] ?? {}),
      skinScore: json['skin_score'] ?? 0,
      skinMetrics: json['skin_metrics'] != null
          ? SkinMetrics.fromJson(json['skin_metrics'])
          : null,
      recommendedShades: List<String>.from(json['recommended_shades'] ?? []),
      recommendedProducts: (json['recommended_products'] as List? ?? [])
          .map((e) => RecommendedProduct.fromJson(e))
          .toList(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  static RGBColor _parseRGBColor(dynamic value) {
    if (value is Map<String, dynamic>) {
      return RGBColor.fromJson(value);
    } else if (value is String) {
      return RGBColor.fromString(value);
    }
    return const RGBColor(r: 0, g: 0, b: 0);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'depth': depth,
        'undertone': undertone,
        'raw_rgb': rawRgb.toString(),
        'corrected_rgb': correctedRgb.toString(),
        'hex': hex,
        'cmyk': cmyk.toJson(),
        'ryb': ryb.toJson(),
        'pigment_mix': pigmentMix.toJson(),
        'skin_score': skinScore,
        'skin_metrics': skinMetrics?.toJson(),
        'recommended_shades': recommendedShades,
        'recommended_products':
            recommendedProducts.map((e) => e.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
      };
}

class RecommendedProduct {
  final String id;
  final String brand;
  final String shadeName;
  final String priceRange;
  final String affiliateUrl;
  final String hexReference;

  RecommendedProduct({
    required this.id,
    required this.brand,
    required this.shadeName,
    required this.priceRange,
    required this.affiliateUrl,
    required this.hexReference,
  });

  factory RecommendedProduct.fromJson(Map<String, dynamic> json) {
    return RecommendedProduct(
      id: json['id'] ?? '',
      brand: json['brand'] ?? '',
      shadeName: json['shade_name'] ?? '',
      priceRange: json['price_range'] ?? '',
      affiliateUrl: json['affiliate_url'] ?? '',
      hexReference: json['hex_reference'] ?? '#000000',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brand': brand,
        'shade_name': shadeName,
        'price_range': priceRange,
        'affiliate_url': affiliateUrl,
        'hex_reference': hexReference,
      };
}

class RGBColor {
  final int r;
  final int g;
  final int b;

  const RGBColor({required this.r, required this.g, required this.b});

  factory RGBColor.fromString(String s) {
    final parts = s.split(',');
    if (parts.length != 3) return const RGBColor(r: 0, g: 0, b: 0);
    return RGBColor(
      r: int.tryParse(parts[0].trim()) ?? 0,
      g: int.tryParse(parts[1].trim()) ?? 0,
      b: int.tryParse(parts[2].trim()) ?? 0,
    );
  }

  factory RGBColor.fromJson(Map<String, dynamic> json) => RGBColor(
        r: json['r'] ?? 0,
        g: json['g'] ?? 0,
        b: json['b'] ?? 0,
      );

  @override
  String toString() => '$r, $g, $b';
  Map<String, dynamic> toJson() => {'r': r, 'g': g, 'b': b};

  int toARGB() => 0xFF000000 | (r << 16) | (g << 8) | b;
}

class CMYKColor {
  final double c;
  final double m;
  final double y;
  final double k;

  const CMYKColor(
      {required this.c, required this.m, required this.y, required this.k});

  factory CMYKColor.fromJson(Map<String, dynamic> json) => CMYKColor(
        c: (json['c'] ?? 0).toDouble(),
        m: (json['m'] ?? 0).toDouble(),
        y: (json['y'] ?? 0).toDouble(),
        k: (json['k'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {'c': c, 'm': m, 'y': y, 'k': k};
  String get formatted =>
      'C:${c.round()}% M:${m.round()}% Y:${y.round()}% K:${k.round()}%';
}

class RYBColor {
  final double r;
  final double y;
  final double b;

  const RYBColor({required this.r, required this.y, required this.b});

  factory RYBColor.fromJson(Map<String, dynamic> json) => RYBColor(
        r: (json['r'] ?? 0).toDouble(),
        y: (json['y'] ?? 0).toDouble(),
        b: (json['b'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {'r': r, 'y': y, 'b': b};
  String get formatted => 'R:${r.round()} Y:${y.round()} B:${b.round()}';
}

class PigmentMix {
  final double yellow;
  final double red;
  final double blue;
  final double white;
  final double black;

  const PigmentMix({
    required this.yellow,
    required this.red,
    required this.blue,
    required this.white,
    required this.black,
  });

  factory PigmentMix.fromJson(Map<String, dynamic> json) => PigmentMix(
        yellow: (json['yellow'] ?? 0).toDouble(),
        red: (json['red'] ?? 0).toDouble(),
        blue: (json['blue'] ?? 0).toDouble(),
        white: (json['white'] ?? 0).toDouble(),
        black: (json['black'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'yellow': yellow,
        'red': red,
        'blue': blue,
        'white': white,
        'black': black,
      };
}

class SkinMetrics {
  final int hydration;
  final int texture;
  final int evenness;
  final int radiance;

  const SkinMetrics({
    required this.hydration,
    required this.texture,
    required this.evenness,
    required this.radiance,
  });

  factory SkinMetrics.fromJson(Map<String, dynamic> json) => SkinMetrics(
        hydration: json['hydration'] ?? 0,
        texture: json['texture'] ?? 0,
        evenness: json['evenness'] ?? 0,
        radiance: json['radiance'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'hydration': hydration,
        'texture': texture,
        'evenness': evenness,
        'radiance': radiance,
      };
}
