import 'dart:io';

import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/theme/colors.dart'; // Ensure this is correctly imported
import 'package:cookethflow/features/dashboard/providers/dashboard_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cookethflow/features/dashboard/widgets/delete_account.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSettingsWidget extends StatefulWidget {
  const ProfileSettingsWidget({super.key});

  @override
  State<ProfileSettingsWidget> createState() => _ProfileSettingsWidgetState();
}

class _ProfileSettingsWidgetState extends State<ProfileSettingsWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  XFile? _selectedImage; // To hold the newly selected image for upload

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize controllers with current user data when dependencies change
    final supabaseService = Provider.of<SupabaseService>(
      context,
      listen: false,
    );
    if (supabaseService.currentUser != null) {
      _nameController.text = supabaseService.currentUser!.name ?? '';
      _emailController.text = supabaseService.currentUser!.email;
      _usernameController.text = supabaseService.currentUser!.username ?? '';
      // No need to fetch image here, CachedNetworkImage handles it
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _saveChanges() async {
    final supabaseService = Provider.of<SupabaseService>(
      context,
      listen: false,
    );
    final String currentUserId =
        supabaseService.currentUser!.id; // Ensure user is logged in

    // Update Name and Username
    if (_nameController.text != supabaseService.currentUser!.name ||
        _usernameController.text != supabaseService.currentUser!.username) {
      try {
        final res = await supabaseService.updateUserName(
          newName: _nameController.text,
          newUsername: _usernameController.text,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(res)));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    // Update Email
    if (_emailController.text != supabaseService.currentUser!.email) {
      try {
        final res = await supabaseService.updateUserEmail(
          email: _emailController.text,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(res)));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    // Upload Profile Picture if a new one was selected
    if (_selectedImage != null) {
      try {
        final res = await supabaseService.uploadUserProfilePicture(
          _selectedImage!,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Profile picture updated!')));
        setState(() {
          _selectedImage = null; // Clear selected image after upload
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    // Optionally, refresh user data to ensure everything is in sync
    await supabaseService.supabase.auth.refreshSession();

    // Close the dialog after saving
    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DashboardProvider, SupabaseService>(
      builder: (context, dashboardProvider, supabaseService, child) {
        final currentUser = supabaseService.currentUser;
        final String displayAvatarUrl =
            _selectedImage != null
                ? _selectedImage!
                    .path // Show locally selected image immediately
                : currentUser?.avatarUrl ?? ''; // Fallback to network or empty

        return Dialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(height: 16),

                // Profile section
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child:
                                displayAvatarUrl.isNotEmpty
                                    ? (_selectedImage !=
                                            null // If a new image is selected, display it from path/memory
                                        ? (kIsWeb
                                            ? Image.network(
                                              displayAvatarUrl,
                                              fit: BoxFit.cover,
                                            )
                                            : Image.file(
                                              File(displayAvatarUrl),
                                              fit: BoxFit.cover,
                                            ))
                                        : CachedNetworkImage(
                                          // Otherwise, display from network cache
                                          imageUrl: displayAvatarUrl,
                                          fit: BoxFit.cover,
                                          placeholder:
                                              (context, url) =>
                                                  const CircularProgressIndicator(),
                                          errorWidget:
                                              (context, url, error) =>
                                                  Image.asset(
                                                    supabaseService
                                                        .defaultPfpPath,
                                                    fit: BoxFit.cover,
                                                  ),
                                        ))
                                    : Image.asset(
                                      supabaseService.defaultPfpPath,
                                      fit: BoxFit.cover,
                                    ), // Default fallback
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _pickImage, // Call image picker
                            child: Container(
                              width:
                                  28, // Slightly larger for better tap target
                              height: 28,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).cardColor,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.edit,
                                size: 14,
                                color: Theme.of(context).cardColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser?.name ?? 'Loading Name...',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentUser?.username ?? 'Loading Username...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Form fields
                Row(
                  children: [
                    _buildField(
                      context,
                      label: 'Name',
                      controller: _nameController,
                    ),
                    const SizedBox(width: 16),
                    _buildField(
                      context,
                      label: 'Email',
                      controller: _emailController,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Username field
                _buildField(
                  context,
                  label: 'Username',
                  controller: _usernameController,
                  width: 250,
                ),

                const SizedBox(height: 32),

                // Theme toggle section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Theme',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Toggle between light and dark mode',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          supabaseService.isDark
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: Theme.of(context).iconTheme.color,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Switch(
                          value: supabaseService.isDark,
                          onChanged: (value) => supabaseService.toggleTheme(),
                          activeColor: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.titleLarge?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _saveChanges, // Call the save changes function
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Save all changes',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                Divider(color: Theme.of(context).dividerColor),
                const SizedBox(height: 24),

                // Delete account
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delete Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Permanently delete your account',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const DeleteAccountDialog(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryColors[1],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Delete Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    double? width,
  }) {
    return Expanded(
      flex: width != null ? 0 : 1,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller, // Use the provided controller
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
