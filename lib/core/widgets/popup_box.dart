import 'package:flutter/material.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage("https://your-profile-image-link.com"),
                ),
                const SizedBox(width: 10),
                
                // Username & Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text("John Doe", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 5),
                          Icon(Icons.edit, size: 16, color: Colors.blue),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text("iamjohndoe@gmail.com", style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                          const SizedBox(width: 5),
                          Icon(Icons.edit, size: 14, color: Colors.blue),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Close Button
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 10),
            
            // Change Password
            TextButton(
              onPressed: () {},
              child: const Text("Change Password", style: TextStyle(color: Colors.blue)),
            ),
            
            const Divider(),
            
            // Devices Section
            const Text("Your Devices", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Column(
              children: [
                _deviceTile("Windows 11", Icons.computer, "2 months ago"),
                _deviceTile("Android", Icons.phone_android, ""),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Delete Account Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Delete Account", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deviceTile(String name, IconData icon, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 5),
          Text(name, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          if (time.isNotEmpty)
            Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          TextButton(
            onPressed: () {},
            child: const Text("Revoke Access", style: TextStyle(color: Colors.blue, fontSize: 12)),
          ),
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
