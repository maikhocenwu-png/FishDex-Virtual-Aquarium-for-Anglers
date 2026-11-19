import 'package:flutter_test/flutter_test.dart';

import 'package:fishdex/data/store.dart';

void main() {
  test('fmtDate shows month and day', () {
    expect(fmtDate(DateTime(2026, 11, 19)), 'Nov 19');
  });

  test('fmtTime uses 12-hour time', () {
    expect(fmtTime(DateTime(2026, 11, 19, 15, 5)), '3:05 PM');
    expect(fmtTime(DateTime(2026, 11, 19, 0, 7)), '12:07 AM');
  });

  test('sizeText joins length and weight', () {
    final c = CatchItem(
      id: '1',
      species: 'Largemouth bass',
      caughtAt: DateTime(2026, 11, 19),
      length: '38',
      weight: '0.9',
    );
    expect(c.sizeText, '38 cm, 0.9 kg');
  });

  test('sizeText says Not given when empty', () {
    final c = CatchItem(
      id: '2',
      species: 'Bluegill',
      caughtAt: DateTime(2026, 11, 19),
    );
    expect(c.sizeText, 'Not given');
  });

  test('a catch with no photo does not need an upload', () {
    final c = CatchItem(
      id: '3',
      species: 'Bluegill',
      caughtAt: DateTime(2026, 11, 19),
    );
    expect(c.hasPhoto, false);
    expect(c.needsUpload, false);
  });
}
