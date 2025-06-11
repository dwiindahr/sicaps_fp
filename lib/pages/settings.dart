import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background is white
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black, // Title text color
            fontWeight: FontWeight.normal, // Matches the image, not bold
          ),
        ),
        backgroundColor: Colors.white, // AppBar background is white
        elevation: 0, // No shadow
        foregroundColor: Colors.black, // Back button color
      ),
      body: Column( // Use Column to structure the entire body
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0), // Padding around the entire list
              children: [
                // === Bagian Profil ===
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0), // Space below profile section
                  child: Row(
                    children: [
                      // Circular profile image placeholder
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.grey[300], // Light grey circle
                          shape: BoxShape.circle,
                        ),
                        // You might add an Image.asset here if you have a default profile pic
                        // child: Image.asset('assets/images/default_profile.png'),
                      ),
                      const SizedBox(width: 16), // Space between circle and text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Lorem Ipsum', // User's name
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'loremipsum@gmail.com', // User's email
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // === Bagian "Akun Saya" ===
                const Text(
                  'Akun Saya',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8), // Space below title
                _buildSettingsListTile(context, 'Pengaturan Akun'),
                _buildSettingsListTile(context, 'Aktivitas Saya'),
                _buildSettingsListTile(context, 'Privasi & Keamanan'),
                
                const Divider(height: 32, thickness: 1, color: Colors.grey), // Separator

                // === Bagian "Umum" ===
                const Text(
                  'Umum',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8), // Space below title
                _buildSettingsListTile(context, 'Bahasa'),
                _buildSettingsListTile(context, 'Notifikasi'),
                _buildSettingsListTile(context, 'Kualitas Media'),

                const Divider(height: 32, thickness: 1, color: Colors.grey), // Separator

                // === Bagian "Bantuan" ===
                const Text(
                  'Bantuan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8), // Space below title
                _buildSettingsListTile(context, 'Pusat Bantuan'),
                _buildSettingsListTile(context, 'Peraturan Komunitas'),
                _buildSettingsListTile(context, 'Kebijakan Privasi'),

                const Divider(height: 32, thickness: 1, color: Colors.grey), // Separator

                // === Bagian "Login" ===
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8), // Space below title
                ListTile(
                  title: const Text(
                    'Keluar',
                    style: TextStyle(color: Colors.red,fontSize: 16,), // Red text
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    // Handle 'Keluar' tap
                  },
                  contentPadding: EdgeInsets.zero, // Remove default padding
                  dense: true, // Make it a bit more compact
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build consistent ListTile for settings options
  Widget _buildSettingsListTile(BuildContext context, String title) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: () {
        // Implement navigation or action for each setting
        print('Tapped on: $title'); // For demonstration
      },
      contentPadding: EdgeInsets.zero, // Remove default horizontal padding
      dense: true, // Make the list tile a bit more compact vertically
    );
  }
}