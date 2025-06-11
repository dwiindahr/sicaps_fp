import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk Clipboard

class AddRelationPage extends StatefulWidget {
  @override
  _AddRelationPageState createState() => _AddRelationPageState();
}

class _AddRelationPageState extends State<AddRelationPage> {
  final TextEditingController _emailController = TextEditingController();
  final String _shareableLink = 'meccabot/invite/eouog083ry02rtbk'; // Contoh link dummy

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tambah Relasi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios), // Tombol kembali
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shareable invitation link',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!), // Border abu-abu
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  Icon(Icons.link, color: Colors.grey[600]), // Ikon link
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _shareableLink, // Tampilkan link dummy
                      style: const TextStyle(color: Colors.blue), // Warna biru
                      overflow: TextOverflow.ellipsis, // Jika terlalu panjang, gunakan ...
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, color: Colors.grey[600]), // Ikon copy
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _shareableLink));
                      _showSnackbar('Link disalin!');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'or invite by email', // Teks pemisah
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'john@example.com', // Hint text
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue, width: 2), // Border saat fokus
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Aksi saat tombol Invite ditekan
                      if (_emailController.text.isNotEmpty) {
                        _showSnackbar('Mengirim undangan ke ${_emailController.text}');
                        _emailController.clear(); // Bersihkan field setelah kirim
                      } else {
                        _showSnackbar('Mohon masukkan alamat email.');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange, // Warna oranye
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    child: const Text('Invite', style: TextStyle(color: Colors.white)), // Teks tombol
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // BottomNavigationBar akan diatur di MainAppScreen
    );
  }
}