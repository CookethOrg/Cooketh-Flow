import 'dart:convert';
import 'dart:typed_data';
// import 'dart:ui' as ui;

import 'package:file_saver/file_saver.dart';
// import 'package:flutter/rendering.dart';

class FileServices {
  FileSaver fs = FileSaver();

  Future<String> exportFile({
    required String fileName, 
    required String jsonString,
  }) async {
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

  Future<String> exportPNG({
    required String fileName,
    required Uint8List pngBytes,
  }) async {
    try {
      await fs.saveFile(
          name: fileName,
          bytes: pngBytes,
          ext: 'png',
          mimeType: MimeType.png);
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> exportSVG({
    required String fileName,
    required String svgString,
  }) async {
    try {
      await fs.saveFile(
          name: fileName,
          bytes: Uint8List.fromList(utf8.encode(svgString)),
          ext: 'svg',
          mimeType: MimeType.other);
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  // For importing files
  Future<Map<String, dynamic>?> importJsonFile(Uint8List fileData) async {
    try {
      final String jsonString = utf8.decode(fileData);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return jsonData;
    } catch (e) {
      print("Error importing JSON file: $e");
      return null;
    }
  }
}