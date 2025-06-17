import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tambahRelasi.dart'; // Import halaman untuk menambah relasi
import 'detailLokasi.dart'; // Import halaman detail lokasi
import 'package:project_caps/widgets/family_member.dart'; // Pastikan path ini benar
import 'package:project_caps/pages/listPermintaanRelasi.dart'; // Import FamilyRelationRequestPage

class LiveTrackerPage extends StatefulWidget {
  const LiveTrackerPage({super.key});

  @override
  _LiveTrackerPageState createState() => _LiveTrackerPageState();
}

class _LiveTrackerPageState extends State<LiveTrackerPage> {
  List<FamilyMember> familyMembers = [];
  List<Map<String, dynamic>> incomingRelationRequests =
      []; // Untuk badge notifikasi
  bool _isLoading = true;
  String? _errorMessage;

  late final SupabaseClient _supabase;
  late final Stream<List<Map<String, dynamic>>>
      _acceptedRelationsRawStream; // Stream untuk relasi aktif
  late final Stream<List<Map<String, dynamic>>>
      _relationRequestsRawStream; // Stream untuk permintaan masuk (badge)

  @override
  void initState() {
    super.initState();
    _supabase = Supabase.instance.client;
    _initializeStreams(); // Setup Realtime listeners
    _fetchData(); // Initial fetch for both family members and pending requests count
  }

  @override
  void dispose() {
    // Pastikan untuk membatalkan langganan stream saat widget di-dispose
    // Pada versi supabase_flutter yang lebih baru, stream().listen() mengembalikan StreamSubscription.
    // Jika Anda ingin mengelola disposal secara eksplisit, simpan StreamSubscription dan panggil .cancel() di dispose.
    super.dispose();
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _initializeStreams() {
    final currentUserEmail = _supabase.auth.currentUser?.email;
    final currentUserId = _supabase.auth.currentUser?.id;

    if (currentUserEmail != null && currentUserId != null) {
      // Stream untuk relasi keluarga yang sudah diterima (status 'accepted')
      _acceptedRelationsRawStream = _supabase
          .from('family_relation_requests')
          .stream(primaryKey: ['id']).order('updated_at', ascending: false);

      _acceptedRelationsRawStream.listen((data) async {
        List<String> relatedUserIds = [];
        // Filter di sisi klien: relasi yang melibatkan pengguna saat ini dan berstatus 'accepted'
        List<Map<String, dynamic>> filteredAccepted = data.where((request) {
          return (request['requester_id'] == currentUserId ||
                  request['recipient_email'] == currentUserEmail) &&
              request['status'] == 'accepted';
        }).toList();

        for (var req in filteredAccepted) {
          String idToFetch;
          if (req['requester_id'] == currentUserId) {
            // Jika saya requester, ID teman adalah ID dari recipient_email
            // Kita perlu mengambil ID dari tabel profiles berdasarkan email recipient.
            final recipientProfile = await _supabase
                .from('profiles')
                .select('id')
                .eq('email', req['recipient_email'])
                .limit(1)
                .single();
            idToFetch = recipientProfile['id'];
          } else {
            // Jika saya recipient, ID teman adalah requester_id
            idToFetch = req['requester_id'];
          }
          if (!relatedUserIds.contains(idToFetch)) {
            // Hindari duplikasi jika ada relasi dua arah
            relatedUserIds.add(idToFetch);
          }
        }

        // Ambil profil lengkap dari ID pengguna yang merupakan relasi keluarga aktif
        if (relatedUserIds.isNotEmpty) {
          final profilesResponse = await _supabase
              .from('profiles')
              .select() // Ambil semua kolom profil
              .inFilter('id', relatedUserIds) // PERBAIKAN: Gunakan .inFilter()
              .order('name', ascending: true);

          setState(() {
            familyMembers = profilesResponse
                .map((json) => FamilyMember.fromJson(json))
                .toList();
          });
        } else {
          setState(() {
            familyMembers = [];
          });
        }
      }).onError((error) {
        print('Error listening to accepted relations stream: $error');
        setState(() {
          _errorMessage = 'Error Realtime Relasi: ${error.toString()}';
        });
      });

      // Stream untuk menghitung permintaan masuk (untuk badge notifikasi)
      _relationRequestsRawStream = _supabase
          .from('family_relation_requests')
          .stream(primaryKey: ['id']).order('created_at', ascending: false);

      _relationRequestsRawStream.listen((data) {
        // Filter di sisi klien: permintaan yang masuk ke pengguna ini dan statusnya 'pending'
        List<Map<String, dynamic>> filteredIncoming = data.where((request) {
          return request['recipient_email'] == currentUserEmail &&
              request['status'] == 'pending';
        }).toList();

        setState(() {
          incomingRelationRequests =
              filteredIncoming; // Update jumlah untuk badge
        });
      }).onError((error) {
        print(
            'Error listening to incoming relation requests for badge: $error');
        setState(() {
          _errorMessage = 'Error Realtime Permintaan: ${error.toString()}';
        });
      });
    } else {
      // If user is not logged in, set loading to false and show error
      setState(() {
        _errorMessage = 'Silakan login untuk melihat pelacak keluarga.';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null || currentUser.email == null) {
      setState(() {
        _errorMessage = 'Anda harus login untuk melihat data.';
        _isLoading = false;
      });
      return;
    }

    try {
      // Fetch data untuk badge notifikasi permintaan masuk
      final incomingCount = await _supabase
          .from('family_relation_requests')
          .select()
          .eq('recipient_email', currentUser.email!)
          .eq('status', 'pending')
          .order('created_at', ascending: false);
      setState(() {
        incomingRelationRequests = incomingCount;
      });

      // Fetch data untuk daftar relasi keluarga yang sudah diterima
      final acceptedRequests = await _supabase
          .from('family_relation_requests')
          .select(
              'requester_id, recipient_email') // Hanya ambil kolom yang diperlukan
          .or('requester_id.eq.${currentUser.id},recipient_email.eq.${currentUser.email}')
          .eq('status', 'accepted');

      List<String> relatedUserIds = [];
      for (var req in acceptedRequests) {
        String idToFetch;
        if (req['requester_id'] == currentUser.id) {
          // Jika saya adalah requester, teman adalah recipient_email (perlu ID dari profiles)
          final recipientProfile = await _supabase
              .from('profiles')
              .select('id')
              .eq('email', req['recipient_email'])
              .limit(1)
              .single(); // Gunakan .single()
          idToFetch = recipientProfile['id'];
        } else {
          // Jika saya adalah recipient, teman adalah requester_id
          idToFetch = req['requester_id'];
        }
        if (!relatedUserIds.contains(idToFetch)) {
          relatedUserIds.add(idToFetch);
        }
      }

      List<FamilyMember> fetchedMembers = [];
      if (relatedUserIds.isNotEmpty) {
        final profilesResponse = await _supabase
            .from('profiles')
            .select() // Ambil semua data profil
            .inFilter('id', relatedUserIds) // PERBAIKAN: Gunakan .inFilter()
            .order('name', ascending: true);
        fetchedMembers = profilesResponse
            .map((json) => FamilyMember.fromJson(json))
            .toList();
      }

      setState(() {
        familyMembers = fetchedMembers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error memuat daftar relasi keluarga: ${e.toString()}';
        _isLoading = false;
      });
      print('Error fetching data for LiveTrackerPage: ${e.toString()}');
    }
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
          Stack(
            // Gunakan Stack untuk badge notifikasi
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {
                  _showSnackbar('Notifikasi ditekan!');
                },
              ),
              if (incomingRelationRequests.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '${incomingRelationRequests.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
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
                  'Pilih anggota keluarga yang ingin dilacak atau tambah kontak anggota keluarga Anda.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddRelationPage()),
                    );
                    _fetchData(); // Panggil _fetchData untuk refresh kedua daftar setelah kembali
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Tambah Relasi Keluarga',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FamilyRelationRequestPage()),
                    );
                    _fetchData(); // Panggil _fetchData untuk refresh kedua daftar setelah kembali
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Lihat Permintaan Relasi Keluarga (${incomingRelationRequests.length})',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : Expanded(
                      child: RefreshIndicator(
                        onRefresh:
                            _fetchData, // Memuat ulang data saat pull-to-refresh
                        child: familyMembers.isEmpty
                            ? const Center(
                                child: Text(
                                    'Belum ada relasi keluarga yang aktif.'))
                            : ListView.builder(
                                itemCount: familyMembers.length,
                                itemBuilder: (context, index) {
                                  final member = familyMembers[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 8.0),
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                LocationDetailPage(
                                                    member: member),
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                            color: Colors.grey[300]!, width: 1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16.0, horizontal: 12.0),
                                        backgroundColor: Colors.white,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          member.name,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
        ],
      ),
    );
  }
}
