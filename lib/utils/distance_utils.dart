// In distance_utils.dart
import 'dart:math';

class DistanceUtils {
  static double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meters

    // Periksa bahwa semua input adalah double yang valid
    // dan tidak ada null di sini jika kode Anda memanggilnya dengan null.
    // (Dalam kasus Anda, Anda sudah melakukan null check sebelum memanggil)

    double dLat =
        _degreesToRadians(lat2 - lat1); // Perbedaan Latitude dalam radian
    double dLon =
        _degreesToRadians(lon2 - lon1); // Perbedaan Longitude dalam radian

    lat1 = _degreesToRadians(lat1); // Latitude 1 dalam radian
    lat2 = _degreesToRadians(lat2); // Latitude 2 dalam radian

    // Bagian formula Haversine
    double a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // Jarak dalam meter
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
