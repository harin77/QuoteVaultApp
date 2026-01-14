import 'package:flutter/material.dart';

import 'core/supabase_client.dart';
import 'notifications/daily_quote_service.dart';
import 'auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  // Replace with your Supabase project URL and anon key
  await SupabaseService.initialize(
    url: 'https://sorrycant.supabase.co',
    anonKey: 'sb_sorrycant-sg3n6',
  );

  // Initialize notifications
  await DailyQuoteService.initialize();

  runApp(const QuoteVaultApp());
}

class QuoteVaultApp extends StatelessWidget {
  const QuoteVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}
