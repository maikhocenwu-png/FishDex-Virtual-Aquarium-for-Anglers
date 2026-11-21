import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:fishdex/screens/share_screen.dart';
import 'package:fishdex/ui/widgets.dart';

/// The switches live on the share preview so the angler can un-hide a photo
/// and see the card change without going back to Profile.
void main() {
  testWidgets('the photo switch calls back and shows ON', (tester) async {
    var location = false;
    var photos = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => ShareSwitches(
              shareLocation: location,
              sharePhotos: photos,
              onShareLocation: (v) => setState(() => location = v),
              onSharePhotos: (v) => setState(() => photos = v),
            ),
          ),
        ),
      ),
    );

    expect(find.text('OFF'), findsNWidgets(2));

    // The second switch is the photos one.
    await tester.tap(find.byType(WireSwitch).at(1));
    await tester.pump();

    expect(photos, isTrue);
    expect(location, isFalse);
    expect(find.text('ON'), findsOneWidget);
    expect(find.text('OFF'), findsOneWidget);
  });

  testWidgets('the location switch only changes the location flag', (
    tester,
  ) async {
    var location = false;
    var photos = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => ShareSwitches(
              shareLocation: location,
              sharePhotos: photos,
              onShareLocation: (v) => setState(() => location = v),
              onSharePhotos: (v) => setState(() => photos = v),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(WireSwitch).first);
    await tester.pump();

    expect(location, isTrue);
    expect(photos, isFalse);
  });
}
