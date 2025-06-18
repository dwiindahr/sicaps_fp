import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_caps/pages/login.dart';
import 'package:project_caps/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://cnumhydzeezuelgrgtps.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNudW1oeWR6ZWV6dWVsZ3JndHBzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAxNDMwNTYsImV4cCI6MjA2NTcxOTA1Nn0.FXBtNmBhYM-zjPWEDL5juDng7mVGSLri1TKhNAftYqw',
  );

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  if (isLoggedIn) {
    await _updateUserLocationIfLoggedIn();
  }

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mecca',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const HomePage() : const LoginScreen(),
    );
  }
}

/// ✅ Fungsi untuk update lokasi otomatis saat auto-login
Future<void> _updateUserLocationIfLoggedIn() async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) return;

  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
      localeIdentifier: "id_ID",
    );

    String formattedAddress = "Lokasi tidak diketahui";
    if (placemarks.isNotEmpty) {
      final place = placemarks[0];
      formattedAddress = [
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.country
      ].where((e) => e != null && e!.isNotEmpty).join(', ');
    }

    await supabase.from('profiles').update({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'location': formattedAddress,
      'lastUpdated': DateTime.now().toIso8601String(),
    }).eq('id', user.id);
  } catch (e) {
    print('Gagal update lokasi otomatis saat auto-login: $e');
  }
}
