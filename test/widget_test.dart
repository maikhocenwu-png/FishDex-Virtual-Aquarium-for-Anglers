import 'package:fishdex/features/home/home_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home shell switches between screens', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeShell()));

    expect(find.text('Aquarium (milestone 4)'), findsOneWidget);

    await tester.tap(find.text('Map'));
    await tester.pump();

    expect(find.text('Map (milestone 5)'), findsOneWidget);
  });
}