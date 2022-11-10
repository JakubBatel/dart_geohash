import 'package:dart_geohash/dart_geohash.dart';
import 'package:test/test.dart';

void main() {
  test('Test GeoHasher', () {
    final geohash = const GeoHasher();

    // region Test Decode
    expect(geohash.decode('0'), LatLong(-67.5, -157.5));
    // Standard example with 9 character accuracy
    expect(geohash.decode('9v6kn87zg'), LatLong(30.23710012435913, -97.79499292373657));
    // Arbitrary accuracy. Only up to 12 characters accuracy can be achieved
    expect(geohash.decode('9v6kn87zgbbbbbbbbbb'), LatLong(30.237082819785357, -97.7949811566264));

    // Multiple ones that should throw an Exception
    expect(() => geohash.decode('a'), throwsArgumentError);
    expect(() => geohash.decode('-0'), throwsArgumentError);
    expect(() => geohash.decode(''), throwsArgumentError);
    //endregion

    // region Test Encode
    expect(geohash.encode(-67.5, -157.5, precision: 0), '');
    expect(geohash.encode(30.23710012435913, -97.79499292373657, precision: 1), '9');
    expect(geohash.encode(30.23710012435913, -97.79499292373657, precision: 9), '9v6kn87zg');
    expect(geohash.encode(30.23710012435913, -97.79499292373657, precision: 10), '9v6kn87zgs');
    expect(geohash.encode(30.23710012435913, -97.79499292373657, precision: 20), '9v6kn87zgs0000000000');
    expect(geohash.encode(30.23710012435913, -97.79499292373657), '9v6kn87zgs00');

    // Multiple ones that should throw an Exception
    expect(() => geohash.encode(45, -181), throwsArgumentError);
    expect(() => geohash.encode(95, 45), throwsArgumentError);
    //endregion

    //region Test neighbors
    expect(geohash.neighbors('9v6kn87zg'), {
      Direction.NORTH: '9v6kn8eb5',
      Direction.NORTHEAST: '9v6kn8ebh',
      Direction.EAST: '9v6kn87zu',
      Direction.SOUTHEAST: '9v6kn87zs',
      Direction.SOUTH: '9v6kn87ze',
      Direction.SOUTHWEST: '9v6kn87zd',
      Direction.WEST: '9v6kn87zf',
      Direction.NORTHWEST: '9v6kn8eb4',
      Direction.CENTRAL: '9v6kn87zg',
    });

    // Multiple ones that should throw an Exception
    expect(() => geohash.neighbors('a'), throwsArgumentError);
    expect(() => geohash.neighbors('-0'), throwsArgumentError);
    expect(() => geohash.neighbors(''), throwsArgumentError);
    //endregion
  });

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
