import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:universal_html/html.dart' as html;

class PlatformFileService {
  static Future<Map<String, dynamic>?> pickJSONFile() async {
    try {
      if (kIsWeb) {
        return await _pickFileWeb();
      } else {
        return await _pickFileNative();
      }
    } catch (e) {
      print("Error picking file: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> _pickFileNative() async {
    try {
      final path = await FlutterDocumentPicker.openDocument(
        params: FlutterDocumentPickerParams(
          allowedFileExtensions: ['json'],
          invalidFileNameSymbols: ['/'],
        ),
      );

      if (path == null) return null;

      final fileName = path.split('/').last;
      final File file = File(path);
      final bytes = await file.readAsBytes();

      return {
        'name': fileName,
        'bytes': bytes,
      };
    } catch (e) {
      print("Native file picking error: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> _pickFileWeb() async {
    try {
      final input = html.FileUploadInputElement()..accept = '.json';
      input.click();

      await input.onChange.first;
      final files = input.files;
      if (files == null || files.isEmpty) return null;

      final file = files[0];
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      await reader.onLoad.first;
      final bytes = Uint8List.fromList(reader.result as List<int>);
      final fileName = file.name;

      return {
        'name': fileName,
        'bytes': bytes,
      };
    } catch (e) {
      print("Web file picking error: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> parseJSONFile(Uint8List bytes) async {
    try {
      final String content = utf8.decode(bytes);
      final Map<String, dynamic> jsonData = jsonDecode(content);
      return jsonData;
    } catch (e) {
      print("Error parsing JSON: $e");
      return null;
    }
  }
}