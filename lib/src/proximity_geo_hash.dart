/// Integration of package https://github.com/anovis/proximity_hash

import 'dart:math';
import 'dart:collection';

import 'package:dart_geohash/src/geo_hasher.dart';
import 'package:meta/meta.dart';

const _EARTH_RADIUS = 6371000;

@visibleForTesting
List<double> getCentroid(double latitude, double longitude, double height, double width) {
  final centeredY = latitude + (height / 2);
  final centeredX = longitude + (width / 2);

  return [centeredX, centeredY];
}

/// Check to see if a point is contained in a circle
@visibleForTesting
bool isInsideCircle(double latitude, double longitude, double radius,
    [double centerLat = 0.0, double centerLon = 0.0]) {
  return pow(longitude - centerLon, 2) + pow(latitude - centerLat, 2) <= pow(radius, 2);
}

/// Convert location point to geohash taking into account Earth curvature
@visibleForTesting
String convertToGeoHash(double y, double x, double latitude, double longitude, int precision) {
  final latDiff = (y / _EARTH_RADIUS) * (180 / pi);
  final lonDiff = (x / _EARTH_RADIUS) * (180 / pi) / cos(latitude * pi / 180);

  return const GeoHasher().encode(latitude + latDiff, longitude + lonDiff, precision: precision);
}

@visibleForTesting
double getWidthForPrecision(int p) =>
    const [5009400.0, 1252300.0, 156500.0, 39100.0, 4900.0, 1200.0, 152.9, 38.2, 4.8, 1.2, 0.149, 0.0370][p - 1] / 2;

@visibleForTesting
double getHeightForPrecision(int p) =>
    const [4992600.0, 624100.0, 156000.0, 19500.0, 4900.0, 609.4, 152.4, 19.0, 4.8, 0.595, 0.149, 0.0199][p - 1] / 2;

// Generate geohashes based on radius in meters
Set<String> createProximityGeoHashes(double latitude, double longitude, double radius, int precision) {
  if (precision > 12 || precision < 0) {
    throw ArgumentError('Invalid precision $precision (0 < precision <= 12 does not hold).');
  }

  final geoHashes = HashSet<String>();

  final width = getWidthForPrecision(precision);
  final height = getHeightForPrecision(precision);

  final latMoves = (radius / height).ceil();
  final lonMoves = (radius / width).ceil();

  for (var y = 0; y < latMoves; y++) {
    final tempLat = height * y;
    for (var x = 0; x < lonMoves; x++) {
      final tempLong = width * x;

      if (isInsideCircle(tempLat, tempLong, radius)) {
        final centerList = getCentroid(tempLat, tempLong, height, width);
        final centerX = centerList[0];
        final centerY = centerList[1];

        geoHashes.addAll([
          convertToGeoHash(centerY, centerX, latitude, longitude, precision),
          convertToGeoHash(-centerY, centerX, latitude, longitude, precision),
          convertToGeoHash(centerY, -centerX, latitude, longitude, precision),
          convertToGeoHash(-centerY, -centerX, latitude, longitude, precision),
        ]);
      }
    }
  }
  return geoHashes;
}
