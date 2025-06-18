import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:project_caps/pages/login.dart'; // Ganti dengan path ke halaman login Anda

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _userName = 'Memuat...';
  String _userEmail = 'Memuat...';

  late final SupabaseClient _supabase;

  @override
  void initState() {
    super.initState();
    _supabase = Supabase.instance.client;
    _loadUserProfile();
  }

  Future<void> _signOut() async {
    try {
      await _supabase.auth.signOut();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: ${e.toString()}')),
      );
      print('Error signing out: ${e.toString()}');
    }
  }

  Future<void> _loadUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final response = await _supabase
            .from('profiles')
            .select('name, email')
            .eq('id', user.id)
            .single();

        if (mounted) {
          setState(() {
            _userName = response['name'] as String? ?? 'Nama Tidak Diketahui';
            _userEmail = response['email'] as String? ??
                user.email ??
                'Email Tidak Diketahui';
          });
        }
      } catch (e) {
        print('Error loading user profile: $e');
        if (mounted) {
          setState(() {
            _userName = 'Error Memuat';
            _userEmail = 'Error Memuat';
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _userName = 'Pengguna Tamu';
          _userEmail = 'Tidak login';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background Scaffold jadi abu-abu muda
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ), 
        backgroundColor: Colors.white, // AppBar tetap putih
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 24.0), // Padding disesuaikan untuk spacing Card
              children: [
                // === Bagian Profil ===
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Row(
                    children: [
                      Container( // Ganti Container ini untuk menampilkan gambar
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300], 
                          image: const DecorationImage(
                            image: AssetImage('assets/images/profile-mecca.png'),
                            fit: BoxFit.cover, // Agar gambar mengisi seluruh lingkaran
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _userEmail,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // === Bagian Pengaturan Utama (Pengaturan Akun, Bahasa, Pusat Bantuan) ===
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSettingsListItem(
                          context, 'Pengaturan Akun', Icons.person_outline,
                          showDivider: true),
                      _buildSettingsListItem(context, 'Bahasa', Icons.language,
                          showDivider: true),
                      _buildSettingsListItem(
                          context, 'Pusat Bantuan', Icons.help_outline,
                          showDivider: false),
                    ],
                  ),
                ),

                const SizedBox(height: 24), // Spasi sebelum judul Login

                // === Bagian "Login" (dengan judul dan item keluar) ===
                const Text( // Mengembalikan judul 'Login'
                  'Login',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8), // Spasi di bawah judul Login

                Container( // Bungkus item logout dalam Container terpisah
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _buildSettingsListItem(
                    context,
                    'Keluar',
                    Icons.logout,
                    isLogout: true,
                    showDivider: false, // Logout tidak perlu divider
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method untuk membangun ListTile dengan ikon dan background abu-abu
  Widget _buildSettingsListItem(BuildContext context, String title,
      IconData icon, {bool isLogout = false, bool showDivider = false}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: isLogout ? Colors.red : Colors.grey[700]),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: isLogout ? Colors.red : Colors.black,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: isLogout ? Colors.red : Colors.grey,
          ),
          onTap: isLogout ? _signOut : () {
            print('Tapped on: $title');
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
        if (showDivider) // Tambahkan Divider jika showDivider true
          Divider(
            height: 1,
            thickness: 0.5,
            color: Colors.grey[300],
            indent: 16, // Indentasi agar sejajar dengan teks
            endIndent: 16, // Indentasi agar sejajar dengan teks
          ),
      ],
    );
  }
}