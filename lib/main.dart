import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_caps/pages/login.dart';
import 'package:project_caps/pages/home.dart'; // <-- Pastikan ini diimpor jika HomePage digunakan
import 'package:flutter/foundation.dart' show kIsWeb; // <-- IMPOR INI
import 'package:workmanager/workmanager.dart'; // <-- IMPOR INI
import 'package:geolocator/geolocator.dart'; // <-- IMPOR INI
import 'package:geocoding/geocoding.dart'; // <-- IMPOR INI

// =========================================================================
// Fungsi TOP-LEVEL untuk Workmanager (harus di luar class manapun)
// =========================================================================
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      await Supabase.initialize(
        url: 'https://cnumhydzeezuelgrgtps.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNudW1oeWR6ZWV6dWVsZ3JndHBzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAxNDMwNTYsImV4cCI6MjA2NTcxOTA1Nn0.FXBtNmBhYM-zjPWEDL5juDng7mVGSLri1TKhNAftYqw',
      );
    } catch (e) {
      print("[Workmanager] Supabase init error/already initialized: $e");
    }

    final supabase = Supabase.instance.client;

    switch (taskName) {
      case "updateLocationTask":
        print("[Workmanager] Executing updateLocationTask");
        try {
          final user = supabase.auth.currentUser;
          if (user == null) {
            print("[Workmanager] User not logged in in background, skipping location update.");
            return Future.value(true);
          }

          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) {
            print("[Workmanager] Location services are disabled. Cannot update location.");
            return Future.value(true);
          }

          Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high);

          String formattedAddress = "Lokasi tidak diketahui";
          try {
            List<Placemark> placemarks = await placemarkFromCoordinates(
                position.latitude, position.longitude,
                localeIdentifier: "id_ID");
            if (placemarks.isNotEmpty) {
              Placemark place = placemarks[0];
              formattedAddress = [
                place.street, place.subLocality, place.locality,
                place.administrativeArea, place.country
              ].where((element) => element != null && element.isNotEmpty).join(', ');
            }
          } catch (e) {
            print("[Workmanager] Error during reverse geocoding in background: $e");
          }

          await supabase.from('profiles').update({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'location': formattedAddress,
            'lastUpdated': DateTime.now().toIso8601String(),
          }).eq('id', user.id);

          print("[Workmanager] Location updated successfully for user ${user.id}: Lat ${position.latitude}, Lng ${position.longitude}");
          return Future.value(true);
        } catch (e) {
          print("[Workmanager] Background location update failed with error: $e");
          return Future.value(false);
        }
      default:
        print("[Workmanager] Unknown task received: $taskName");
        return Future.value(false);
    }
  });
}

// =========================================================================
// Fungsi _updateUserLocationIfLoggedIn dipindahkan ke bawah MyApp
// karena biasanya tidak seharusnya di dalam atau di atas main().
// =========================================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Workmanager hanya jika BUKAN di web
  if (!kIsWeb) {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
  }

  await Supabase.initialize(
      url: 'https://cnumhydzeezuelgrgtps.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNudW1oeWR6ZWV6dWVsZ3JndHBzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAxNDMwNTYsImV4cCI6MjA2NTcxOTA1Nn0.FXBtNmBhYM-zjPWEDL5juDng7mVGSLri1TKhNAftYqw');

  final isLoggedIn = Supabase.instance.client.auth.currentUser != null;

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
      ].where((e) => e != null && e.isNotEmpty).join(', ');
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