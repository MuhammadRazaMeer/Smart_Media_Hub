import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

class FileService {
  Future<void> saveFile(Uint8List bytes, String fileName) async {
    if (kIsWeb) {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // For Android, we can save to gallery or documents
      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        quality: 100,
        name: fileName.split('.').first,
      );
      if (result['isSuccess'] != true) {
        throw Exception("Failed to save to gallery");
      }
    }
  }

  String generateFileName(String prefix, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return "${prefix}_$timestamp.$extension";
  }
}
