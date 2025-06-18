import 'package:flutter/material.dart';

class MeccaChatsPage extends StatefulWidget {
  const MeccaChatsPage({super.key});

  @override
  State<MeccaChatsPage> createState() => _MeccaChatsPageState();
}

class _MeccaChatsPageState extends State<MeccaChatsPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = []; // Daftar untuk menyimpan pesan

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messages.add(_messageController.text); // Tambahkan pesan ke daftar
        _messageController.clear(); // Bersihkan input setelah kirim
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Mecca Chats',
          style: TextStyle(
            fontWeight: FontWeight.normal,
          ),
        ),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Bagian untuk menampilkan pesan yang sudah dikirim
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/logo-meccha.png',
                            width: 150,
                            height: 150,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Dapatkan bantuan instan dengan bertanya pada Mecca AI',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return Align(
                        alignment: Alignment.centerRight, // Pesan muncul di kanan
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 218, 178), // Warna bubble pesan
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Text(
                            message,
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _messageController, // Kaitkan controller
              decoration: InputDecoration(
                hintText: 'Ask anything...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                // ==== Perubahan untuk Outline Abu-abu ====
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0), // Outline abu-abu
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0), // Outline abu-abu saat tidak fokus
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.blue, width: 2.0), // Outline biru saat fokus
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                suffixIcon: Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  decoration: const BoxDecoration( // Kembali ke warna awal
                    color: Color.fromARGB(255, 102, 99, 93),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage, // Panggil fungsi kirim pesan
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}