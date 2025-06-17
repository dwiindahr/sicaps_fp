// lib/familyRelationRequestPage.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FamilyRelationRequestPage extends StatefulWidget {
  const FamilyRelationRequestPage({super.key});

  @override
  _FamilyRelationRequestPageState createState() =>
      _FamilyRelationRequestPageState();
}

class _FamilyRelationRequestPageState extends State<FamilyRelationRequestPage> {
  List<Map<String, dynamic>> _incomingRequests = [];
  bool _isLoading = true;
  String? _errorMessage;
  late final SupabaseClient _supabase;
  late final Stream<List<Map<String, dynamic>>>
      _requestsRawStream; // Ubah nama variabel untuk menandakan raw stream

  @override
  void initState() {
    super.initState();
    _supabase = Supabase.instance.client;
    _initializeRequestsStream(); // Setup Realtime listener
    _fetchIncomingRequests(); // Initial fetch
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _initializeRequestsStream() {
    final currentUserEmail = _supabase.auth.currentUser?.email;
    if (currentUserEmail == null) {
      setState(() {
        _errorMessage = 'Anda harus login untuk melihat permintaan.';
        _isLoading = false;
      });
      return;
    }

    _requestsRawStream = _supabase
        .from('family_relation_requests')
        .stream(primaryKey: ['id']) // Hanya langganan ke perubahan tabel
        .order('created_at', ascending: false);

    _requestsRawStream.listen((data) async {
      // --- FILTER DI SISI KLIEN SETELAH DATA DITERIMA ---
      List<Map<String, dynamic>> filteredData = data.where((request) {
        return request['recipient_email'] == currentUserEmail &&
            request['status'] == 'pending';
      }).toList();
      // --- AKHIR FILTER ---

      List<Map<String, dynamic>> requestsWithNames = [];
      for (var request in filteredData) {
        final requesterProfile = await _supabase
            .from('profiles')
            .select('name')
            .eq('id', request['requester_id'])
            .limit(1);

        if (requesterProfile.isNotEmpty) {
          request['requester_name'] = requesterProfile[0]['name'];
        } else {
          request['requester_name'] = 'Pengguna Tidak Dikenal';
        }
        requestsWithNames.add(request);
      }

      setState(() {
        _incomingRequests = requestsWithNames;
        _isLoading = false;
      });
    }).onError((error) {
      setState(() {
        _errorMessage = 'Error memuat permintaan: $error';
        _isLoading = false;
      });
      print('Realtime stream error: $error');
    });
  }

  Future<void> _fetchIncomingRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final currentUserEmail = _supabase.auth.currentUser?.email;
    if (currentUserEmail == null) {
      setState(() {
        _errorMessage = 'Anda harus login untuk melihat permintaan.';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await _supabase
          .from('family_relation_requests')
          .select()
          .eq('recipient_email', currentUserEmail)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      List<Map<String, dynamic>> requestsWithNames = [];
      for (var request in response) {
        final requesterProfile = await _supabase
            .from('profiles')
            .select('name')
            .eq('id', request['requester_id'])
            .limit(1);

        if (requesterProfile.isNotEmpty) {
          request['requester_name'] = requesterProfile[0]['name'];
        } else {
          request['requester_name'] = 'Pengguna Tidak Dikenal';
        }
        requestsWithNames.add(request);
      }

      setState(() {
        _incomingRequests = requestsWithNames;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error memuat permintaan: $e';
        _isLoading = false;
      });
      print('Error fetching incoming requests: $e');
    }
  }

  // --- PERUBAHAN DI FUNGSI _handleRequest ---
  Future<void> _handleRequest(String requestId, String status) async {
    try {
      await _supabase
          .from('family_relation_requests')
          .update({'status': status}).eq('id', requestId);

      if (status == 'accepted') {
        _showSnackbar('Permintaan diterima!');
      } else {
        _showSnackbar('Permintaan ditolak!');
      }

      // Memanggil ulang fungsi fetch untuk memastikan UI diperbarui segera
      // Meskipun Realtime akan update, memanggil ini memastikan refresh segera.
      await _fetchIncomingRequests();
    } catch (e) {
      _showSnackbar('Gagal memperbarui permintaan: $e');
      print('Error handling request: $e');
    }
  }
  // ------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Permintaan Relasi Keluarga',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _incomingRequests.isEmpty
                  ? const Center(
                      child: Text(
                          'Tidak ada permintaan relasi keluarga yang tertunda.'))
                  : RefreshIndicator(
                      onRefresh: _fetchIncomingRequests,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _incomingRequests.length,
                        itemBuilder: (context, index) {
                          final request = _incomingRequests[index];
                          final requesterName = request['requester_name'] ??
                              'Pengguna Tidak Dikenal';

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Permintaan dari:',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    requesterName,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '(${request['recipient_email']})',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () => _handleRequest(
                                            request['id'], 'rejected'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: BorderSide(
                                              color: Colors.red.shade100),
                                        ),
                                        child: const Text('Tolak'),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () => _handleRequest(
                                            request['id'], 'accepted'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Terima'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
