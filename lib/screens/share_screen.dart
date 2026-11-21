import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/store.dart';
import '../ui/share_card.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';

/// A.9 Share. Shows the picture a friend would get, then hands it to the
/// phone's share sheet (WhatsApp, Photos, mail, ...).
///
/// Two things it can share:
///  * the whole aquarium, opened from the Aquarium tab;
///  * one catch, opened from Catch details ([catchId] is not null).
///
/// Everything on the card goes through the privacy switches in Profile and
/// privacy: a hidden place or a hidden photo is never drawn, and the text that
/// goes with the picture does not mention it either.
class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key, this.catchId});

  /// null = share the whole aquarium; otherwise share just this catch.
  final String? catchId;

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final GlobalKey _cardKey = GlobalKey();
  final GlobalKey _buttonKey = GlobalKey();

  /// The photos the card is allowed to show, already loaded.
  List<SharePhoto> _photos = const [];

  /// Which set of photo sources [_photos] was made from.
  String _photoKey = '';

  bool _sharing = false;

  /// The catch to share, or null when the whole aquarium is shared.
  CatchItem? get _oneCatch {
    final id = widget.catchId;
    if (id == null) return null;
    for (final c in store.catches) {
      if (c.id == id) return c;
    }
    return null;
  }

  ShareCardData _buildData() {
    final one = _oneCatch;
    if (one != null) {
      return catchShare(
        one,
        shareLocation: store.shareLocation,
        sharePhotos: store.sharePhotos,
      );
    }
    return aquariumShare(
      store.catches,
      shareLocation: store.shareLocation,
      sharePhotos: store.sharePhotos,
    );
  }

  /// Loads the photos once per set of visible photos, after the frame is drawn
  /// so the card does not get a new photo halfway through a build.
  void _schedulePhotos(ShareCardData data) {
    final key = [
      for (final c in data.photoSources) '${c.id}|${c.localPhoto}|${c.photoPath}',
    ].join(',');
    if (key == _photoKey) return;
    _photoKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final photos = await data.resolvePhotos(store.photoUrl);
      if (!mounted) return;
      setState(() => _photos = photos);
    });
  }

  /// Photos that may be shown right now. Anything else is dropped at once, so
  /// switching "Share photos" off takes the photos off the card immediately.
  List<SharePhoto> _visiblePhotos(ShareCardData data) {
    if (data.photoSources.isEmpty) return const [];
    final allowed = {for (final c in data.photoSources) c.id};
    return [
      for (final photo in _photos)
        if (allowed.contains(photo.catchId)) photo,
    ];
  }

  /// Draws the card into a PNG file, then opens the phone's share sheet.
  Future<void> _share(ShareCardData data) async {
    if (_sharing || data.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sharing = true);
    try {
      final photos = await data.resolvePhotos(store.photoUrl);
      if (!mounted) return;
      await _precachePhotos(photos);
      if (!mounted) return;
      setState(() => _photos = photos);
      await _savePictureAndShare(data);
    } catch (e) {
      debugPrint('share error: $e');
      if (!mounted) return;
      await _copyTextInstead(messenger, data);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _savePictureAndShare(ShareCardData data) async {
    final boundary =
        _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) throw StateError('The card is not ready yet');
    await _waitForPaint(boundary);

    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (bytes == null) throw StateError('Could not draw the picture');

    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, shareFileName(data)));
    await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        text: data.caption,
        title: data.title,
        subject: data.title,
        sharePositionOrigin: _shareOrigin(),
      ),
    );
  }

  /// Waits until the card has really been painted, so the picture is not blank.
  ///
  /// [RenderRepaintBoundary.debugNeedsPaint] is always false in a release
  /// build, so the extra short wait is what gives the raster thread time there.
  Future<void> _waitForPaint(RenderRepaintBoundary boundary) async {
    await WidgetsBinding.instance.endOfFrame;
    for (var i = 0; i < 4 && boundary.debugNeedsPaint; i++) {
      await WidgetsBinding.instance.endOfFrame;
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }

  /// Loads the photos into the image cache, so drawing the card does not wait
  /// for the network. A photo that is too slow is simply left out.
  Future<void> _precachePhotos(List<SharePhoto> photos) async {
    for (final photo in photos) {
      try {
        final file = photo.file;
        final url = photo.url;
        if (file != null) {
          await precacheImage(
            FileImage(File(file)),
            context,
            onError: (_, _) {},
          ).timeout(const Duration(seconds: 3));
        } else if (url != null) {
          await precacheImage(
            NetworkImage(url),
            context,
            onError: (_, _) {},
          ).timeout(const Duration(seconds: 4));
        }
      } catch (e) {
        debugPrint('photo not ready: $e');
      }
    }
  }

  /// Where the share sheet should pop from on an iPad. Ignored elsewhere.
  Rect? _shareOrigin() {
    final box = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  /// If the share sheet cannot open (for example on a device without one), the
  /// text is copied instead so the angler still gets something.
  Future<void> _copyTextInstead(
    ScaffoldMessengerState messenger,
    ShareCardData data,
  ) async {
    try {
      await Clipboard.setData(ClipboardData(text: data.caption));
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not open the share sheet. The text was copied.'),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not share. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final missing = widget.catchId != null && _oneCatch == null;
        final data = _buildData();
        if (!missing) _schedulePhotos(data);
        final photos = _visiblePhotos(data);
        final canShare = !missing && !data.isEmpty && !_sharing;

        return Scaffold(
          body: Column(
            children: [
              TopBar(
                title: data.single ? 'Share this catch' : 'Share preview',
                back: '<',
              ),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (missing)
                          const Text(
                            'Catch not found',
                            style: TextStyle(fontSize: 13, color: kMuted),
                          )
                        else ...[
                          Text(
                            data.single
                                ? 'This is what your friends will see when you '
                                      'share this catch'
                                : 'This is what your friends will see',
                            style: const TextStyle(
                              fontSize: 13,
                              color: kMuted,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: RepaintBoundary(
                              key: _cardKey,
                              child: MediaQuery.withNoTextScaling(
                                child: ShareCard(data: data, photos: photos),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        // The same switches as Profile and privacy, right here,
                        // so the angler can check the card photo by photo
                        // without leaving the preview.
                        ShareSwitches(
                          shareLocation: store.shareLocation,
                          sharePhotos: store.sharePhotos,
                          onShareLocation: store.setShareLocation,
                          onSharePhotos: store.setSharePhotos,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'These are the same switches as in Profile and '
                          'privacy.',
                          style: TextStyle(fontSize: 12, color: kMuted),
                        ),
                        const SizedBox(height: 20),
                        if (data.isEmpty && !missing) ...[
                          const Text(
                            'Add a catch first: your aquarium has no fish to '
                            'share yet.',
                            style: TextStyle(fontSize: 13, color: kMuted),
                          ),
                          const SizedBox(height: 10),
                        ],
                        DarkButton(
                          _sharing ? 'Preparing the picture...' : 'Share',
                          key: _buttonKey,
                          enabled: canShare,
                          onTap: () => _share(data),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The two privacy switches under the preview. They change the same settings
/// as Profile and privacy, and the card redraws at once.
///
/// Kept as its own widget so it can be tested without the app's [AppStore].
class ShareSwitches extends StatelessWidget {
  const ShareSwitches({
    super.key,
    required this.shareLocation,
    required this.sharePhotos,
    required this.onShareLocation,
    required this.onSharePhotos,
  });

  final bool shareLocation;
  final bool sharePhotos;
  final ValueChanged<bool> onShareLocation;
  final ValueChanged<bool> onSharePhotos;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InfoRow(
          title: 'Share location',
          subtitle: 'Friends see where you caught them',
          trailing: WireSwitch(
            on: shareLocation,
            onChanged: onShareLocation,
          ),
        ),
        const SizedBox(height: 8),
        InfoRow(
          title: 'Share photos',
          subtitle: 'Friends see your catch photos',
          trailing: WireSwitch(on: sharePhotos, onChanged: onSharePhotos),
        ),
      ],
    );
  }
}
