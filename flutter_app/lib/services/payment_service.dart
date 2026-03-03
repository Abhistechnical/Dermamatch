// lib/services/payment_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

class PaymentService {
  late Razorpay _razorpay;
  final AuthService _authService = AuthService();
  final SupabaseClient _supabase = Supabase.instance.client;

  Function(String paymentId, int credits)? onSuccess;
  Function(String error)? onFailure;

  void init() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    _razorpay.clear();
  }

  /// Credit packages
  static const List<CreditPack> packs = [
    CreditPack(name: 'Starter', credits: 5, amount: 4900, label: '₹49'),
    CreditPack(name: 'Standard', credits: 15, amount: 9900, label: '₹99'),
    CreditPack(name: 'Pro', credits: 50, amount: 24900, label: '₹249'),
  ];

  Future<void> purchaseCredits({
    required CreditPack pack,
    required String userEmail,
    required String userName,
  }) async {
    final keyId = dotenv.env['RAZORPAY_KEY_ID'] ?? '';
    final options = {
      'key': keyId,
      'amount': pack.amount,
      'name': 'DermaMatch AI',
      'description': '${pack.credits} Scan Credits - ${pack.name} Pack',
      'prefill': {'contact': '', 'email': userEmail, 'name': userName},
      'theme': {'color': '#C9A84C'},
      'notes': {'credits': pack.credits.toString()},
    };
    _pendingCredits = pack.credits;
    _pendingAmount = pack.amount;

    // Razorpay flutter doesn't support Windows/macOS/Linux desktop natively
    if (Theme.of(FocusManager.instance.primaryFocus!.context!).platform == TargetPlatform.windows || 
        Theme.of(FocusManager.instance.primaryFocus!.context!).platform == TargetPlatform.macOS || 
        Theme.of(FocusManager.instance.primaryFocus!.context!).platform == TargetPlatform.linux) {
      debugPrint('Simulating Razorpay success for Desktop OS');
      Future.delayed(const Duration(seconds: 1), () {
        _handleSuccess(PaymentSuccessResponse.fromMap({
          'razorpay_payment_id': 'pay_mock_${DateTime.now().millisecondsSinceEpoch}',
          'razorpay_order_id': 'order_123',
          'razorpay_signature': 'sig_123',
        }));
      });
      return;
    }

    _razorpay.open(options);
  }

  int _pendingCredits = 0;
  int _pendingAmount = 0;

  void _handleSuccess(PaymentSuccessResponse response) async {
    final uid = _authService.currentUser?.id;
    if (uid != null) {
      // Record payment
      await _supabase.from('payments').insert({
        'user_id': uid,
        'razorpay_payment_id': response.paymentId,
        'amount': _pendingAmount,
        'status': 'success',
        'created_at': DateTime.now().toIso8601String(),
      });
      // Add credits
      await _authService.addCredits(_pendingCredits);
    }
    onSuccess?.call(response.paymentId ?? '', _pendingCredits);
  }

  void _handleError(PaymentFailureResponse response) {
    onFailure?.call(response.message ?? 'Payment failed');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External wallet: ${response.walletName}');
  }
}

class CreditPack {
  final String name;
  final int credits;
  final int amount; // paise
  final String label;

  const CreditPack({
    required this.name,
    required this.credits,
    required this.amount,
    required this.label,
  });
}
