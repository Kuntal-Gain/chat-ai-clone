import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServices {
  final SupabaseClient _supabase = Supabase.instance.client;

  // signin
  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      password: password,
      email: email,
    );
  }

  // signup
  Future<AuthResponse> signUp(String email, String password) async {
    return await _supabase.auth.signUp(
      password: password,
      email: email,
    );
  }

  // signout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // get user email
  String? getCurrentEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;

    return user?.email;
  }
}
