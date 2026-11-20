import 'dart:io';

import 'package:material_ui/material_ui.dart';

import '../data/store.dart';
import 'theme.dart';
import 'widgets.dart';

/// One photo that can appear on a share card.
///
/// The file on the phone is preferred (it works with no internet). Otherwise
/// [url] is a temporary signed link to the private photo in Supabase Storage,
/// made by [AppStore.photoUrl].
class SharePhoto {
  const SharePhoto({
    required this.catchId,
    this.file,
    this.url,
    this.label = '',
  });

  /// Which catch this photo belongs to, so the screen can drop a photo as soon
  /// as the angler switches sharing off.
  final String catchId;

  final String? file;
  final String? url;

  /// The species, shown when the photo needs a caption.
  final String label;
}

/// One "label / value" line under the fish (Place, Caught, Size, ...).
class ShareFact {
  const ShareFact(this.label, this.value);

  final String label;
  final String value;
}

/// The content of one share card, already filtered by the privacy switches.
///
/// The card and the text that goes with it are built from this object, so a
/// hidden place or a hidden photo can never reach the picture or the message:
/// [facts] simply has no Place line and [photoSources] is empty.
class ShareCardData {
  ShareCardData({
    required this.single,
    required this.title,
    required this.subtitle,
    required this.fish,
    required this.facts,
    required this.photoSources,
    required this.caption,
    this.moreFish = 0,
  });

  /// true = one catch, false = the whole aquarium.
  final bool single;

  final String title; // 'My aquarium' or the species name
  final String subtitle;
  final List<CatchItem> fish; // the fish drawn on the card
  final List<ShareFact> facts;
  final List<CatchItem> photoSources; // empty when photos are private
  final String caption; // the text shared together with the picture
  final int moreFish; // fish that did not fit on the card

  bool get isEmpty => fish.isEmpty;

  /// How many photos a card may show.
  static const int maxPhotos = 3;

  /// Turns [photoSources] into photos the card can draw. Nothing is returned
  /// when photos are private, so the privacy rule stays in one place.
  Future<List<SharePhoto>> resolvePhotos(
    Future<String?> Function(String storagePath) signedUrl,
  ) async {
    final out = <SharePhoto>[];
    for (final c in photoSources) {
      if (out.length >= maxPhotos) break;
      final local = c.localPhoto;
      if (local != null && local.isNotEmpty && File(local).existsSync()) {
        out.add(SharePhoto(catchId: c.id, file: local, label: c.species));
        continue;
      }
      final remote = c.photoPath;
      if (remote == null || remote.isEmpty) continue;
      final url = await signedUrl(remote);
      if (url == null || url.isEmpty) continue;
      out.add(SharePhoto(catchId: c.id, url: url, label: c.species));
    }
    return out;
  }
}

/// The whole-aquarium card. Only fish that came from a real catch are drawn.
ShareCardData aquariumShare(
  List<CatchItem> catches, {
  required bool shareLocation,
  required bool sharePhotos,
}) {
  final fish = [for (final c in catches) if (c.fed) c]
    ..sort((a, b) => b.caughtAt.compareTo(a.caughtAt));
  final shown = fish.take(8).toList();
  final place = shareLocation ? _lastPlace(fish) : null;
  final species = {for (final c in fish) c.species}.length;

  return ShareCardData(
    single: false,
    title: 'My aquarium',
    subtitle: fish.isEmpty
        ? 'No fish yet. Add a catch to fill the tank.'
        : '${fish.length} fish, all from real catches',
    fish: shown,
    moreFish: fish.length - shown.length,
    facts: [
      ShareFact('Fish', '${fish.length}'),
      ShareFact('Species', '$species'),
      if (place != null) ShareFact('Place', place),
      if (fish.isNotEmpty) ShareFact('Since', '${fish.last.caughtAt.year}'),
    ],
    photoSources: sharePhotos
        ? [for (final c in fish) if (c.hasPhoto) c]
              .take(ShareCardData.maxPhotos)
              .toList()
        : const [],
    caption: _aquariumCaption(fish, place: place),
  );
}

/// The card for one catch, opened from Catch details.
ShareCardData catchShare(
  CatchItem c, {
  required bool shareLocation,
  required bool sharePhotos,
}) {
  final place = shareLocation && c.place.isNotEmpty ? c.place : null;
  return ShareCardData(
    single: true,
    title: c.species,
    subtitle: 'From my FishDex collection',
    fish: [c],
    facts: [
      ShareFact('Caught', '${fmtDate(c.caughtAt)}, ${c.caughtAt.year}'),
      ShareFact('Size', c.sizeText),
      if (place != null) ShareFact('Place', place),
    ],
    photoSources: sharePhotos && c.hasPhoto ? [c] : const [],
    caption: _catchCaption(c, place: place),
  );
}

/// A file name for the picture, safe on every phone.
/// 'Largemouth bass' becomes 'fishdex-largemouth-bass.png'.
String shareFileName(ShareCardData data) {
  if (!data.single) return 'fishdex-aquarium.png';
  final slug = data.title
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp('^-+|-+\$'), '');
  return 'fishdex-${slug.isEmpty ? 'catch' : slug}.png';
}

/// The newest place among the fish, or null when none has one.
String? _lastPlace(List<CatchItem> fish) {
  for (final c in fish) {
    if (c.place.isNotEmpty) return c.place;
  }
  return null;
}

String _aquariumCaption(List<CatchItem> fish, {String? place}) {
  final text = StringBuffer(
    'My FishDex aquarium: ${fish.length} fish from real catches.',
  );
  if (fish.isEmpty) text.write('\nNothing in the tank yet.');
  if (place != null) text.write('\nLast place: $place');
  text.write('\nShared from FishDex.');
  return text.toString();
}

String _catchCaption(CatchItem c, {String? place}) {
  final text = StringBuffer(
    '${c.species}\n${fmtDate(c.caughtAt)}, ${c.caughtAt.year}',
  );
  if (c.length.isNotEmpty || c.weight.isNotEmpty) {
    text.write(' - ${c.sizeText}');
  }
  if (place != null) text.write('\nPlace: $place');
  text.write('\nShared from FishDex.');
  return text.toString();
}

/// The picture the angler shares: white card, gray border, same wireframe look
/// as the rest of the app.
///
/// The card never reads the privacy switches itself. [ShareCardData] has
/// already removed anything the angler keeps private, and [photos] only holds
/// the photos that are allowed to be shown.
class ShareCard extends StatelessWidget {
  const ShareCard({super.key, required this.data, this.photos = const []});

  final ShareCardData data;
  final List<SharePhoto> photos;

  /// Fixed width, so the picture looks the same on every phone.
  static const double cardWidth = 320;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cardWidth,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kLine),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kInk,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
                  style: const TextStyle(fontSize: 11, color: kMuted),
                ),
                const SizedBox(height: 14),
                _petArea(),
                // The single-catch card already shows its photo as the big
                // picture, so only the aquarium card gets a photo strip.
                if (photos.isNotEmpty && !data.single) ...[
                  const SizedBox(height: 12),
                  _photoStrip(),
                ],
                const SizedBox(height: 14),
                Container(height: 1, color: kTag),
                const SizedBox(height: 6),
                for (final fact in data.facts) _factRow(fact),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Shared from FishDex',
                    style: TextStyle(
                      fontSize: 10,
                      color: kMuted,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      color: kBar,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: [
          const Text(
            'FishDex',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: kInk,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Text(
            data.single ? 'A REAL CATCH' : 'MY AQUARIUM',
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: kMuted,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  /// The fish (or the one catch's photo), never a photo when photos are private.
  Widget _petArea() {
    if (data.fish.isEmpty) {
      return Container(
        height: 92,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          border: Border.all(color: kTag),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'No fish yet',
          style: TextStyle(fontSize: 12, color: kMuted),
        ),
      );
    }

    if (data.single) {
      if (photos.isNotEmpty) return _heroPhoto(photos.first);
      return Center(
        child: FishShape(species: data.fish.first.species, width: 190),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in data.fish)
              SizedBox(
                width: 62,
                child: Column(
                  children: [
                    FishShape(species: c.species, width: 58),
                    const SizedBox(height: 2),
                    Text(
                      c.species,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9,
                        height: 1.15,
                        color: kMuted,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        if (data.moreFish > 0)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '+${data.moreFish} more fish',
              style: const TextStyle(fontSize: 10, color: kMuted),
            ),
          ),
      ],
    );
  }

  Widget _heroPhoto(SharePhoto photo) {
    // contain, not cover: a shared catch photo should show the whole fish,
    // not a crop of it.
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 230,
        width: double.infinity,
        color: const Color(0xFFF7F7F7),
        child: _photoImage(photo, fit: BoxFit.contain),
      ),
    );
  }

  Widget _photoStrip() {
    final shown = photos.take(ShareCardData.maxPhotos).toList();
    return Row(
      children: [
        for (var i = 0; i < shown.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 74,
                width: double.infinity,
                child: _photoImage(shown[i]),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _photoImage(SharePhoto photo, {BoxFit fit = BoxFit.cover}) {
    final file = photo.file;
    final url = photo.url;
    Widget broken(BuildContext context, Object error, StackTrace? stack) =>
        const PhotoBox(label: 'PHOTO');
    if (file != null) {
      return Image.file(File(file), fit: fit, errorBuilder: broken);
    }
    if (url != null) {
      return Image.network(url, fit: fit, errorBuilder: broken);
    }
    return const PhotoBox(label: 'PHOTO');
  }

  Widget _factRow(ShareFact fact) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              fact.label,
              style: const TextStyle(fontSize: 11, color: kMuted),
            ),
          ),
          Expanded(
            child: Text(
              fact.value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: kInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
