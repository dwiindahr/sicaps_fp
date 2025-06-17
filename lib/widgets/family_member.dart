// lib/widgets/family_member.dart

class FamilyMember {
  final String id; // Penting untuk merujuk ke profil Supabase
  final String name;
  final String email; // Tambahkan email di sini
  final String location;
  final String distance;
  final String lastUpdated;
  final double? latitude;
  final double? longitude;

  FamilyMember({
    required this.id,
    required this.name,
    required this.email, // Tambahkan di constructor
    required this.location,
    required this.distance,
    required this.lastUpdated,
    this.latitude,
    this.longitude,
  });

  // Factory constructor untuk membuat objek FamilyMember dari JSON (dari Supabase)
  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] as String, // Pastikan ada 'id' di JSON
      name: json['name'] as String,
      email: json['email'] as String, // Pastikan ada 'email' di JSON
      location: json['location'] as String? ?? 'Lokasi Tidak Diketahui',
      distance: json['distance'] as String? ?? 'Tidak Diketahui',
      lastUpdated: json['lastUpdated'] != null
          ? _formatLastUpdated(DateTime.parse(json['lastUpdated']))
          : 'Belum diperbarui',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  // Fungsi helper untuk format 'lastUpdated' menjadi format yang lebih mudah dibaca
  static String _formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }
}
