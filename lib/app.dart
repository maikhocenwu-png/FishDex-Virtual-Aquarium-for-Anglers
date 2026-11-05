import 'package:flutter/material.dart';

import 'features/home/home_shell.dart';

class FishDexApp extends StatelessWidget {
  const FishDexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FishDex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: const HomeShell(),
    );
  }
}