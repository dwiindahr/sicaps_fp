import 'package:flutter/material.dart';
import 'package:project_caps/widgets/family_member.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:project_caps/utils/distance_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class LocationDetailPage extends StatefulWidget {
  final FamilyMember member;

  const LocationDetailPage({super.key, required this.member});

  @override
  State<LocationDetailPage> createState() => _LocationDetailPageState();
}

class _LocationDetailPageState extends State<LocationDetailPage> {
  late MapController mapController;
  GeoPoint? _currentUserLocation;
  String _distanceToMember = 'Menghitung...';

  FamilyMember? _currentMemberData;
  StreamSubscription<List<Map<String, dynamic>>>? _memberLocationSubscription;

  // Track the previous location of the member marker to remove it
  GeoPoint? _previousMemberMarkerLocation; // <-- NEW: To track old marker position

  @override
  void initState() {
    super.initState();
    _currentMemberData = widget.member;

    print('[LocationDetailPage] Initializing map for ${widget.member.name}');
    print(
        '[LocationDetailPage] Member data - Lat: ${widget.member.latitude}, Lng: ${widget.member.longitude}');

    mapController = MapController(
      initPosition: GeoPoint(
        latitude: _currentMemberData!.latitude ?? 0.0,
        longitude: _currentMemberData!.longitude ?? 0.0,
      ),
    );

    _getCurrentLocationAndCalculateDistance();
    _subscribeToMemberLocationUpdates();
  }

  @override
  void dispose() {
    _memberLocationSubscription?.cancel();
    mapController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _subscribeToMemberLocationUpdates() {
    final supabase = Supabase.instance.client;
    _memberLocationSubscription = supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', widget.member.id)
        .limit(1)
        .order('lastUpdated', ascending: false)
        .listen((data) {
      if (data.isNotEmpty) {
        final updatedData = data[0];
        print('[LocationDetailPage] Realtime update received for ${widget.member.name}: $updatedData');

        setState(() {
          _currentMemberData = FamilyMember.fromJson(updatedData);
        });

        _updateMapWithNewMemberLocation(_currentMemberData!);
        _getCurrentLocationAndCalculateDistance();
      }
    }, onError: (error) {
      print('[LocationDetailPage] Realtime subscription error: $error');
      _showSnackbar('Gagal memperbarui lokasi real-time: ${error.toString()}');
    });
  }

  // --- MODIFIED FUNGSI: Perbarui marker dan tampilan peta ---
  Future<void> _updateMapWithNewMemberLocation(FamilyMember member) async {
    if (member.latitude != null && member.longitude != null) {
      GeoPoint newMemberLocation = GeoPoint(
        latitude: member.latitude!,
        longitude: member.longitude!,
      );
      print('[LocationDetailPage] Updating map to new location: ${newMemberLocation.latitude}, ${newMemberLocation.longitude}');

      // Remove the previous marker if it exists and its location is known
      if (_previousMemberMarkerLocation != null) {
        try {
          await mapController.removeMarker(_previousMemberMarkerLocation!);
          print('Removed previous marker at: ${_previousMemberMarkerLocation!.latitude}, ${_previousMemberMarkerLocation!.longitude}');
        } catch (e) {
          print('Error removing previous marker: $e');
          // This can happen if the marker isn't actually on the map anymore,
          // but we still try to add the new one.
        }
      }

      // Add the new marker
      await mapController.addMarker(
        newMemberLocation,
        markerIcon: const MarkerIcon(
          icon: Icon(
            Icons.person_pin,
            color: Colors.red,
            size: 45,
          ),
        ),
      );
      print('Added new marker at: ${newMemberLocation.latitude}, ${newMemberLocation.longitude}');

      // Update the stored previous marker location
      _previousMemberMarkerLocation = newMemberLocation;
    }
  }
  // ---------------------------------------------------

  Future<void> _getCurrentLocationAndCalculateDistance() async {
    try {
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

      if (_currentMemberData?.latitude != null &&
          _currentMemberData?.longitude != null &&
          _currentUserLocation != null) {
        double distanceInMeters = DistanceUtils.calculateDistance(
          _currentUserLocation!.latitude,
          _currentUserLocation!.longitude,
          _currentMemberData!.latitude!,
          _currentMemberData!.longitude!,
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
    if (_currentMemberData?.latitude != null && _currentMemberData?.longitude != null) {
      GeoPoint memberLocation = GeoPoint(
        latitude: _currentMemberData!.latitude!,
        longitude: _currentMemberData!.longitude!,
      );

      print(
          '[LocationDetailPage] Memindahkan peta ke lokasi anggota: ${memberLocation.latitude}, ${memberLocation.longitude}');
      await mapController.moveTo(memberLocation);
      await mapController.setZoom(zoomLevel: 15.0);
      print('[LocationDetailPage] Peta dipindahkan dan di-zoom.');

      // Add the initial marker and store its location
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
      _previousMemberMarkerLocation = memberLocation; // Store initial marker location
      print('Initial marker added for ${widget.member.name}.');
    } else {
      print(
          'WARNING: Latitude atau Longitude adalah null untuk ${widget.member.name}. Marker TIDAK akan ditambahkan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayMember = _currentMemberData;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Lokasi'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: displayMember?.latitude != null &&
                    displayMember?.longitude != null
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
                        enableTracking: false,
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
                  displayMember?.name ?? 'Nama Tidak Diketahui',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  displayMember?.lastUpdated ?? 'N/A',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.social_distance, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      _distanceToMember,
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
                        displayMember?.location ?? 'Lokasi tidak diketahui',
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
          (displayMember?.latitude != null && displayMember?.longitude != null)
              ? FloatingActionButton(
                  onPressed: () async {
                    print('[LocationDetailPage] Tombol Re-center ditekan.');
                    GeoPoint targetPoint = GeoPoint(
                      latitude: displayMember!.latitude!,
                      longitude: displayMember.longitude!,
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