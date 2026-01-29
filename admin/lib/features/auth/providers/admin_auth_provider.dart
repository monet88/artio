import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'admin_auth_provider.g.dart';

@riverpod
class AdminAuth extends _$AdminAuth implements Listenable {
  VoidCallback? _routerListener;

  @override
  Stream<User?> build() {
    return Supabase.instance.client.auth.onAuthStateChange.map((event) {
      _notifyRouter();
      return event.session?.user;
    });
  }

  void _notifyRouter() => _routerListener?.call();

  @override
  void addListener(VoidCallback listener) => _routerListener = listener;

  @override
  void removeListener(VoidCallback listener) => _routerListener = null;

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
    } on PostgrestException catch (_) {
      // Database error during profile fetch - sign out and rethrow
      await Supabase.instance.client.auth.signOut();
      rethrow;
    } catch (_) {
      // Network/unexpected error - ensure clean state before rethrow
      await Supabase.instance.client.auth.signOut();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}
