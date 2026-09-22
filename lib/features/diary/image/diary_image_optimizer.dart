import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Compresses and resizes journal photos before upload.
class DiaryImageOptimizer {
  DiaryImageOptimizer._();

  static const int maxSide = 1280;
  static const int jpegQuality = 75;
  static const int maxBytes = 900 * 1024;

  /// Returns an optimized JPEG file in the temp directory.
  static Future<File> optimize(File source) async {
    final bytes = await source.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw StateError('Could not decode image.');
    }

    img.Image processed = decoded;
    final longest = processed.width > processed.height
        ? processed.width
        : processed.height;
    if (longest > maxSide) {
      if (processed.width >= processed.height) {
        processed = img.copyResize(
          processed,
          width: maxSide,
          interpolation: img.Interpolation.average,
        );
      } else {
        processed = img.copyResize(
          processed,
          height: maxSide,
          interpolation: img.Interpolation.average,
        );
      }
    }

    var quality = jpegQuality;
    Uint8List encoded = Uint8List.fromList(
      img.encodeJpg(processed, quality: quality),
    );

    while (encoded.lengthInBytes > maxBytes && quality > 45) {
      quality -= 10;
      encoded = Uint8List.fromList(
        img.encodeJpg(processed, quality: quality),
      );
    }

    final dir = await getTemporaryDirectory();
    final name =
        'diary_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final out = File(p.join(dir.path, name));
    await out.writeAsBytes(encoded, flush: true);
    return out;
  }
}
