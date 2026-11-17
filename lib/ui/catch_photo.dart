import 'dart:io';

import 'package:flutter/material.dart';

import '../data/store.dart';
import 'widgets.dart';

/// Shows a catch's photo: the local file if we have it, otherwise the photo
/// from the private Supabase bucket (through a short-lived signed link).
class CatchPhoto extends StatefulWidget {
  const CatchPhoto(this.item, {super.key, required this.height});

  final CatchItem item;
  final double height;

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

  Widget _frame(Widget child) => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: SizedBox(height: widget.height, width: double.infinity, child: child),
  );

  @override
  Widget build(BuildContext context) {
    final h = widget.height;
    final local = widget.item.localPhoto;
    if (local != null && File(local).existsSync()) {
      return _frame(Image.file(File(local), fit: BoxFit.cover));
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
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                PhotoBox(height: h, label: 'PHOTO UNAVAILABLE'),
          ),
        );
      },
    );
  }
}
