import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Picks a photo (camera or gallery) and keeps a copy inside the app's own
/// folder, so the file is still there after the picker cleans up its cache.
class PhotoService {
  static final ImagePicker _picker = ImagePicker();

  /// Returns the path of the saved copy, or null if the user cancelled.
  static Future<String?> pick(ImageSource source, String catchId) async {
    final x = await _picker.pickImage(
      source: source,
      maxWidth: 1600, // big enough to look sharp, small enough to upload fast
      imageQuality: 80, // JPEG quality 0-100
    );
    if (x == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/photos');
    await folder.create(recursive: true);
    // The time in the name makes a replaced photo a new file (no stale cache).
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final dest = '${folder.path}/$catchId-$stamp.jpg';
    await File(x.path).copy(dest);
    return dest;
  }
}
