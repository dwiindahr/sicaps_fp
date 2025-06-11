class FamilyMember {
  final String name;
  final String? location; // e.g., "Al Haram, Makkah 24231, Arab Saudi"
  final String? distance; // e.g., "Berjarak 100km"
  final String? lastUpdated; // e.g., "20j yang lalu"
  final double? latitude;
  final double? longitude;

  FamilyMember({
    required this.name,
    this.location,
    this.distance,
    this.lastUpdated,
    this.latitude,
    this.longitude,
  });
}