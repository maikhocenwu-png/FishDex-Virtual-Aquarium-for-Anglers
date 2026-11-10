import 'package:flutter/material.dart';

import 'screens/auth_screens.dart';
import 'ui/theme.dart';

class FishDexApp extends StatelessWidget {
  const FishDexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FishDex',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const SignInScreen(),
    );
  }
}
