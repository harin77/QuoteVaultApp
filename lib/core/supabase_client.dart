import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized Supabase client
class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  /// Initialize Supabase
  /// Replace with your Supabase URL and anon key
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  /// Get current user
  static User? get currentUser => client.auth.currentUser;

  /// Get current user ID
  static String? get currentUserId => client.auth.currentUser?.id;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Auth stream
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}
