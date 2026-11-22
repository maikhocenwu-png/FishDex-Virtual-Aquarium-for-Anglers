import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/env.dart';
import 'data/store.dart';
import 'screens/auth_screens.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );

  // If the phone still has a saved login, skip the Sign in screen.
  Widget start = const SignInScreen();
  final user = Supabase.instance.client.auth.currentUser;
  if (user != null) {
    final email = user.email ?? '';
    final name = user.userMetadata?['display_name'] as String?;
    store.userEmail = email;
    store.userName = (name != null && name.isNotEmpty)
        ? name
        : email.split('@').first;
    await store.loadAll();
    start = const HomeScreen();
  }

  runApp(FishDexApp(home: start));
}
