import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddRelationPage extends StatefulWidget {
  const AddRelationPage({super.key});

  @override
  _AddRelationPageState createState() => _AddRelationPageState();
}

class _AddRelationPageState extends State<AddRelationPage> {
  final TextEditingController _emailController = TextEditingController();
  List<Map<String, dynamic>> _sentPendingRequests = [];
  bool _isLoadingRequests = true;
  String? _requestsErrorMessage;

  late final SupabaseClient _supabase;
  late final Stream<List<Map<String, dynamic>>> _sentRequestsRawStream;

  @override
  void initState() {
    super.initState();
    _supabase = Supabase.instance.client;
    _initializeSentRequestsStream();
    _fetchSentPendingRequests();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _initializeSentRequestsStream() {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      setState(() {
        _requestsErrorMessage =
            'Anda harus login untuk melihat permintaan terkirim.';
        _isLoadingRequests = false;
      });
      return;
    }

    _sentRequestsRawStream = _supabase
        .from('family_relation_requests')
        .stream(primaryKey: ['id']).order('created_at', ascending: false);

    _sentRequestsRawStream.listen((data) {
      List<Map<String, dynamic>> filteredData = data.where((request) {
        return request['requester_id'] == currentUserId &&
            request['status'] == 'pending';
      }).toList();

      setState(() {
        _sentPendingRequests = filteredData;
        _isLoadingRequests = false;
      });
    }).onError((error) {
      setState(() {
        _requestsErrorMessage = 'Error memuat permintaan terkirim: $error';
        _isLoadingRequests = false;
      });
      print('Realtime stream error for sent requests: $error');
    });
  }

  Future<void> _fetchSentPendingRequests() async {
    setState(() {
      _isLoadingRequests = true;
      _requestsErrorMessage = null;
    });

    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      setState(() {
        _requestsErrorMessage =
            'Anda harus login untuk melihat permintaan terkirim.';
        _isLoadingRequests = false;
      });
      return;
    }

    try {
      final response = await _supabase
          .from('family_relation_requests')
          .select()
          .eq('requester_id', currentUserId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      setState(() {
        _sentPendingRequests = response;
        _isLoadingRequests = false;
      });
    } catch (e) {
      setState(() {
        _requestsErrorMessage = 'Error memuat permintaan terkirim: $e';
        _isLoadingRequests = false;
      });
      print('Error fetching sent pending requests: $e');
    }
  }

  Future<void> _sendRelationInvitation() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnackbar('Mohon masukkan alamat email.');
      return;
    }

    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      _showSnackbar('Anda harus login untuk mengirim undangan.');
      return;
    }

    if (currentUser.email == email) {
      _showSnackbar('Anda tidak bisa mengundang diri sendiri.');
      return;
    }

    try {
      final recipientProfile = await _supabase
          .from('profiles')
          .select('id, email')
          .eq('email', email)
          .limit(1);

      if (recipientProfile.isEmpty) {
        _showSnackbar(
            'Pengguna dengan email ini tidak terdaftar. Mereka perlu mendaftar terlebih dahulu.');
        return;
      }

      final recipientId = recipientProfile[0]['id'];

      final existingAcceptedRelation = await _supabase
          .from('family_relation_requests')
          .select('id')
          .or('and(requester_id.eq.${currentUser.id},recipient_email.eq.$email),'
              'and(requester_id.eq.$recipientId,recipient_email.eq.${currentUser.email})')
          .eq('status', 'accepted')
          .limit(1);

      if (existingAcceptedRelation.isNotEmpty) {
        _showSnackbar('Anda sudah berteman dengan pengguna ini.');
        return;
      }

      final existingSentPendingRequest = await _supabase
          .from('family_relation_requests')
          .select('id')
          .eq('requester_id', currentUser.id)
          .eq('recipient_email', email)
          .eq('status', 'pending')
          .limit(1);

      if (existingSentPendingRequest.isNotEmpty) {
        _showSnackbar(
            'Anda sudah mengirim permintaan relasi ke email ini dan masih tertunda.');
        return;
      }

      final incomingPendingRequest = await _supabase
          .from('family_relation_requests')
          .select('id')
          .eq('requester_id', recipientId)
          .eq('recipient_email', currentUser.email ?? '')
          .eq('status', 'pending')
          .limit(1);

      if (incomingPendingRequest.isNotEmpty) {
        _showSnackbar(
            'Pengguna ini sudah mengirim permintaan relasi kepada Anda. Silakan cek daftar permintaan masuk.');
        return;
      }

      await _supabase.from('family_relation_requests').insert({
        'requester_id': currentUser.id,
        'recipient_email': email,
        'status': 'pending',
      });

      _showSnackbar('Permintaan relasi ke $email berhasil dikirim!');
      _emailController.clear();
    } on PostgrestException catch (e) {
      print('Supabase error: ${e.message}');
      _showSnackbar('Gagal mengirim permintaan relasi: ${e.message}');
    } catch (e) {
      print('General error: $e');
      _showSnackbar('Terjadi kesalahan: $e');
    }
  }

  Future<void> _cancelSentRequest(String requestId) async {
    try {
      await _supabase
          .from('family_relation_requests')
          .update({'status': 'cancelled'}).eq('id', requestId);
      _showSnackbar('Permintaan berhasil dibatalkan.');
    } catch (e) {
      _showSnackbar('Gagal membatalkan permintaan: $e');
      print('Error cancelling request: $e');
    }
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
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Kirim permintaan relasi melalui email',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'john@example.com',
                // ==== Perubahan untuk Outline Abu-abu Circular 100 ====
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                // ===========================================
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 12.0),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton(
                    onPressed: _sendRelationInvitation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 102, 0), // Warna background orange
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(100), // Border radius circular 100
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    child: const Text('Kirim',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 24),
            const Text(
              'Permintaan Relasi Terkirim (Pending):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _isLoadingRequests
                ? const Center(child: CircularProgressIndicator())
                : _requestsErrorMessage != null
                    ? Center(child: Text(_requestsErrorMessage!))
                    : _sentPendingRequests.isEmpty
                        ? const Center(
                            child: Text(
                                'Tidak ada permintaan relasi terkirim yang tertunda.'))
                        : Expanded(
                            child: ListView.builder(
                              itemCount: _sentPendingRequests.length,
                              itemBuilder: (context, index) {
                                final request = _sentPendingRequests[index];
                                return Card(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  elevation: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Kepada: ${request['recipient_email']}',
                                            style:
                                                const TextStyle(fontSize: 15),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              _cancelSentRequest(request['id']),
                                          style: TextButton.styleFrom(
                                              foregroundColor: Colors.red),
                                          child: const Text('Batalkan'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ],
        ),
      ),
    );
  }
}