import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:fishdex/data/store.dart';
import 'package:fishdex/ui/share_card.dart';

CatchItem _catch({
  String id = '1',
  String species = 'Largemouth bass',
  DateTime? caughtAt,
  String place = '',
  String length = '',
  String weight = '',
  bool fed = true,
  String? photoPath,
  String? localPhoto,
}) {
  return CatchItem(
    id: id,
    species: species,
    caughtAt: caughtAt ?? DateTime(2026, 11, 19, 15, 5),
    place: place,
    length: length,
    weight: weight,
    photoPath: photoPath,
    localPhoto: localPhoto,
    uploaded: true,
    fed: fed,
  );
}

void main() {
  group('aquarium card', () {
    test('hides the place when location sharing is off', () {
      final data = aquariumShare(
        [_catch(place: 'Lake Ontario')],
        shareLocation: false,
        sharePhotos: false,
      );
      expect(data.facts.any((f) => f.label == 'Place'), isFalse);
      expect(data.caption.contains('Lake Ontario'), isFalse);
    });

    test('shows the newest place when location sharing is on', () {
      final data = aquariumShare(
        [
          _catch(id: 'old', place: 'Old Pond', caughtAt: DateTime(2026, 10, 2)),
          _catch(
            id: 'new',
            place: 'Lake Ontario',
            caughtAt: DateTime(2026, 11, 19),
          ),
        ],
        shareLocation: true,
        sharePhotos: false,
      );
      expect(
        data.facts.firstWhere((f) => f.label == 'Place').value,
        'Lake Ontario',
      );
      expect(data.caption.contains('Lake Ontario'), isTrue);
    });

    test('hides the photos when photo sharing is off', () {
      final data = aquariumShare(
        [_catch(photoPath: 'user/1.jpg')],
        shareLocation: false,
        sharePhotos: false,
      );
      expect(data.photoSources, isEmpty);
    });

    test('collects at most three photos', () {
      final data = aquariumShare(
        [for (var i = 0; i < 5; i++) _catch(id: '$i', photoPath: 'user/$i.jpg')],
        shareLocation: false,
        sharePhotos: true,
      );
      expect(data.photoSources.length, 3);
    });

    test('only counts fish that are in the aquarium', () {
      final data = aquariumShare(
        [_catch(id: 'a'), _catch(id: 'b', fed: false)],
        shareLocation: false,
        sharePhotos: false,
      );
      expect(data.fish.length, 1);
      expect(data.facts.firstWhere((f) => f.label == 'Fish').value, '1');
    });

    test('draws at most eight fish but counts them all', () {
      final data = aquariumShare(
        [for (var i = 0; i < 11; i++) _catch(id: '$i')],
        shareLocation: false,
        sharePhotos: false,
      );
      expect(data.fish.length, 8);
      expect(data.moreFish, 3);
    });

    test('says the tank is empty', () {
      final data = aquariumShare(
        [],
        shareLocation: true,
        sharePhotos: true,
      );
      expect(data.isEmpty, isTrue);
      expect(data.subtitle, contains('No fish'));
    });
  });

  group('one catch card', () {
    test('keeps the place private when location sharing is off', () {
      final data = catchShare(
        _catch(place: 'Lake Ontario', length: '38', weight: '0.9'),
        shareLocation: false,
        sharePhotos: false,
      );
      expect(data.facts.any((f) => f.label == 'Place'), isFalse);
      expect(data.caption.contains('Lake Ontario'), isFalse);
      expect(data.caption.contains('38 cm'), isTrue);
    });

    test('includes the place when location sharing is on', () {
      final data = catchShare(
        _catch(place: 'Lake Ontario'),
        shareLocation: true,
        sharePhotos: false,
      );
      expect(
        data.facts.firstWhere((f) => f.label == 'Place').value,
        'Lake Ontario',
      );
      expect(data.caption, contains('Place: Lake Ontario'));
    });
  });

  group('picture file name', () {
    test('uses the species of the catch', () {
      final data = catchShare(
        _catch(species: 'Largemouth bass'),
        shareLocation: false,
        sharePhotos: false,
      );
      expect(shareFileName(data), 'fishdex-largemouth-bass.png');
    });

    test('falls back when the name has no letters', () {
      final data = catchShare(
        _catch(species: '鲈鱼'),
        shareLocation: false,
        sharePhotos: false,
      );
      expect(shareFileName(data), 'fishdex-catch.png');
    });

    test('names the aquarium picture', () {
      final data = aquariumShare(
        [],
        shareLocation: false,
        sharePhotos: false,
      );
      expect(shareFileName(data), 'fishdex-aquarium.png');
    });
  });

  group('photos on the card', () {
    test('are not even asked for when they are private', () async {
      var asked = false;
      final data = aquariumShare(
        [_catch(photoPath: 'user/1.jpg')],
        shareLocation: false,
        sharePhotos: false,
      );
      final photos = await data.resolvePhotos((path) async {
        asked = true;
        return 'https://example.com/$path';
      });
      expect(photos, isEmpty);
      expect(asked, isFalse);
    });

    test('use the signed link when the photo is only online', () async {
      final data = aquariumShare(
        [_catch(photoPath: 'user/1.jpg')],
        shareLocation: false,
        sharePhotos: true,
      );
      final photos = await data.resolvePhotos(
        (path) async => 'https://example.com/$path',
      );
      expect(photos.single.url, 'https://example.com/user/1.jpg');
    });
  });

  group('card widget', () {
    testWidgets('does not draw a hidden place', (tester) async {
      final data = aquariumShare(
        [_catch(species: 'Bluegill', place: 'Lake Ontario')],
        shareLocation: false,
        sharePhotos: false,
      );
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ShareCard(data: data))),
      );
      expect(find.text('Bluegill'), findsOneWidget);
      expect(find.text('Place'), findsNothing);
      expect(find.text('Lake Ontario'), findsNothing);
    });

    testWidgets('draws the place when it is shared', (tester) async {
      final data = aquariumShare(
        [_catch(species: 'Bluegill', place: 'Lake Ontario')],
        shareLocation: true,
        sharePhotos: false,
      );
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ShareCard(data: data))),
      );
      expect(find.text('Place'), findsOneWidget);
      expect(find.text('Lake Ontario'), findsOneWidget);
    });

    testWidgets('tells the angler there is nothing to share', (tester) async {
      final data = aquariumShare(
        [],
        shareLocation: false,
        sharePhotos: false,
      );
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ShareCard(data: data))),
      );
      expect(find.text('No fish yet'), findsOneWidget);
    });

    testWidgets('draws a shared photo only once on a single catch card', (
      tester,
    ) async {
      final file = File(
        '${Directory.systemTemp.path}/fishdex_card_test_photo.png',
      )..writeAsBytesSync(const [0x89, 0x50, 0x4E, 0x47]);
      addTearDown(() {
        if (file.existsSync()) file.deleteSync();
      });
      final data = catchShare(
        _catch(photoPath: 'user/1.jpg'),
        shareLocation: false,
        sharePhotos: true,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShareCard(
              data: data,
              photos: [
                SharePhoto(catchId: '1', file: file.path, label: 'Bluegill'),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
