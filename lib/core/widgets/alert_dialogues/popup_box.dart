import 'dart:io';

import 'package:cookethflow/core/services/file_services.dart';
import 'package:cookethflow/core/services/supabase_service.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ProfileDialog extends StatefulWidget {
  const ProfileDialog({super.key});

  @override
  State<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final auth = Provider.of<SupabaseService>(context, listen: false);
    if (auth.userName == null || auth.email == null) {
      await auth.fetchCurrentUserDetails();
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SupabaseService>(
      builder: (context, pv, child) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: const BorderSide(
              color: Colors.black,
              width: 2.0,
              style: BorderStyle.solid,
            ),
          ),
          child: SizedBox(
            width: 800,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(
                          PhosphorIconsRegular.xCircle,
                          size: 40,
                          color: Colors.black,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: pv.userPfp != null
                                  ? FileImage(File(pv.userPfp!.path))
                                  : const AssetImage('assets/Frame 268.png')
                                      as ImageProvider),
                          border: Border.all(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            width: 1.0,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color:
                                          const Color.fromARGB(255, 0, 0, 0)),
                                ),
                                padding: const EdgeInsets.all(2),
                                child: IconButton(
                                  style: IconButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      hoverColor: Colors.transparent),
                                  onPressed: () async {
                                    try {
                                      XFile? file =
                                          await FileServices().selectImages();
                                      if (file != null) {
                                        await pv.uploadUserProfilePicture(file);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Profile picture updated')));
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                              SnackBar(content: Text('$e')));
                                    }
                                  },
                                  icon: const Icon(Icons.edit, size: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "User Name",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        pv.userName ?? "John Doe",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          showEditDialog(
                              context, 'User Name', pv.userName ?? "John Doe",
                              (newValue) async {
                            return await pv.updateUserName(userName: newValue);
                          });
                        },
                        icon: Icon(Icons.edit,
                            size: 16, color: Colors.blue.shade400),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Email Address",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        pv.email ?? "john.doe@example.com",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'Email update requires verification. Coming soon!')));
                        },
                        icon: Icon(Icons.edit,
                            size: 16, color: Colors.blue.shade400),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Password",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      showPasswordChangeDialog(context);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "Change Password",
                      style:
                          TextStyle(fontSize: 18, color: Colors.blue.shade400),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

void showProfileDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const ProfileDialog();
    },
  );
}

void showEditDialog(BuildContext context, String attribute, String currentValue,
    Future<String> Function(String) onUpdate) {
  final TextEditingController controller =
      TextEditingController(text: currentValue);
  bool isProcessing = false;
  String? errorMessage;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text('Update $attribute'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Enter new $attribute',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(width: 1, color: Colors.black),
                  ),
                  errorText: errorMessage,
                ),
                enabled: !isProcessing,
              ),
              if (isProcessing)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isProcessing ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: isProcessing
                  ? null
                  : () async {
                      final newValue = controller.text.trim();
                      if (newValue.isEmpty) {
                        setState(() {
                          errorMessage = 'Value cannot be empty';
                        });
                        return;
                      }
                      if (newValue == currentValue) {
                        Navigator.pop(context);
                        return;
                      }
                      setState(() {
                        isProcessing = true;
                        errorMessage = null;
                      });
                      try {
                        await onUpdate(newValue);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('$attribute updated successfully')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          setState(() {
                            isProcessing = false;
                            errorMessage = 'Error: ${e.toString()}';
                          });
                        }
                      }
                    },
              child: const Text('Update'),
            ),
          ],
        );
      });
    },
  );
}

void showPasswordChangeDialog(BuildContext context) {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isProcessing = false;
  String? errorMessage;
  bool obscureCurrentPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Change Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrentPassword,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrentPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureCurrentPassword = !obscureCurrentPassword;
                        });
                      },
                    ),
                  ),
                  enabled: !isProcessing,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNewPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureNewPassword = !obscureNewPassword;
                        });
                      },
                    ),
                  ),
                  enabled: !isProcessing,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorText: errorMessage,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  enabled: !isProcessing,
                ),
                if (isProcessing)
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isProcessing ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: isProcessing
                    ? null
                    : () async {
                        final currentPassword = currentPasswordController.text;
                        final newPassword = newPasswordController.text;
                        final confirmPassword = confirmPasswordController.text;

                        if (currentPassword.isEmpty ||
                            newPassword.isEmpty ||
                            confirmPassword.isEmpty) {
                          setState(() {
                            errorMessage = 'All fields are required';
                          });
                          return;
                        }
                        if (newPassword != confirmPassword) {
                          setState(() {
                            errorMessage = 'New passwords do not match';
                          });
                          return;
                        }
                        if (newPassword.length < 6) {
                          setState(() {
                            errorMessage =
                                'Password must be at least 6 characters';
                          });
                          return;
                        }
                        setState(() {
                          isProcessing = true;
                          errorMessage = null;
                        });
                        try {
                          final pv = Provider.of<SupabaseService>(context,
                              listen: false);
                          await pv.updateUserPassword(
                            currentPassword: currentPassword,
                            newPassword: newPassword,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Password updated successfully')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            setState(() {
                              isProcessing = false;
                              errorMessage = 'Error: ${e.toString()}';
                            });
                          }
                        }
                      },
                child: const Text('Update Password'),
              ),
            ],
          );
        },
      );
    },
  );
}
