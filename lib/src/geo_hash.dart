import 'package:dart_geohash/src/direction.dart';
import 'package:dart_geohash/src/geo_hasher.dart';
import 'package:dart_geohash/src/latlong.dart';

/// A containing class for a geohash
class GeoHash {
  final String geohash;

  /// Constructor given a String geohash
  const GeoHash(this.geohash);

  /// Constructor given LatLong object
  factory GeoHash.fromLatLong(LatLong latLong, {int precision = 9}) =>
      GeoHash.fromDecimalDegrees(latLong.latitude, latLong.longitude, precision: precision);

  /// Constructor given Latitude and Longitude
  factory GeoHash.fromDecimalDegrees(
    double latitude,
    double longitude, {
    int precision = 9,
  }) =>
      GeoHash(const GeoHasher().encode(longitude, latitude, precision: precision));

  /// Returns the double longitude with an optional decimal accuracy
  double longitude({int decimalAccuracy = 20}) {
    if (decimalAccuracy > 20) {
      throw RangeError('Decimal Accuracy must be between 0..20');
    }
    return double.parse(_longitude.toStringAsFixed(decimalAccuracy));
  }

  /// Returns the double latitude with an optional decimal accuracy
  double latitude({int decimalAccuracy = 20}) {
    if (decimalAccuracy > 20 || decimalAccuracy < 0) {
      throw RangeError('Decimal Accuracy must be between 0..20');
    }
    return double.parse(_latitude.toStringAsFixed(decimalAccuracy));
  }

  /// Returns a Map<String, String> containing the `Direction` as the key and
  /// the value being the geohash of the neighboring geohash in that direction.
  Map<Direction, String> get neighborsByDirection => const GeoHasher().neighbors(geohash);
  Set<String> get neighbors => neighborsByDirection.values.toSet();

  /// Returns true if the given geohash contains this one within it.
  bool isInside(String geohash) {
    if (geohash.length > geohash.length) {
      return false;
    }

    return geohash.substring(0, geohash.length) == geohash;
  }

  /// Returns true if the given geohash is contained within this geohash
  bool contains(String geohash) {
    if (geohash.length < geohash.length) {
      return false;
    }

    return geohash.substring(0, geohash.length) == geohash;
  }

  /// Returns a new Geohash for the parent of this one.
  GeoHash get parent => GeoHash(geohash.substring(0, geohash.length - 1));

  double get _latitude => const GeoHasher().decode(geohash).latitude;
  double get _longitude => const GeoHasher().decode(geohash).longitude;
}
