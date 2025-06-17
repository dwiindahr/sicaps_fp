import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_caps/pages/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
