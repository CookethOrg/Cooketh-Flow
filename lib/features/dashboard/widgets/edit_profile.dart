import 'dart:io';

import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/theme/colors.dart'; // Ensure this is correctly imported
import 'package:cookethflow/features/dashboard/providers/dashboard_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cookethflow/features/dashboard/widgets/delete_account.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;

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
        await supabaseService.uploadUserProfilePicture(
          _selectedImage!,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile picture updated!')));
        setState(() {
          _selectedImage = null; // Clear selected image after upload
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
    
    // Refresh user data from Supabase to ensure UI is in sync
    await supabaseService.supabase.auth.refreshSession();
  }

  @override
  Widget build(BuildContext context) {
    rh.DeviceType deviceType = rh.ResponsiveLayoutHelper.getDeviceType(context);
    bool is_desk = deviceType == rh.DeviceType.desktop ? true : false;

    return Consumer2<DashboardProvider, SupabaseService>(
      builder: (context, dashboardProvider, supabaseService, child) {
        final currentUser = supabaseService.currentUser;
        
        // Update controllers with the current state of the provider
        _nameController.text = currentUser?.name ?? '';
        _emailController.text = currentUser?.email ?? '';
        _usernameController.text = currentUser?.username ?? '';
        
        final String displayAvatarUrl =
            _selectedImage != null
                ? _selectedImage!.path
                : currentUser?.avatarUrl ?? '';

        return Dialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: deviceType == rh.DeviceType.desktop ? 500 : 1.6.sw,
            padding:
                deviceType == rh.DeviceType.desktop
                    ? const EdgeInsets.all(24)
                    : const EdgeInsets.only(top: 16, left: 10, right: 10),
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
                deviceType == rh.DeviceType.desktop
                    ? const SizedBox(height: 16)
                    : const SizedBox(height: 8),

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
                                    ? (_selectedImage != null
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
                            onTap: _pickImage,
                            child: Container(
                              width:
                                  28,
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
                    deviceType == rh.DeviceType.desktop
                        ? const SizedBox(width: 16)
                        : const SizedBox(width: 8),
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
                        deviceType == rh.DeviceType.desktop
                            ? const SizedBox(height: 4)
                            : const SizedBox(height: 2),
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

                deviceType == rh.DeviceType.desktop
                    ? const SizedBox(height: 32)
                    : const SizedBox(height: 16),

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

                deviceType == rh.DeviceType.desktop
                    ? const SizedBox(height: 20)
                    : const SizedBox(height: 10),

                // Username field
                _buildField(
                  context,
                  label: 'Username',
                  controller: _usernameController,
                  width: 250,
                ),

                deviceType == rh.DeviceType.desktop
                    ? const SizedBox(height: 32)
                    : const SizedBox(height: 16),

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
                        deviceType == rh.DeviceType.desktop
                            ? const SizedBox(height: 4)
                            : const SizedBox(height: 2),
                        Text(
                          'Toggle between light and dark mode',
                          style: TextStyle(
                            fontSize:deviceType == rh.DeviceType.desktop? 14 : 10,
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
                          size:deviceType == rh.DeviceType.desktop?20 : 10,
                        ),
                        deviceType == rh.DeviceType.desktop
                            ? const SizedBox(height: 8)
                            : const SizedBox(height: 4),
                        Switch(
                          value: supabaseService.isDark,
                          onChanged: (value) => supabaseService.toggleTheme(),
                          activeColor: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),

                deviceType == rh.DeviceType.desktop
                    ? const SizedBox(height: 32)
                    : const SizedBox(height: 16),

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

                deviceType == rh.DeviceType.desktop
                    ? const SizedBox(height: 32)
                    : const SizedBox(height: 16),
                Divider(color: Theme.of(context).dividerColor),
                deviceType == rh.DeviceType.desktop
                    ? const SizedBox(height: 24)
                    : const SizedBox(height: 12),

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
                        deviceType == rh.DeviceType.desktop
                            ? const SizedBox(height: 4)
                            : const SizedBox(height: 4),
                        Text(
                          'Permanently delete your account',
                          style: TextStyle(
                            fontSize:deviceType == rh.DeviceType.desktop? 14 : 10,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: is_desk,
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const DeleteAccountDialog(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryColors[1],
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                deviceType == rh.DeviceType.desktop ? 20 : 10,
                            vertical:
                                deviceType == rh.DeviceType.desktop ? 10 : 5,
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
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Visibility(
                  visible: !is_desk,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const DeleteAccountDialog(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryColors[1],
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              deviceType == rh.DeviceType.desktop ? 20 : 10,
                          vertical:
                              deviceType == rh.DeviceType.desktop ? 10 : 5,
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
                  ),
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