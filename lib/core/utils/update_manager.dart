import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;

class UpdateManager {
  final SupabaseClient supabase = Supabase.instance.client;

  // Fetch latest version from Supabase
  Future<Map<String, dynamic>?> getLatestVersion() async {
    try {
      final response = await supabase
          .from('app_versions')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .single();
      return response;
    } catch (e) {
      print('Error fetching version: $e');
      return null;
    }
  }

  // Check if an update is available
  Future<bool> isUpdateAvailable() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version; // e.g., "1.0.0"
    Map<String, dynamic>? latestInfo = await getLatestVersion();
    if (latestInfo == null) return false;
    String latestVersion = latestInfo['version']; // e.g., "1.1.0"
    return _compareVersions(currentVersion, latestVersion) < 0;
  }

  // Compare version strings (e.g., "1.0.0" vs "1.1.0")
  int _compareVersions(String current, String latest) {
    List<String> currentParts = current.split('.');
    List<String> latestParts = latest.split('.');
    for (int i = 0; i < 3; i++) {
      int currentNum = int.parse(currentParts[i]);
      int latestNum = int.parse(latestParts[i]);
      if (latestNum > currentNum) return -1;
      if (latestNum < currentNum) return 1;
    }
    return 0;
  }

  // Get platform-specific download URL
  String? getDownloadUrl(Map<String, dynamic> latestInfo) {
    if (Platform.isWindows) return latestInfo['windows_url'];
    if (Platform.isLinux) return latestInfo['linux_url'];
    return null;
  }

  // Download the update file
  Future<String?> downloadUpdate(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        String fileName = url.split('/').last;
        String dir = Directory.current.path;
        File file = File('$dir/updates/$fileName');
        await file.create(recursive: true);
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      } else {
        print('Download failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error downloading update: $e');
      return null;
    }
  }

  // Apply the update
    // Apply the update
  Future<void> applyUpdate(String downloadedPath) async {
    try {
      if (Platform.isWindows) {
        String currentPath = Platform.resolvedExecutable;
        String script = '''
        @echo off
        timeout /t 2
        move /y "$downloadedPath" "$currentPath"
        start "" "$currentPath"
        ''';
        File batchFile = File('${Directory.current.path}/update.bat');
        await batchFile.writeAsString(script);
        await Process.start('cmd.exe', ['/c', batchFile.path], runInShell: true);
        exit(0);
      } else if (Platform.isLinux) {
        String currentDir = Directory.current.path;
        // Extract the tarball to the current directory, overwriting existing files
        await Process.run('tar', ['-xzf', downloadedPath, '-C', currentDir]);
        String newBinaryPath = '$currentDir/cookethflow';
        if (await File(newBinaryPath).exists()) {
          await Process.run('chmod', ['+x', newBinaryPath]); // Ensure executable
          await Process.start(newBinaryPath, [], workingDirectory: currentDir);
          exit(0);
        } else {
          print('Update binary not found in tarball');
        }
      }
    } catch (e) {
      print('Error applying update: $e');
    }
  }

  // Show update prompt
  Future<void> checkAndPromptForUpdate(BuildContext context) async {
    if (await isUpdateAvailable()) {
      Map<String, dynamic>? latestInfo = await getLatestVersion();
      if (latestInfo != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Update Available'),
            content: Text(
                'Version ${latestInfo['version']} is available.\n\nRelease notes: ${latestInfo['release_notes']}'),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  String? url = getDownloadUrl(latestInfo);
                  if (url != null) {
                    String? path = await downloadUpdate(url);
                    if (path != null) {
                      await applyUpdate(path);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to download update')),
                      );
                    }
                  }
                },
                child: const Text('Update Now'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Later'),
              ),
            ],
          ),
        );
      }
    }
  }
}