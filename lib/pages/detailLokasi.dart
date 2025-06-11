import 'package:flutter/material.dart';
import 'package:project_caps/widgets/family_member.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart'; // Import flutter_osm_plugin

class LocationDetailPage extends StatefulWidget {
  final FamilyMember member;

  const LocationDetailPage({super.key, required this.member});

  @override
  State<LocationDetailPage> createState() => _LocationDetailPageState();
}

class _LocationDetailPageState extends State<LocationDetailPage> {
  late MapController mapController; // Controller untuk flutter_osm_plugin

  @override
  void initState() {
    super.initState();

    // 1. Inisialisasi mapController terlebih dahulu
    // Posisikan peta ke lokasi anggota keluarga jika tersedia, jika tidak, default ke (0,0)
    mapController = MapController(
      initPosition: GeoPoint(
        latitude: widget.member.latitude ?? 0.0,
        longitude: widget.member.longitude ?? 0.0,
      ),
      // areaLimit: BoundingBox(...)
    );

    // 2. Tambahkan marker setelah peta diinisialisasi
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.member.latitude != null && widget.member.longitude != null) {
        // --- Perbaikan di sini: Menggunakan goToLocation sebagai pengganti setCenter ---
        await mapController.goToLocation(
          GeoPoint(latitude: widget.member.latitude!, longitude: widget.member.longitude!),
        );
        await mapController.setZoom(zoomLevel: 15.0); // Set zoom level
        // -------------------------------------------------------------------------

        // Tambahkan marker ke peta
        await mapController.addMarker(
          GeoPoint(latitude: widget.member.latitude!, longitude: widget.member.longitude!),
          markerIcon: const MarkerIcon(
            icon: Icon(
              Icons.location_on,
              color: Colors.red,
              size: 40,
            ),
          ),
        );
        print('Marker added for ${widget.member.name}.');
      } else {
        print('WARNING: Latitude or Longitude is null for ${widget.member.name}. Marker will not be added.');
      }
    });
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Lokasi'),
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.member.latitude != null && widget.member.longitude != null
                ? OSMFlutter(
                    controller: mapController,
                    osmOption: OSMOption(
                      zoomOption: const ZoomOption(
                        initZoom: 15,
                        minZoomLevel: 3,
                        maxZoomLevel: 19,
                        stepZoom: 1.0,
                      ),
                      // ... opsi lain
                    ),
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
                  '${widget.member.lastUpdated ?? 'N/A'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.social_distance, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      widget.member.distance ?? 'N/A',
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
    );
  }
}