import 'package:dart_geohash/dart_geo_hash.dart';
import 'package:test/test.dart';

void main() {
  test('Test GeoHasher', () {
    final geoHasher = const GeoHasher();

    // region Test Decode
    expect(geoHasher.decode('0'), LatLong(-67.5, -157.5));
    // Standard example with 9 character accuracy
    expect(geoHasher.decode('9v6kn87zg'), LatLong(30.23710012435913, -97.79499292373657));
    // Arbitrary accuracy. Only up to 12 characters accuracy can be achieved
    expect(geoHasher.decode('9v6kn87zgbbbbbbbbbb'), LatLong(30.237082819785357, -97.7949811566264));

    // Multiple ones that should throw an Exception
    expect(() => geoHasher.decode('a'), throwsArgumentError);
    expect(() => geoHasher.decode('-0'), throwsArgumentError);
    expect(() => geoHasher.decode(''), throwsArgumentError);
    //endregion

    // region Test Encode
    expect(geoHasher.encode(-67.5, -157.5, precision: 0), '');
    expect(geoHasher.encode(30.23710012435913, -97.79499292373657, precision: 1), '9');
    expect(geoHasher.encode(30.23710012435913, -97.79499292373657, precision: 9), '9v6kn87zg');
    expect(geoHasher.encode(30.23710012435913, -97.79499292373657, precision: 10), '9v6kn87zgs');
    expect(geoHasher.encode(30.23710012435913, -97.79499292373657, precision: 20), '9v6kn87zgs0000000000');
    expect(geoHasher.encode(30.23710012435913, -97.79499292373657), '9v6kn87zgs00');

    // Multiple ones that should throw an Exception
    expect(() => geoHasher.encode(45, -181), throwsArgumentError);
    expect(() => geoHasher.encode(95, 45), throwsArgumentError);
    //endregion

    //region Test neighbors
    expect(geoHasher.neighbors('9v6kn87zg'), {
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
    expect(() => geoHasher.neighbors('a'), throwsArgumentError);
    expect(() => geoHasher.neighbors('-0'), throwsArgumentError);
    expect(() => geoHasher.neighbors(''), throwsArgumentError);
    //endregion
  });

  
}
