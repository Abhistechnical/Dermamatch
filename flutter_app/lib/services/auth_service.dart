// lib/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    if (response.user != null) {
      // Create user record in public.users
      await _client.from('users').upsert({
        'id': response.user!.id,
        'email': email,
        'plan_type': 'free',
        'credits': 3, // 3 free scans on signup
        'created_at': DateTime.now().toIso8601String(),
      });
    }
    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<UserModel?> fetchUserProfile() async {
    final uid = currentUser?.id;
    if (uid == null) return null;
    final data = await _client.from('users').select().eq('id', uid).single();
    return UserModel.fromJson(data);
  }

  Future<UserModel?> deductCredit() async {
    final uid = currentUser?.id;
    if (uid == null) return null;

    // Fetch current credits
    final data =
        await _client.from('users').select('credits').eq('id', uid).single();
    final credits = data['credits'] as int;
    if (credits <= 0) throw Exception('No credits remaining');

    final updated = await _client
        .from('users')
        .update({'credits': credits - 1})
        .eq('id', uid)
        .select()
        .single();

    return UserModel.fromJson(updated);
  }

  Future<void> addCredits(int amount) async {
    final uid = currentUser?.id;
    if (uid == null) return;
    final data =
        await _client.from('users').select('credits').eq('id', uid).single();
    final credits = data['credits'] as int;
    await _client
        .from('users')
        .update({'credits': credits + amount}).eq('id', uid);
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }
}
