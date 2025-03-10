import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';

class PlatformFileService {
  static Future<Map<String, dynamic>?> pickJSONFile() async {
    try {
      if (kIsWeb) {
        // For web platform, we'll use a custom approach
        // This requires the 'universal_html' package
        return _pickFileWeb();
      } else {
        // For non-web platforms
        return _pickFileNative();
      }
    } catch (e) {
      print("Error picking file: $e");
      return null;
    }
  }
  
  static Future<Map<String, dynamic>?> _pickFileNative() async {
    try {
      // Use flutter_document_picker which has better platform compatibility
      final path = await FlutterDocumentPicker.openDocument(
        params: FlutterDocumentPickerParams(
          allowedFileExtensions: ['json'],
          invalidFileNameSymbols: ['/']
        ),
      );
      
      if (path == null) return null;
      
      // Get file name from path
      final fileName = path.split('/').last;
      
      // Read file content
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
    // Implementation for web platforms would go here
    // For simplicity, we'll just return a placeholder message
    // A real implementation would use HTML FileReader API
    throw Exception("Web file picking not implemented in this version. Please use a desktop app for file import.");
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