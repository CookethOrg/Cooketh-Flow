import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class UpdateManager {
  final SupabaseClient supabase = Supabase.instance.client;
  bool _isCheckingForUpdate = false;

  // Fetch latest version from Supabase
  Future<Map<String, dynamic>?> getLatestVersion() async {
    try {
      final response = await supabase
          .from('app_versions')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .single();
      print('Latest version fetched: ${response['version']}');
      return response;
    } catch (e) {
      print('Error fetching version: $e');
      return null;
    }
  }

  // Check if an update is available
  Future<bool> isUpdateAvailable() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version; // e.g., "1.0.0"
      Map<String, dynamic>? latestInfo = await getLatestVersion();
      
      if (latestInfo == null) return false;
      
      String latestVersion = latestInfo['version']; // e.g., "1.1.0"
      print('Current version: $currentVersion, Latest version: $latestVersion');
      
      return _compareVersions(currentVersion, latestVersion) < 0;
    } catch (e) {
      print('Error checking for update: $e');
      return false;
    }
  }

  // Compare version strings (e.g., "1.0.0" vs "1.1.0")
  int _compareVersions(String current, String latest) {
    List<String> currentParts = current.split('.');
    List<String> latestParts = latest.split('.');
    
    // Ensure both lists have at least 3 elements
    while (currentParts.length < 3) currentParts.add('0');
    while (latestParts.length < 3) latestParts.add('0');
    
    for (int i = 0; i < 3; i++) {
      int currentNum = int.tryParse(currentParts[i]) ?? 0;
      int latestNum = int.tryParse(latestParts[i]) ?? 0;
      
      if (latestNum > currentNum) return -1;
      if (latestNum < currentNum) return 1;
    }
    return 0;
  }

  // Get platform-specific download URL
  String? getDownloadUrl(Map<String, dynamic> latestInfo) {
    if (Platform.isWindows) return latestInfo['windows_url'];
    if (Platform.isLinux) return latestInfo['linux_url'];
    if (Platform.isMacOS) return latestInfo['macos_url'];
    return null;
  }

  // Download the update file
  Future<String?> downloadUpdate(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Get app's temporary directory for storing the update
        final tempDir = await getTemporaryDirectory();
        String fileName = url.split('/').last;
        File file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        print('Update downloaded to: ${file.path}');
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
  Future<void> applyUpdate(String downloadedPath) async {
    try {
      if (Platform.isWindows) {
        String currentPath = Platform.resolvedExecutable;
        // Create batch file for Windows update
        final tempDir = await getTemporaryDirectory();
        File batchFile = File('${tempDir.path}/update.bat');
        
        String script = '''
        @echo off
        echo Updating Cooketh Flow...
        timeout /t 2
        copy /y "$downloadedPath" "$currentPath"
        echo Update complete! Restarting application...
        start "" "$currentPath"
        exit
        ''';
        
        await batchFile.writeAsString(script);
        await Process.start('cmd.exe', ['/c', batchFile.path], runInShell: true);
        exit(0);
      } else if (Platform.isLinux) {
        final appDir = await getApplicationDocumentsDirectory();
        final updateDir = Directory('${appDir.path}/update');
        if (!await updateDir.exists()) {
          await updateDir.create(recursive: true);
        }
        
        // Extract the tarball
        await Process.run('tar', ['-xzf', downloadedPath, '-C', updateDir.path]);
        
        // Make the new binary executable
        String newBinaryPath = '${updateDir.path}/cookethflow';
        if (await File(newBinaryPath).exists()) {
          await Process.run('chmod', ['+x', newBinaryPath]);
          
          // Create a shell script to replace the current binary and restart
          File scriptFile = File('${updateDir.path}/apply_update.sh');
          
          String script = '''
          #!/bin/bash
          cp "$newBinaryPath" "${Platform.resolvedExecutable}"
          exec "${Platform.resolvedExecutable}"
          ''';
          
          await scriptFile.writeAsString(script);
          await Process.run('chmod', ['+x', scriptFile.path]);
          await Process.start(scriptFile.path, [], mode: ProcessStartMode.detached);
          exit(0);
        } else {
          throw Exception('Update binary not found in tarball');
        }
      } else if (Platform.isMacOS) {
        // macOS update logic
        final appDir = await getApplicationDocumentsDirectory();
        final updateDir = Directory('${appDir.path}/update');
        if (!await updateDir.exists()) {
          await updateDir.create(recursive: true);
        }
        
        // For macOS, assuming it's a DMG file
        await Process.run('open', [downloadedPath]);
        // Show instructions to the user for manual update
        // (automatic update on macOS often requires elevated privileges)
      }
    } catch (e) {
      print('Error applying update: $e');
      throw e;
    }
  }

  // Show update prompt
  Future<void> checkAndPromptForUpdate(BuildContext context) async {
    if (_isCheckingForUpdate) return;
    
    _isCheckingForUpdate = true;
    
    try {
      bool updateAvailable = await isUpdateAvailable();
      
      if (!updateAvailable) {
        print('No updates available');
        _isCheckingForUpdate = false;
        return;
      }
      
      Map<String, dynamic>? latestInfo = await getLatestVersion();
      if (latestInfo == null) {
        _isCheckingForUpdate = false;
        return;
      }
      
      if (!context.mounted) {
        _isCheckingForUpdate = false;
        return;
      }
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Update Available'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version ${latestInfo['version']} is available.'),
              const SizedBox(height: 16),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Fetching current version...');
                  } else if (snapshot.hasError) {
                    return const Text('Error fetching version');
                  } else {
                    return Text('Current version: ${snapshot.data?.version ?? 'Unknown'}');
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text('Release notes:'),
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(latestInfo['release_notes'] ?? 'No release notes available'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _isCheckingForUpdate = false;
              },
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                
                // Show loading dialog
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const AlertDialog(
                    title: Text('Downloading Update'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LinearProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Please wait while the update is being downloaded...'),
                      ],
                    ),
                  ),
                );
                
                String? url = getDownloadUrl(latestInfo);
                if (url != null) {
                  try {
                    String? path = await downloadUpdate(url);
                    
                    if (!context.mounted) {
                      _isCheckingForUpdate = false;
                      return;
                    }
                    
                    // Close the loading dialog
                    Navigator.pop(context);
                    
                    if (path != null) {
                      // Show confirmation before applying update
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Ready to Update'),
                          content: const Text(
                            'The update has been downloaded and is ready to install. '
                            'The application will restart during this process.'
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _isCheckingForUpdate = false;
                              },
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                try {
                                  await applyUpdate(path);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed to apply update: $e')),
                                    );
                                  }
                                  _isCheckingForUpdate = false;
                                }
                              },
                              child: const Text('Install & Restart'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to download update')),
                        );
                      }
                      _isCheckingForUpdate = false;
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.pop(context); // Close loading dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error during update: $e')),
                      );
                    }
                    _isCheckingForUpdate = false;
                  }
                } else {
                  if (context.mounted) {
                    Navigator.pop(context); // Close loading dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No download available for your platform')),
                    );
                  }
                  _isCheckingForUpdate = false;
                }
              },
              child: const Text('Update Now'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error in update process: $e');
      _isCheckingForUpdate = false;
    }
  }
}