import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:project_caps/pages/login.dart'; // Ganti dengan path ke halaman login Anda

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  // Ubah menjadi StatefulWidget
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Anda bisa menambahkan variabel untuk data profil dinamis di sini jika diperlukan
  // String _userName = 'Loading...';
  // String _userEmail = 'Loading...';

  @override
  void initState() {
    super.initState();
    // Jika Anda ingin menampilkan nama/email pengguna yang login:
    // _loadUserProfile();
  }

  // Fungsi untuk melakukan logout
  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      // Setelah logout berhasil, arahkan ke halaman login dan hapus semua rute sebelumnya
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) =>
                const LoginScreen()), // Pastikan LoginPage ada dan path-nya benar
        (route) => false, // Hapus semua rute dari stack navigasi
      );
    } catch (e) {
      // Tampilkan Snackbar jika ada error saat logout
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: ${e.toString()}')),
      );
      print('Error signing out: ${e.toString()}');
    }
  }

  // Opsional: Fungsi untuk memuat data profil pengguna yang login
  // Jika Anda ingin nama dan email di bagian profil dinamis
  // Future<void> _loadUserProfile() async {
  //   final user = Supabase.instance.client.auth.currentUser;
  //   if (user != null) {
  //     // Jika profil disimpan di tabel 'profiles' dan id-nya sama dengan user.id
  //     final response = await Supabase.instance.client
  //         .from('profiles')
  //         .select('name, email')
  //         .eq('id', user.id)
  //         .single();
  //     if (mounted) {
  //       setState(() {
  //         _userName = response['name'] as String? ?? 'Nama Pengguna';
  //         _userEmail = response['email'] as String? ?? user.email ?? 'Tidak ada email';
  //       });
  //     }
  //   } else {
  //     if (mounted) {
  //       setState(() {
  //         _userName = 'Pengguna Tamu';
  //         _userEmail = 'Tidak login';
  //       });
  //     }
  //   }
  // }

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
      body: Column(
        // Use Column to structure the entire body
        children: [
          Expanded(
            child: ListView(
              padding:
                  const EdgeInsets.all(16.0), // Padding around the entire list
              children: [
                // === Bagian Profil ===
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 24.0), // Space below profile section
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
                        // Anda mungkin menambahkan Image.network di sini untuk gambar profil dinamis
                        // child: _userProfileImageUrl != null ? Image.network(_userProfileImageUrl) : null,
                      ),
                      const SizedBox(
                          width: 16), // Space between circle and text
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ubah menjadi non-const jika ingin dinamis
                          Text(
                            'Lorem Ipsum', // Ganti dengan _userName jika dinamis
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'loremipsum@gmail.com', // Ganti dengan _userEmail jika dinamis
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

                const Divider(
                    height: 32, thickness: 1, color: Colors.grey), // Separator

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

                const Divider(
                    height: 32, thickness: 1, color: Colors.grey), // Separator

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

                const Divider(
                    height: 32, thickness: 1, color: Colors.grey), // Separator

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
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ), // Red text
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.grey),
                  onTap: _signOut, // <--- TERAPKAN FUNGSI LOGOUT DI SINI
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
