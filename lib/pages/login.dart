import 'package:flutter/material.dart';
import 'package:project_caps/pages/register.dart';
import 'package:project_caps/pages/home.dart'; // Pastikan ini halaman utama Anda
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator
import 'package:geocoding/geocoding.dart'; // Import geocoding

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool isLoading = false;

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // --- FUNGSI _updateUserLocationAndProfile YANG DIPERBAIKI ---
  Future<void> _updateUserLocationAndProfile(String userId) async {
    print(
        '[_updateUserLocationAndProfile] Memulai proses update lokasi untuk userId: $userId');
    try {
      // 1. Cek apakah layanan lokasi diaktifkan
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print(
          '[_updateUserLocationAndProfile] Layanan lokasi diaktifkan: $serviceEnabled');
      if (!serviceEnabled) {
        _showSnackbar(
            'Layanan lokasi dinonaktifkan. Mohon aktifkan di pengaturan perangkat Anda.');
        return; // Keluar jika layanan tidak aktif
      }

      // 2. Cek status izin lokasi saat ini dan minta jika ditolak
      permission = await Geolocator.checkPermission();
      print(
          '[_updateUserLocationAndProfile] Status izin lokasi saat ini: $permission');

      if (permission == LocationPermission.denied) {
        // Jika izin ditolak, minta izin dari pengguna
        print(
            '[_updateUserLocationAndProfile] Izin ditolak, meminta izin dari pengguna...');
        permission = await Geolocator
            .requestPermission(); // <--- INI PANGGILAN YANG HILANG!
        print(
            '[_updateUserLocationAndProfile] Status izin setelah permintaan: $permission');

        if (permission == LocationPermission.denied) {
          _showSnackbar(
              'Izin lokasi ditolak. Fitur lokasi otomatis mungkin tidak berfungsi.');
          return; // Keluar jika izin tetap ditolak setelah permintaan
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Jika izin ditolak permanen, informasikan pengguna untuk mengubah di pengaturan
        print('[_updateUserLocationAndProfile] Izin lokasi ditolak permanen.');
        _showSnackbar(
            'Izin lokasi ditolak secara permanen. Silakan ubah di pengaturan aplikasi.');
        return; // Keluar jika izin ditolak permanen
      }

      // 3. Dapatkan posisi saat ini (hanya jika izin sudah diberikan)
      print(
          '[_updateUserLocationAndProfile] Izin diberikan. Mencoba mendapatkan posisi GPS...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high, // Akurasi tinggi
      );
      print(
          '[_updateUserLocationAndProfile] Posisi didapatkan: ${position.latitude}, ${position.longitude}');

      // 4. Reverse Geocoding: Konversi koordinat menjadi alamat
      print('[_updateUserLocationAndProfile] Melakukan reverse geocoding...');
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude,
          localeIdentifier: "id_ID" // Opsional: untuk bahasa Indonesia
          );

      String formattedAddress = "Lokasi tidak diketahui";
      if (placemarks.isNotEmpty) {
        // Gabungkan komponen alamat yang ada dan tidak null/kosong
        Placemark place = placemarks[0];
        formattedAddress = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country
        ].where((element) => element != null && element!.isNotEmpty).join(', ');
      }
      print(
          '[_updateUserLocationAndProfile] Alamat terformat: $formattedAddress');

      // 5. Perbarui profil pengguna di Supabase
      print(
          '[_updateUserLocationAndProfile] Memperbarui profil di Supabase...');
      await supabase.from('profiles').update({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'location': formattedAddress,
        'lastUpdated': DateTime.now().toIso8601String(),
      }).eq('id', userId); // Menggunakan userId yang dilewatkan
      print(
          '[_updateUserLocationAndProfile] Lokasi profil berhasil diperbarui di Supabase.');
    } catch (e) {
      print(
          '[_updateUserLocationAndProfile] Gagal mendapatkan atau memperbarui lokasi: ${e.toString()}');
      _showSnackbar('Gagal memperbarui lokasi otomatis: ${e.toString()}');
    }
  }
  // -------------------------------------------------------------------

  /// function for login (tidak ada perubahan signifikan di sini)
  Future<void> _login() async {
    final password = passwordController.text.trim();
    final email = emailController.text.trim();

    setState(() {
      isLoading = true;
    });
    print('[LoginScreen] Memulai proses login.');
    try {
      final AuthResponse res = await supabase.auth
          .signInWithPassword(password: password, email: email);
      final userId = res.user?.id;

      if (userId == null) {
        print('[LoginScreen] Login berhasil, tetapi User ID tidak ditemukan.');
        throw Exception('User ID not found');
      }
      print('[LoginScreen] Login berhasil untuk User ID: $userId');

      // Setelah login berhasil, panggil fungsi update lokasi dan profil
      await _updateUserLocationAndProfile(userId);
      print(
          '[LoginScreen] Fungsi _updateUserLocationAndProfile selesai dipanggil.');

      // Navigasi ke halaman utama aplikasi
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const HomePage())); // Pastikan HomePage adalah const
      _showSnackbar('Login berhasil!');
    } on AuthException catch (e) {
      print('[LoginScreen] Auth Error: ${e.message}');
      _showSnackbar('Error autentikasi: ${e.message}');
    } catch (e) {
      print('[LoginScreen] Unexpected Error: ${e.toString()}');
      _showSnackbar('Terjadi kesalahan tak terduga: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
      print('[LoginScreen] Proses login selesai.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo-meccha.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            const Text("Welcome Back!",
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange)),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                  labelText: "Email", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                  labelText: "Password", border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _login();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                  side: const BorderSide(width: 2, color: Colors.orange)),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : const Text(
                      "Login",
                      style:
                          TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                    ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignupScreen()));
              },
              child: const Text(
                "Don't have an account? Sign Up",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            )
          ],
        ),
      ),
    );
  }
}
