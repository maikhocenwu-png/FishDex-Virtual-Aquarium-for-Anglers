import 'package:flutter/material.dart';

// Colors taken from the Figma wireframes (plain grays).
const kInk = Color(0xFF222222);
const kDark = Color(0xFF444444);
const kLine = Color(0xFF8A8A8A);
const kBar = Color(0xFFF0F0F0);
const kPhoto = Color(0xFFD9D9D9);
const kTag = Color(0xFFDDDDDD);
const kMuted = Color(0xFF6B6B6B);

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(primary: kDark),
  );
}
