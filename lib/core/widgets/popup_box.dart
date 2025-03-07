import 'package:cookethflow/providers/authentication_provider.dart';
import 'package:cookethflow/screens/log_in.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            // Username Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image:
                          NetworkImage("https://your-profile-image-link.com"),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(
                      color: Colors.grey.shade300,
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
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(Icons.edit, size: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),

            const SizedBox(height: 24),

            // Username
            const Text(
              "Username",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  "John Doe",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                Icon(Icons.edit, size: 16, color: Colors.blue.shade400),
              ],
            ),

            const SizedBox(height: 24),

            // Email Address
            const Text(
              "Email Address",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  "iamjohndoe@gmail.com",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                Icon(Icons.edit, size: 16, color: Colors.blue.shade400),
              ],
            ),

            const SizedBox(height: 24),

            // Password
            const Text(
              "Password",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                "Change Password",
                style: TextStyle(fontSize: 18, color: Colors.blue.shade400),
              ),
            ),

            const SizedBox(height: 24),

            // Devices Section
            const Text(
              "Your Devices",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _deviceTile(context, "Windows 11", Icons.laptop, "This Device",
                showTime: false),
            _deviceTile(context, "Android", Icons.phone_android, "2 months ago",
                showRevokeButton: true),

            const SizedBox(height: 24),

            // Actions Section
            const Text(
              "Actions",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Delete Account Button
            // SizedBox(
            //   height: 44,
            //   width: 180,
            //   child: ElevatedButton(
            //     onPressed: () async {
            //       final confirmed = await showDialog<bool>(
            //         context: context,
            //         builder: (context) => AlertDialog(
            //           title: Text('Delete Account'),
            //           content: Text(
            //             'Are you sure you want to delete your account? This action cannot be undone.',
            //             style: TextStyle(fontFamily: 'Frederik'),
            //           ),
            //           actions: [
            //             TextButton(
            //               onPressed: () => Navigator.pop(context, false),
            //               child: Text('Cancel'),
            //             ),
            //             TextButton(
            //               onPressed: () => Navigator.pop(context, true),
            //               child: Text('Delete',
            //                   style: TextStyle(color: Colors.red)),
            //             ),
            //           ],
            //         ),
            //       );

            //       if (confirmed == true) {
            //         try {
            //           // Show loading indicator
            //           showDialog(
            //             context: context,
            //             barrierDismissible: false,
            //             builder: (context) =>
            //                 Center(child: CircularProgressIndicator()),
            //           );

            //           // Delete account
            //           final authProvider = Provider.of<AuthenticationProvider>(
            //               context,
            //               listen: false);
            //           await authProvider.deleteUserAccount();

            //           // Close the loading dialog and the profile dialog
            //           Navigator.of(context, rootNavigator: true)
            //               .pop(); // Close loading
            //           Navigator.of(context, rootNavigator: true)
            //               .pop(); // Close profile dialog

            //           // Navigate to login page
            //           Navigator.of(context, rootNavigator: true)
            //               .pushAndRemoveUntil(
            //             MaterialPageRoute(builder: (context) => LoginPage()),
            //             (route) => false,
            //           );
            //         } catch (e) {
            //           // Close loading dialog
            //           Navigator.of(context, rootNavigator: true).pop();

            //           // Show error
            //           ScaffoldMessenger.of(context).showSnackBar(
            //             SnackBar(
            //               content:
            //                   Text('Error deleting account: ${e.toString()}'),
            //               backgroundColor: Colors.red,
            //             ),
            //           );
            //         }
            //       }
            //     },
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.red,
            //       shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(8)),
            //     ),
            //     child: const Text("Delete Account",
            //         style: TextStyle(
            //             color: Colors.white,
            //             fontSize: 16,
            //             fontWeight: FontWeight.w500)),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _deviceTile(
      BuildContext context, String name, IconData icon, String timeOrLabel,
      {bool showTime = true, bool showRevokeButton = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 12),
          Text(name,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(timeOrLabel,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400)),
          if (showRevokeButton) ...[
            const SizedBox(width: 16),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text("Revoke Access",
                  style: TextStyle(
                      color: Colors.blue.shade400,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ],
      ),
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
