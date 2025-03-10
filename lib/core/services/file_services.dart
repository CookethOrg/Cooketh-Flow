import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';

class FileServices {
  FileSaver fs = FileSaver();

  Future<String> exportFile(
      {required String fileName, required String jsonString}) async {
    try {
      await fs.saveFile(
          name: fileName,
          bytes: Uint8List.fromList(utf8.encode(jsonString)),
          ext: 'json',
          mimeType: MimeType.json);
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }
}
