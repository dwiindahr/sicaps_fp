import 'package:flutter/material.dart';

class DetailLokasiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Lokasi')),
      body: Center(
        child: Column(
          children: [
            Icon(Icons.map, size: 100),
            Text('Jarak: 1.2 km'),
            Text('Alamat: Jalan Al-Haram No. 1'),
          ],
        ),
      ),
    );
  }
}
