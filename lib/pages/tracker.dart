import 'package:flutter/material.dart';
import 'tambahRelasi.dart'; // Import halaman untuk menambah relasi
import 'detailLokasi.dart'; // Import halaman detail lokasi
import 'package:project_caps/widgets/family_member.dart';

class LiveTrackerPage extends StatefulWidget {
  @override
  _LiveTrackerPageState createState() => _LiveTrackerPageState();
}

class _LiveTrackerPageState extends State<LiveTrackerPage> {
  // Inisialisasi daftar anggota keluarga dengan data yang konsisten
  List<FamilyMember> familyMembers = [
    FamilyMember(
      name: 'Najwa',
      location: 'Al Haram, Makkah 24231, Arab Saudi',
      distance: 'Berjarak 100km',
      lastUpdated: '20j yang lalu',
      latitude: 21.4225, // Example latitude for Mecca
      longitude: 39.8262, // Example longitude for Mecca
    ),
    // Pastikan Eka dan Budi juga diinisialisasi dengan properti nullable
    FamilyMember(
      name: 'Eka',
      location: 'Jabal Nur, Makkah 24231, Arab Saudi',
      distance: 'Berjarak 50km',
      lastUpdated: '1h yang lalu',
      latitude: 21.4225, // Contoh koordinat untuk Eka
      longitude: 39.8262, // Contoh koordinat untuk Eka
    ),
    FamilyMember(
      name: 'Budi',
      location: 'Jannat al-Mu\'alla, Makkah 24231, Arab Saudi',
      distance: 'Berjarak 10km',
      lastUpdated: '30m yang lalu',
      latitude: 21.4225, // Contoh koordinat untuk Budi
      longitude: 39.8262, // Contoh koordinat untuk Budi
    ),
  ];

  // Metode untuk menambahkan anggota keluarga baru
  void _addFamilyMember(FamilyMember newMember) {
    setState(() {
      familyMembers.add(newMember);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Live Tracker',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none), // Ikon bel notifikasi
            onPressed: () {
              // Aksi saat ikon notifikasi ditekan
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifikasi ditekan!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih anggota keluarga yang ingin dilacak atau tambah kontak anggota keluarga anda.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    // Navigasi ke halaman AddRelationPage
                    // Menerima hasil (nama) dari AddRelationPage
                    final String? newName = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddRelationPage()),
                    );
                    if (newName != null && newName.isNotEmpty) {
                      _addFamilyMember(FamilyMember(
                        name: newName,
                        location: 'Lokasi Tidak Diketahui', // Default jika tidak ada data
                        distance: 'Tidak Diketahui',
                        lastUpdated: 'Baru ditambahkan',
                        latitude: null, // Default null
                        longitude: null, // Default null
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$newName ditambahkan ke daftar!')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange, // Warna oranye sesuai gambar
                    minimumSize: const Size(double.infinity, 50), // Lebar penuh, tinggi tetap
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Sudut membulat
                    ),
                  ),
                  child: const Text(
                    'Tambah Relasi Keluarga',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: familyMembers.length,
              itemBuilder: (context, index) {
                final member = familyMembers[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: OutlinedButton( // Menggunakan OutlinedButton untuk efek border
                    onPressed: () {
                      // Navigasi ke halaman LocationDetailPage saat nama diklik
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LocationDetailPage(member: member),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!, width: 1), // Border abu-abu muda
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                      backgroundColor: Colors.white, // Latar belakang tombol putih
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft, // Teks rata kiri di dalam tombol
                      child: Text(
                        member.name,
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}