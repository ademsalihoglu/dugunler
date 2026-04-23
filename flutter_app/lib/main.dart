// =====================================================
// DüğünDefteri - Main Entry Point
// =====================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/supabase/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Supabase Init
  await SupabaseConfig.init();
  
  runApp(const ProviderScope(child: DugunDefteriApp()));
}

class DugunDefteriApp extends StatelessWidget {
  const DugunDefteriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DüğünDefteri',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    final user = SupabaseConfig.currentUser;
    if (user != null) {
      return const HomeScreen();
    }
    return const AuthScreen();
  }
}