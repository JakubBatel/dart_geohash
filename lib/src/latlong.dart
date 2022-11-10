class LatLong {
  final double latitude;
  final double longitude;

  const LatLong(this.latitude, this.longitude);

  bool operator ==(Object other) => other is LatLong && latitude == other.latitude && longitude == other.longitude;

  int get hashCode => Object.hash(latitude, longitude);
}
