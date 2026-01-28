import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'admin_auth_provider.g.dart';

@riverpod
class AdminAuth extends _$AdminAuth {
  @override
  Stream<User?> build() {
    return Supabase.instance.client.auth.onAuthStateChange.map((event) => event.session?.user);
  }

  Future<void> login(String email, String password) async {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    if (response.user == null) throw Exception('Login failed');

    // Check role
    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();

      if (profile['role'] != 'admin') {
        await Supabase.instance.client.auth.signOut();
        throw Exception('Access Denied: You do not have admin privileges.');
      }
    } catch (e) {
      // If profile fetch fails or check fails, ensure we sign out
      await Supabase.instance.client.auth.signOut();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}
