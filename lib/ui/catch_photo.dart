import 'dart:io';

import 'package:flutter/material.dart';

import '../data/store.dart';
import 'widgets.dart';

/// Shows a catch's photo: the local file if we have it, otherwise the photo
/// from the private Supabase bucket (through a short-lived signed link).
///
/// fit: BoxFit.cover fills the box (crops the edges, good for thumbnails);
///      BoxFit.contain shows the WHOLE photo (good for the details screen).
/// tapToZoom: tapping opens the photo full screen.
class CatchPhoto extends StatefulWidget {
  const CatchPhoto(
    this.item, {
    super.key,
    required this.height,
    this.fit = BoxFit.cover,
    this.tapToZoom = false,
  });

  final CatchItem item;
  final double height;
  final BoxFit fit;
  final bool tapToZoom;

  @override
  State<CatchPhoto> createState() => _CatchPhotoState();
}

class _CatchPhotoState extends State<CatchPhoto> {
  Future<String?>? _url;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(CatchPhoto old) {
    super.didUpdateWidget(old);
    if (old.item.photoPath != widget.item.photoPath) _load();
  }

  void _load() {
    final p = widget.item.photoPath;
    _url = p == null ? null : store.photoUrl(p);
  }

  Widget _frame(Widget child) {
    final box = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: widget.height,
        width: double.infinity,
        // grey bars around a photo that does not fill the box
        color: widget.fit == BoxFit.contain ? const Color(0xFFEFEFEF) : null,
        child: child,
      ),
    );
    if (!widget.tapToZoom) return box;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PhotoViewerScreen(widget.item)),
      ),
      child: box,
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height;
    final local = widget.item.localPhoto;
    if (local != null && File(local).existsSync()) {
      return _frame(Image.file(File(local), fit: widget.fit));
    }
    if (_url == null) return PhotoBox(height: h, label: 'NO PHOTO');
    return FutureBuilder<String?>(
      future: _url,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return PhotoBox(height: h, label: 'LOADING...');
        }
        final url = snap.data;
        if (url == null) return PhotoBox(height: h, label: 'PHOTO UNAVAILABLE');
        return _frame(
          Image.network(
            url,
            fit: widget.fit,
            errorBuilder: (_, _, _) =>
                PhotoBox(height: h, label: 'PHOTO UNAVAILABLE'),
          ),
        );
      },
    );
  }
}

/// Full-screen photo. Pinch to zoom, drag to move.
class PhotoViewerScreen extends StatelessWidget {
  const PhotoViewerScreen(this.item, {super.key});

  final CatchItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(item.species),
      ),
      body: SafeArea(
        child: Center(
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: CatchPhoto(
              item,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
