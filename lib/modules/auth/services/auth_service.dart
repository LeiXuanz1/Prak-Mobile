import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  void onAuthStateChanged(void Function(Session? session) callback) {
    _client.auth.onAuthStateChange.listen((data) {
      callback(data.session);
    });
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Register gagal');
    }
  }

  Future<void> login({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  bool get isLoggedIn => _client.auth.currentSession != null;
}
