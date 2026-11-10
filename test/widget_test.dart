import 'package:flutter_test/flutter_test.dart';

import 'package:fishdex/app.dart';
import 'package:fishdex/ui/widgets.dart';

void main() {
  testWidgets('sign in opens the catches list', (tester) async {
    await tester.pumpWidget(const FishDexApp());
    expect(find.text('FishDex'), findsOneWidget);

    await tester.tap(find.widgetWithText(DarkButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('My catches'), findsOneWidget);
    expect(find.text('Largemouth bass'), findsOneWidget);
  });
}
