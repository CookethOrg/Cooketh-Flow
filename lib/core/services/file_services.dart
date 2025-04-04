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
  final FileSelectorPlatform fileSelector = FileSelectorPlatform.instance;

  Future<String> exportFile({
    required String defaultName,
    required String jsonString,
  }) async {
    try {
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'JSON',
        extensions: ['json'],
        mimeTypes: ['application/json'],
      );

      // Ensure the default name ends with .json
      if (!defaultName.toLowerCase().endsWith('.json')) {
        defaultName = '$defaultName.json';
      }

      final String? path = await fileSelector.getSavePath(
        acceptedTypeGroups: [typeGroup],
        suggestedName: defaultName,
      );

      if (path == null) {
        return 'Save operation cancelled';
      }

      // Ensure the selected path ends with .json
      final String savePath =
          path.toLowerCase().endsWith('.json') ? path : '$path.json';

      final XFile file = XFile.fromData(
        Uint8List.fromList(utf8.encode(jsonString)),
        mimeType: 'application/json',
        name: savePath.split('/').last,
      );

      await file.saveTo(savePath);
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> exportPNG({
    required String defaultName,
    required Uint8List pngBytes,
  }) async {
    try {
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'PNG Images',
        extensions: ['png'],
        mimeTypes: ['image/png'],
      );

      final String? path = await fileSelector.getSavePath(
        acceptedTypeGroups: [typeGroup],
        suggestedName: defaultName,
      );

      if (path == null) {
        return 'Save operation cancelled';
      }

      final XFile file = XFile.fromData(
        pngBytes,
        mimeType: 'image/png',
        name: path.split('/').last,
        path: path,
      );

      await file.saveTo(path);
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> exportSVG({
    required String defaultName,
    required String svgString,
  }) async {
    try {
      const XTypeGroup typeGroup = XTypeGroup(
        label: 'SVG Images',
        extensions: ['svg'],
        mimeTypes: ['image/svg+xml'],
      );

      final String? path = await fileSelector.getSavePath(
        acceptedTypeGroups: [typeGroup],
        suggestedName: defaultName,
      );

      if (path == null) {
        return 'Save operation cancelled';
      }

      final XFile file = XFile.fromData(
        Uint8List.fromList(utf8.encode(svgString)),
        mimeType: 'image/svg+xml',
        name: path.split('/').last,
        path: path,
      );

      await file.saveTo(path);
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
    // final fileSelector = FileSelectorPlatform.instance;
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

  Future<XFile?> importJsonFiles() async {
    // final fileSelector = FileSelectorPlatform.instance;
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'JSON',
      mimeTypes: ['application/json'],
      extensions: ['json'],
    );

    try {
      final XFile? file =
          await fileSelector.openFile(acceptedTypeGroups: [typeGroup]);
      if (file != null) {
        print('Selected file: ${file.path}');
      }
      return file;
    } catch (e) {
      print('Error in selecting file: $e');
      return null;
    }
  }
}
