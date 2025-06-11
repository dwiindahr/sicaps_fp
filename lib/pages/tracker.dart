import 'package:flutter/material.dart';

class LiveTrackerPage extends StatelessWidget {
  final List<String> names = ['Nelysa', 'Bai', 'Rudi'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Tracker')),
      body: Column(
        children: [
          ...names.map((name) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(decoration: InputDecoration(labelText: name)),
          )),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/tambah-relasi'),
            child: Text('Tambah Relasi Keluarga'),
          ),
        ],
      ),
    );
  }
}
