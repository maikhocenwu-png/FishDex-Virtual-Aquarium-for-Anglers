import 'package:flutter_test/flutter_test.dart';

import 'package:fishdex/app.dart';

void main() {
  testWidgets('shows the sign in screen', (tester) async {
    await tester.pumpWidget(const FishDexApp());
    expect(find.text('FishDex'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });
}