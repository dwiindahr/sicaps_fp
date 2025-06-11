import 'package:flutter/material.dart';

class TambahRelasiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Relasi')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Undangan: https://wr.app/invite123'),
            ElevatedButton(
              onPressed: () {},
              child: Text('Salin Tautan'),
            ),
          ],
        ),
      ),
    );
  }
}
