import 'dart:typed_data';

import 'package:dart_geohash/src/direction.dart';
import 'package:dart_geohash/src/latlong.dart';

/// A class that can convert a geohash String to [Longitude, Latitude] and back.
class GeoHasher {
  const GeoHasher();

  String encodeLatLong(LatLong latLong, {int precision = 12}) =>
      encode(latLong.latitude, latLong.longitude, precision: precision);

  /// Encodes a given Longitude and Latitude into a String geohash
  String encode(double latitude, double longitude, {int precision = 12}) {
    var originalPrecision = precision + 0;
    if (longitude < -180.0 || longitude > 180.0) {
      throw RangeError.range(longitude, -180, 180, 'Longitude');
    }
    if (latitude < -90.0 || latitude > 90.0) {
      throw RangeError.range(latitude, -90, 90, 'Latitude');
    }

    if (precision % 2 == 1) {
      precision = precision + 1;
    }
    if (precision != 1) {
      precision ~/= 2;
    }

    final longitudeBits = _doubleToBits(
      value: longitude,
      lower: -180.0,
      upper: 180.0,
      length: precision * 5,
    );
    final latitudeBits = _doubleToBits(
      value: latitude,
      lower: -90.0,
      upper: 90.0,
      length: precision * 5,
    );

    final ret = <int>[];
    for (var i = 0; i < longitudeBits.length; i++) {
      ret.add(longitudeBits[i]);
      ret.add(latitudeBits[i]);
    }
    final geohashString = _bitsToGeoHash(ret);

    if (originalPrecision == 1) {
      return geohashString.substring(0, 1);
    }
    if (originalPrecision % 2 == 1) {
      return geohashString.substring(0, geohashString.length - 1);
    }
    return geohashString;
  }

  /// Decodes a given String into a List<double> containing Longitude and
  /// Latitude in decimal degrees.
  LatLong decode(String geohash) {
    _validateGeohashString(geohash);

    final bits = _geoHashToBits(geohash);
    final longitudeBits = <int>[];
    final latitudeBits = <int>[];

    for (var i = 0; i < bits.length; i++) {
      if (i % 2 == 0 || i == 0) {
        longitudeBits.add(bits[i]);
      } else {
        latitudeBits.add(bits[i]);
      }
    }

    return LatLong(
      _bitsToDouble(bits: latitudeBits),
      _bitsToDouble(bits: longitudeBits, lower: -180, upper: 180),
    );
  }

  /// Returns a Map<String, String> containing the `Direction` as the key and
  /// the value being the geohash of the neighboring geohash in that direction.
  Map<Direction, String> neighbors(String geohash) {
    _validateGeohashString(geohash);

    return {
      Direction.NORTH: _adjacent(geohash: geohash, direction: 'n'),
      Direction.NORTHEAST: _adjacent(geohash: _adjacent(geohash: geohash, direction: 'n'), direction: 'e'),
      Direction.EAST: _adjacent(geohash: geohash, direction: 'e'),
      Direction.SOUTHEAST: _adjacent(geohash: _adjacent(geohash: geohash, direction: 's'), direction: 'e'),
      Direction.SOUTH: _adjacent(geohash: geohash, direction: 's'),
      Direction.SOUTHWEST: _adjacent(geohash: _adjacent(geohash: geohash, direction: 's'), direction: 'w'),
      Direction.WEST: _adjacent(geohash: geohash, direction: 'w'),
      Direction.NORTHWEST: _adjacent(geohash: _adjacent(geohash: geohash, direction: 'n'), direction: 'w'),
      Direction.CENTRAL: geohash
    };
  }

  static final String _baseSequence = '0123456789bcdefghjkmnpqrstuvwxyz';
  RegExp get _geohashAlphabetRegex => RegExp(r'^[0123456789bcdefghjkmnpqrstuvwxyz]+$');

  /// Map of available characters for a geohash
  static const _base32Map = <String, int>{
    '0': 0,
    '1': 1,
    '2': 2,
    '3': 3,
    '4': 4,
    '5': 5,
    '6': 6,
    '7': 7,
    '8': 8,
    '9': 9,
    'b': 10,
    'c': 11,
    'd': 12,
    'e': 13,
    'f': 14,
    'g': 15,
    'h': 16,
    'j': 17,
    'k': 18,
    'm': 19,
    'n': 20,
    'p': 21,
    'q': 22,
    'r': 23,
    's': 24,
    't': 25,
    'u': 26,
    'v': 27,
    'w': 28,
    'x': 29,
    'y': 30,
    'z': 31,
  };

  /// Reversed Map of available characters for a geohash
  static const _base32MapR = <int, String>{
    0: '0',
    1: '1',
    2: '2',
    3: '3',
    4: '4',
    5: '5',
    6: '6',
    7: '7',
    8: '8',
    9: '9',
    10: 'b',
    11: 'c',
    12: 'd',
    13: 'e',
    14: 'f',
    15: 'g',
    16: 'h',
    17: 'j',
    18: 'k',
    19: 'm',
    20: 'n',
    21: 'p',
    22: 'q',
    23: 'r',
    24: 's',
    25: 't',
    26: 'u',
    27: 'v',
    28: 'w',
    29: 'x',
    30: 'y',
    31: 'z',
  };

  void _validateGeohashString(String geohash) {
    if (geohash.isEmpty) {
      throw ArgumentError.value(geohash, 'geohash');
    }

    if (!_geohashAlphabetRegex.hasMatch(geohash)) {
      throw ArgumentError('Invalid character in Geohash');
    }
  }

  /// Converts a List<int> of bits into a double for Longitude and Latitude
  double _bitsToDouble({
    required List<int> bits,
    double lower = -90.0,
    double middle = 0.0,
    double upper = 90.0,
  }) {
    for (final bit in bits) {
      if (bit == 1) {
        lower = middle;
      } else {
        upper = middle;
      }
      middle = (upper + lower) / 2.0;
    }

    return middle;
  }

  /// Converts a double value Longitude or Latitude to a List<int> of bits
  List<int> _doubleToBits({
    required double value,
    double lower = -90.0,
    double middle = 0.0,
    double upper = 90.0,
    int length = 15,
  }) {
    final ret = <int>[];

    for (var i = 0; i < length; i++) {
      if (value >= middle) {
        lower = middle;
        ret.add(1);
      } else {
        upper = middle;
        ret.add(0);
      }
      middle = (upper + lower) / 2;
    }

    return ret;
  }

  /// Converts a List<int> bits into a String geohash
  String _bitsToGeoHash(List<int> bitValue) {
    final geoHashList = <String>[];

    var remainingBits = List<int>.from(bitValue);
    var subBits = <int>[];
    String subBitsAsString;
    for (var i = 0; i < bitValue.length / 5; i++) {
      subBits = remainingBits.sublist(0, 5);
      remainingBits = remainingBits.sublist(5);

      subBitsAsString = '';
      for (final value in subBits) {
        subBitsAsString += value.toString();
      }

      final value = int.parse(int.parse(subBitsAsString, radix: 2).toRadixString(10));
      geoHashList.add(_base32MapR[value]!);
    }

    return geoHashList.join('');
  }

  /// Converts a String geohash into List<int> bits
  List<int> _geoHashToBits(String geohash) {
    final bitList = <int>[];

    for (final letter in geohash.split('')) {
      if (_base32Map[letter] == null) {
        continue;
      }

      final buffer = Uint8List(5).buffer;
      final bufferData = ByteData.view(buffer);

      bufferData.setUint32(0, _base32Map[letter]!);
      for (final letter in bufferData.getUint32(0).toRadixString(2).padLeft(5, '0').split('')) {
        bitList.add(int.parse(letter));
      }
    }

    return bitList;
  }

  /// Returns a String geohash of the neighbor of the given String in the given
  /// direction.
  String _adjacent({
    required String geohash,
    required String direction,
  }) {
    assert(
      RegExp(r'[nsewNSEW]').hasMatch(direction),
      'Invalid Direction $direction not in NSEW',
    );
    if (geohash == '') {
      throw ArgumentError.value(geohash, 'geohash');
    }

    const neighbor = <String, List>{
      'n': ['p0r21436x8zb9dcf5h7kjnmqesgutwvy', 'bc01fg45238967deuvhjyznpkmstqrwx'],
      's': ['14365h7k9dcfesgujnmqp0r2twvyx8zb', '238967debc01fg45kmstqrwxuvhjyznp'],
      'e': ['bc01fg45238967deuvhjyznpkmstqrwx', 'p0r21436x8zb9dcf5h7kjnmqesgutwvy'],
      'w': ['238967debc01fg45kmstqrwxuvhjyznp', '14365h7k9dcfesgujnmqp0r2twvyx8zb'],
    };
    const border = <String, List<String>>{
      'n': ['prxz', 'bcfguvyz'],
      's': ['028b', '0145hjnp'],
      'e': ['bcfguvyz', 'prxz'],
      'w': ['0145hjnp', '028b'],
    };

    final last = geohash[geohash.length - 1];
    final t = geohash.length % 2;

    var parent = geohash.substring(0, geohash.length - 1);
    if (border[direction]![t].contains(last)) {
      parent = _adjacent(geohash: parent, direction: direction);
    }

    return parent + _baseSequence[neighbor[direction]![t].indexOf(last)];
  }
}
