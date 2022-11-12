import 'package:dart_geohash/src/direction.dart';
import 'package:dart_geohash/src/geo_hash.dart';
import 'package:test/test.dart';

void main() {
  test('Test GeoHash', () {
    final geohash = GeoHash('9v6kn87zg');

    // Decimal accuracy, when not specified, is related to length of Geohash
    expect(geohash.longitude(), -97.79499292373657);
    // Decimals are rounded to nearest number keep that in mind when truncating
    expect(geohash.longitude(decimalAccuracy: 3), -97.795);

    // Decimal accuracy, when not specified, is related to length of Geohash
    expect(geohash.latitude(), 30.23710012435913);
    // Decimals are rounded to nearest number keep that in mind when truncating
    expect(geohash.latitude(decimalAccuracy: 3), 30.237);

    final neighborsByDirection = geohash.neighborsByDirection;

    //region Test neighbor
    expect(neighborsByDirection[Direction.NORTH], '9v6kn8eb5');
    expect(neighborsByDirection[Direction.CENTRAL], '9v6kn87zg');

    final neighbors = geohash.neighbors;
    // Neighbor Bool test. Requires same accuracy of geohash
    expect(neighbors.contains('9v6kn8eb5'), true);
    expect(neighbors.contains('9v6kn8'), false);
    expect(neighbors.contains(''), false);
    expect(neighbors.contains('9v6kn87zg'), true);
  });
}
