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
    await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> login({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  Future<void> ensureProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final profile = await Supabase.instance.client
      .from('profiles')
      .select('id')
      .eq('id', user.id)
      .maybeSingle();

    if (profile == null) {
      await Supabase.instance.client.from('profiles').insert({
        'id': user.id,
        'email': user.email,
      });
    }
  }


  bool get isLoggedIn => _client.auth.currentSession != null;
}
