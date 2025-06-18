import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_caps/pages/login.dart';
import 'package:workmanager/workmanager.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // <-- Impor kIsWeb

// Fungsi callbackDispatcher ini tetap diperlukan untuk mobile
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
              ].where((element) => element != null && element!.isNotEmpty).join(', ');
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Gunakan kIsWeb untuk hanya menginisialisasi Workmanager jika BUKAN di web
  if (!kIsWeb) {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // Ubah ke `false` untuk production
    );
  }

  await Supabase.initialize(
      url: 'https://cnumhydzeezuelgrgtps.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNudW1oeWR6ZWV6dWVsZ3JndHBzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAxNDMwNTYsImV4cCI6MjA2NTcxOTA1Nn0.FXBtNmBhYM-zjPWEDL5juDng7mVGSLri1TKhNAftYqw');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mecca',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}