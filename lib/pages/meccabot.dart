import 'package:flutter/material.dart';

class MeccaChatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mecca Chats',
          style: TextStyle(
            fontWeight: FontWeight.normal, 
          ),
        ),
        centerTitle: false, 
        elevation: 0, 
        foregroundColor: Colors.black, 
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Ask anything...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none, 
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: const BorderSide(color: Colors.blue, width: 1.0), 
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                suffixIcon: Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 102, 99, 93), 
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      // Implement send message functionality
                    },
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