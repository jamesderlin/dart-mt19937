// Test with `dart test --platform={chrome,firefox}`

@TestOn('browser')

import 'package:fixnum/fixnum.dart';
import 'package:mt19937/mt19937.dart';
import 'package:test/test.dart';

void main() {
  const sequence = [0x123, 0x234, 0x345, 0x456];
  const sequence64 = [0x12345, 0x23456, 0x34567, 0x45678];

  group('mt19937:', () {
    test('default seed', () {
      var mt = MersenneTwister();
      for (var i = 1; i < 10000; i += 1) {
        mt();
      }
      expect(mt(), 4123659995);
    });
    test('max seed', () {
      var mt = MersenneTwister(seed: 0xFFFFFFFF);
      for (var i = 1; i < 10000; i += 1) {
        mt();
      }
      expect(mt(), 1117955853);
    });
    test('sequence', () {
      var mt = MersenneTwister.from(sequence);
      for (var i = 1; i < 10000; i += 1) {
        mt();
      }
      expect(mt(), 3908684712);
    });
  });

  group('mt19937-64:', () {
    test('default seed', () {
      var mt = MersenneTwisterEngine.w64();
      for (var i = 1; i < 10000; i += 1) {
        mt();
      }
      expect(mt(), BigInt.parse('9981545732273789042'));
    });
    test('max seed', () {
      var mt = MersenneTwisterEngine.w64()..init(Int64(-1));
      for (var i = 1; i < 10000; i += 1) {
        mt();
      }
      expect(mt(), BigInt.parse('898929940823410802'));
    });
    test('sequence', () {
      var mt = MersenneTwisterEngine.w64()
        ..initFromSequence(sequence64.map(Int64.new).toList());
      for (var i = 1; i < 10000; i += 1) {
        mt();
      }
      expect(mt(), BigInt.parse('14002232017267485025'));
    });
  });
}
