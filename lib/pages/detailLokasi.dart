import 'package:flutter/material.dart';
import 'package:project_caps/widgets/family_member.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:project_caps/utils/distance_utils.dart'; // Pastikan ini ada dan berisi fungsi kalkulasi jarak
import 'package:geolocator/geolocator.dart'; // Import geolocator package

class LocationDetailPage extends StatefulWidget {
  final FamilyMember member;

  const LocationDetailPage({super.key, required this.member});

  @override
  State<LocationDetailPage> createState() => _LocationDetailPageState();
}

class _LocationDetailPageState extends State<LocationDetailPage> {
  late MapController mapController;
  GeoPoint? _currentUserLocation; // Untuk menyimpan lokasi pengguna saat ini
  String _distanceToMember = 'Menghitung...'; // Untuk menampilkan jarak

  @override
  void initState() {
    super.initState();

    print('[LocationDetailPage] Initializing map for ${widget.member.name}');
    print(
        '[LocationDetailPage] Member data - Lat: ${widget.member.latitude}, Lng: ${widget.member.longitude}');

    mapController = MapController(
      initPosition: GeoPoint(
        latitude: widget.member.latitude ?? 0.0,
        longitude: widget.member.longitude ?? 0.0,
      ),
    );

    _getCurrentLocationAndCalculateDistance(); // Panggil fungsi untuk mendapatkan lokasi dan menghitung jarak
  }

  Future<void> _getCurrentLocationAndCalculateDistance() async {
    try {
      // 1. Dapatkan lokasi pengguna saat ini
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentUserLocation = GeoPoint(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        print(
            '[LocationDetailPage] Current User Location: ${_currentUserLocation!.latitude}, ${_currentUserLocation!.longitude}');
      });

      // 2. Jika lokasi anggota dan lokasi pengguna saat ini tersedia, hitung jarak
      if (widget.member.latitude != null &&
          widget.member.longitude != null &&
          _currentUserLocation != null) {
        double distanceInMeters = DistanceUtils.calculateDistance(
          _currentUserLocation!.latitude,
          _currentUserLocation!.longitude,
          widget.member.latitude!,
          widget.member.longitude!,
        );

        String formattedDistance;
        if (distanceInMeters < 1000) {
          formattedDistance = '${distanceInMeters.round()} meter';
        } else {
          formattedDistance =
              '${(distanceInMeters / 1000).toStringAsFixed(2)} km';
        }

        setState(() {
          _distanceToMember = formattedDistance;
        });
        print('[LocationDetailPage] Jarak ke anggota: $_distanceToMember');
      } else {
        setState(() {
          _distanceToMember = 'Lokasi tidak lengkap untuk perhitungan jarak';
        });
        print(
            '[LocationDetailPage] Peringatan: Lokasi anggota atau pengguna saat ini tidak lengkap untuk perhitungan jarak.');
      }
    } catch (e) {
      print('[LocationDetailPage] Error getting current location: $e');
      setState(() {
        _distanceToMember = 'Gagal mendapatkan lokasi';
      });
    }
  }

  Future<void> _onMapReady() async {
    print('[LocationDetailPage] onMapIsReady dipicu.');
    if (widget.member.latitude != null && widget.member.longitude != null) {
      GeoPoint memberLocation = GeoPoint(
        latitude: widget.member.latitude!,
        longitude: widget.member.longitude!,
      );

      print(
          '[LocationDetailPage] Memindahkan peta ke lokasi anggota: ${memberLocation.latitude}, ${memberLocation.longitude}');
      await mapController.moveTo(memberLocation);
      await mapController.setZoom(zoomLevel: 15.0);
      print('[LocationDetailPage] Peta dipindahkan dan di-zoom.');

      print('[LocationDetailPage] Menambahkan marker ke peta...');
      await mapController.addMarker(
        memberLocation,
        markerIcon: const MarkerIcon(
          icon: Icon(
            Icons.person_pin,
            color: Colors.red,
            size: 45,
          ),
        ),
      );
      print('Marker berhasil ditambahkan untuk ${widget.member.name}.');
    } else {
      print(
          'WARNING: Latitude atau Longitude adalah null untuk ${widget.member.name}. Marker TIDAK akan ditambahkan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Lokasi'),
        backgroundColor: Colors.white,
        leading: IconButton( // <-- Tambahkan bagian ini
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.member.latitude != null &&
                    widget.member.longitude != null
                ? OSMFlutter(
                    controller: mapController,
                    osmOption: const OSMOption(
                      zoomOption: ZoomOption(
                        initZoom: 15,
                        minZoomLevel: 3,
                        maxZoomLevel: 19,
                        stepZoom: 1.0,
                      ),
                      userTrackingOption: UserTrackingOption(
                        enableTracking: true,
                      ),
                    ),
                    onMapIsReady: (isReady) {
                      if (isReady) {
                        _onMapReady();
                      }
                    },
                  )
                : const Center(
                    child: Text('Lokasi tidak tersedia.'),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.member.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.member.lastUpdated ?? 'N/A',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.social_distance, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      _distanceToMember, // Tampilkan jarak yang sudah dihitung
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.member.location ?? 'Lokasi tidak diketahui',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton:
          (widget.member.latitude != null && widget.member.longitude != null)
              ? FloatingActionButton(
                  onPressed: () async {
                    print('[LocationDetailPage] Tombol Re-center ditekan.');
                    GeoPoint targetPoint = GeoPoint(
                      latitude: widget.member.latitude!,
                      longitude: widget.member.longitude!,
                    );
                    await mapController.moveTo(targetPoint);
                    await mapController.setZoom(zoomLevel: 15.0);
                    print(
                        '[LocationDetailPage] Peta di-recenter ke ${targetPoint.latitude}, ${targetPoint.longitude}.');
                  },
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.my_location, color: Colors.white),
                )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
