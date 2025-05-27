import 'dart:convert';
import 'dart:typed_data';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:cookethflow/data/services/platform_file_service.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

class FileServices {
  final FileSelectorPlatform fileSelector = FileSelectorPlatform.instance;

  Future<String> exportFile({
    required String defaultName,
    required String jsonString,
  }) async {
    try {
      // Ensure the default name ends with .json
      final sanitizedName = defaultName.toLowerCase().endsWith('.json')
          ? defaultName
          : '$defaultName.json';

      if (kIsWeb) {
        // Web: Use browser download API
        final bytes = Uint8List.fromList(utf8.encode(jsonString));
        final blob = html.Blob([bytes], 'application/json');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', sanitizedName)
          ..click();
        html.Url.revokeObjectUrl(url);
        return 'success';
      } else {
        // Desktop: Use file_selector
        const XTypeGroup typeGroup = XTypeGroup(
          label: 'JSON',
          extensions: ['json'],
          mimeTypes: ['application/json'],
        );

        final String? path = await fileSelector.getSavePath(
          acceptedTypeGroups: [typeGroup],
          suggestedName: sanitizedName,
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
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> exportPNG({
    required String defaultName,
    required Uint8List pngBytes,
  }) async {
    try {
      // Ensure the default name ends with .png
      final sanitizedName = defaultName.toLowerCase().endsWith('.png')
          ? defaultName
          : '$defaultName.png';

      if (kIsWeb) {
        // Web: Use browser download API
        final blob = html.Blob([pngBytes], 'image/png');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', sanitizedName)
          ..click();
        html.Url.revokeObjectUrl(url);
        return 'success';
      } else {
        // Desktop: Use file_selector
        const XTypeGroup typeGroup = XTypeGroup(
          label: 'PNG Images',
          extensions: ['png'],
          mimeTypes: ['image/png'],
        );

        final String? path = await fileSelector.getSavePath(
          acceptedTypeGroups: [typeGroup],
          suggestedName: sanitizedName,
        );

        if (path == null) {
          return 'Save operation cancelled';
        }

        // Ensure the selected path ends with .png
        final String savePath =
            path.toLowerCase().endsWith('.png') ? path : '$path.png';

        final XFile file = XFile.fromData(
          pngBytes,
          mimeType: 'image/png',
          name: savePath.split('/').last,
        );

        await file.saveTo(savePath);
        return 'success';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> exportSVG({
    required String defaultName,
    required String svgString,
  }) async {
    try {
      // Ensure the default name ends with .svg
      final sanitizedName = defaultName.toLowerCase().endsWith('.svg')
          ? defaultName
          : '$defaultName.svg';

      if (kIsWeb) {
        // Web: Use browser download API
        final bytes = Uint8List.fromList(utf8.encode(svgString));
        final blob = html.Blob([bytes], 'image/svg+xml');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', sanitizedName)
          ..click();
        html.Url.revokeObjectUrl(url);
        return 'success';
      } else {
        // Desktop: Use file_selector
        const XTypeGroup typeGroup = XTypeGroup(
          label: 'SVG Images',
          extensions: ['svg'],
          mimeTypes: ['image/svg+xml'],
        );

        final String? path = await fileSelector.getSavePath(
          acceptedTypeGroups: [typeGroup],
          suggestedName: sanitizedName,
        );

        if (path == null) {
          return 'Save operation cancelled';
        }

        // Ensure the selected path ends with .svg
        final String savePath =
            path.toLowerCase().endsWith('.svg') ? path : '$path.svg';

        final XFile file = XFile.fromData(
          Uint8List.fromList(utf8.encode(svgString)),
          mimeType: 'image/svg+xml',
          name: savePath.split('/').last,
        );

        await file.saveTo(savePath);
        return 'success';
      }
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
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'Images',
      mimeTypes: ['image/*'],
    );

    try {
      final XFile? file =
          await fileSelector.openFile(acceptedTypeGroups: [typeGroup]);

      if (file != null) {
        print('Selected file: ${file.path}');
      }
      return file;
    } catch (e) {
      print('Error selecting file: $e');
      return null;
    }
  }

  Future<XFile?> importJsonFiles() async {
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
