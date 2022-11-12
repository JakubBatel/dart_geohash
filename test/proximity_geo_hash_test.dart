import 'package:dart_geohash/src/proximity_geo_hash.dart';
import 'package:test/test.dart';

void main() {
  group('Test isInsideCircle', () {
    test('in circle check is true', () {
      expect(isInsideCircle(12, 77, 100, 12.1, 77), true);
    });
    test('in circle check is false', () {
      expect(isInsideCircle(12, 77, 1, 23, 87), false);
    });
  });
  group('Centroid tests', () {
    test('get centroid', () {
      final centroid = getCentroid(10, 10, 10, 10);
      expect(centroid[0], 15.0);
      expect(centroid[1], 15.0);
    });
  });
  group('Lat Lng Conversion tests', () {
    test('convert to geohash', () {
      String geohash = convertToGeoHash(1000.0, 1000.0, 12.0, 77.0, 10);
      expect(geohash, "tdnu26hmkq");
    });
  });
  group('create geohash tests', () {
    test('create geohash', () {
      final geoHashes = createProximityGeoHashes(48.858156, 2.294776, 100, 3);
      expect(geoHashes.length, 2);
      expect(geoHashes.containsAll(["u0d", "u09"]), true);
    });
    test('create multiple geohashes', () {
      final geoHashes = createProximityGeoHashes(43.649093099999995, -79.42056769999999, 4000, 5);
      expect(geoHashes.length, 9);
      expect(geoHashes.contains("dpz83"), true);
    });
  });
}
