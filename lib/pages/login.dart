import 'package:flutter/material.dart';
import 'package:project_caps/pages/register.dart';
import 'package:project_caps/pages/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/gestures.dart';

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
  bool _isHoveringSignUp = false; // New state variable for hover effect

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _updateUserLocationAndProfile(String userId) async {
    print(
        '[_updateUserLocationAndProfile] Memulai proses update lokasi untuk userId: $userId');
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print(
          '[_updateUserLocationAndProfile] Layanan lokasi diaktifkan: $serviceEnabled');
      if (!serviceEnabled) {
        _showSnackbar(
            'Layanan lokasi dinonaktifkan. Mohon aktifkan di pengaturan perangkat Anda.');
        return;
      }

      permission = await Geolocator.checkPermission();
      print(
          '[_updateUserLocationAndProfile] Status izin lokasi saat ini: $permission');

      if (permission == LocationPermission.denied) {
        print(
            '[_updateUserLocationAndProfile] Izin ditolak, meminta izin dari pengguna...');
        permission = await Geolocator.requestPermission();
        print(
            '[_updateUserLocationAndProfile] Status izin setelah permintaan: $permission');

        if (permission == LocationPermission.denied) {
          _showSnackbar(
              'Izin lokasi ditolak. Fitur lokasi otomatis mungkin tidak berfungsi.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('[_updateUserLocationAndProfile] Izin lokasi ditolak permanen.');
        _showSnackbar(
            'Izin lokasi ditolak secara permanen. Silakan ubah di pengaturan aplikasi.');
        return;
      }

      print(
          '[_updateUserLocationAndProfile] Izin diberikan. Mencoba mendapatkan posisi GPS...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print(
          '[_updateUserLocationAndProfile] Posisi didapatkan: ${position.latitude}, ${position.longitude}');

      print('[_updateUserLocationAndProfile] Melakukan reverse geocoding...');
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude,
          localeIdentifier: "id_ID");

      String formattedAddress = "Lokasi tidak diketahui";
      if (placemarks.isNotEmpty) {
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

      print(
          '[_updateUserLocationAndProfile] Memperbarui profil di Supabase...');
      await supabase.from('profiles').update({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'location': formattedAddress,
        'lastUpdated': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      print(
          '[_updateUserLocationAndProfile] Lokasi profil berhasil diperbarui di Supabase.');
    } catch (e) {
      print(
          '[_updateUserLocationAndProfile] Gagal mendapatkan atau memperbarui lokasi: ${e.toString()}');
      _showSnackbar('Gagal memperbarui lokasi otomatis: ${e.toString()}');
    }
  }

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

      await _updateUserLocationAndProfile(userId);
      print(
          '[LoginScreen] Fungsi _updateUserLocationAndProfile selesai dipanggil.');

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const HomePage()));
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

            // Email
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Password
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            // Login Button
            ElevatedButton(
              onPressed: () {
                _login();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                  side: const BorderSide(width: 2, color: Colors.orange)),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : const Text(
                      "Login",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 10),

            // Sign Up
            MouseRegion( 
              onEnter: (_) => setState(() => _isHoveringSignUp = true),
              onExit: (_) => setState(() => _isHoveringSignUp = false),
              child: RichText(
                text: TextSpan(
                  text: "Don't have an account? ",
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Sign Up",
                      style: TextStyle(
                        fontSize: 18,
                        color: _isHoveringSignUp 
                            ? const Color.fromARGB(255, 192, 84, 1) 
                            : const Color.fromARGB(255, 235, 116, 25), 
                        fontWeight: FontWeight.bold
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupScreen()),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}