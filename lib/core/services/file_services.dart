import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:file_saver/file_saver.dart';
import 'package:file_selector/file_selector.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cookethflow/core/services/platform_file_service.dart';

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
          name: fileName, bytes: pngBytes, ext: 'png', mimeType: MimeType.png);
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
    return await PlatformFileService.parseJSONFile(fileData);
  }

  Future<Map<String, dynamic>?> pickAndReadJsonFile() async {
    return await PlatformFileService.pickJSONFile();
  }

  Future<XFile?> selectImages() async {
    // For Linux, you can specify the MIME types or extensions
    final fileSelector = FileSelectorPlatform.instance;
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'Images',
      mimeTypes: ['image/*'], // All image types
      // Alternatively, you can specify extensions:
      // extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
    );

    try {
      final XFile? file =
          await fileSelector.openFile(acceptedTypeGroups: [typeGroup]);

      if (file != null) {
        print('Selected file: ${file.path}');
        // You can now read the file or display the image
        // For example, with Image.file(File(file.path))
      }
      return file;
    } catch (e) {
      print('Error selecting file: $e');
      return null;
    }
  }
}
