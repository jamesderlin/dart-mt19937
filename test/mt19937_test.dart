/// mt19937 tests.
///
/// Tests may be run in the VM or in a web browser.
///
/// Test on web browsers with: `dart test --platform={chrome,firefox}`

import 'package:fixnum/fixnum.dart';
import 'package:mt19937/src/mt19937_engine.dart';
import 'package:mt19937/src/mt19937_fixnum.dart' as mtfn;
import 'package:mt19937/src/mt19937_vm.dart';
import 'package:test/test.dart';

import 'reference.resources.dart' as resources;

Future<void> main() async {
  const sequence = [0x123, 0x234, 0x345, 0x456];
  const sequence64 = [0x12345, 0x23456, 0x34567, 0x45678];

  group('mt19937:', () {
    group(
      'VM implementation:',
      () {
        test('default seed', () {
          var mt = MersenneTwister();
          _compareReferenceOutput(
            () => BigInt.from(mt()),
            resources.defaultSeedResults,
            BigInt.parse,
          );
        });

        test('max seed', () {
          var seed = (1 << 32) - 1;
          var mt = MersenneTwister(seed: seed);
          _compareReferenceOutput(
            () => BigInt.from(mt()),
            resources.maxSeedResults,
            BigInt.parse,
          );
        });

        test('sequence', () {
          var mt = MersenneTwister.from(sequence);
          _compareReferenceOutput(
            () => BigInt.from(mt()),
            resources.sequenceResults,
            BigInt.parse,
          );
        });
      },
      testOn: 'vm',
    );

    group('fixnum implementation:', () {
      test('default seed', () {
        var mt = mtfn.MersenneTwister();
        _compareReferenceOutput(
          () => BigInt.from(mt()),
          resources.defaultSeedResults,
          BigInt.parse,
        );
      });

      test('max seed', () {
        var seed = -1;
        var mt = mtfn.MersenneTwister(seed: seed);
        _compareReferenceOutput(
          () => BigInt.from(mt()),
          resources.maxSeedResults,
          BigInt.parse,
        );
      });

      test('sequence', () {
        var mt = mtfn.MersenneTwister.from(sequence);
        _compareReferenceOutput(
          () => BigInt.from(mt()),
          resources.sequenceResults,
          BigInt.parse,
        );
      });
    });
  });

  group('MersenneTwisterEngine:', () {
    group('mt19937:', () {
      test('default seed', () {
        var mt = MersenneTwisterEngine.w32();
        _compareReferenceOutput(
          mt.call,
          resources.defaultSeedResults,
          BigInt.parse,
        );
      });

      test('max seed', () {
        var seed = Int64((1 << 32) - 1);
        var mt = MersenneTwisterEngine.w32()..init(seed.toInt64());
        _compareReferenceOutput(
          mt.call,
          resources.maxSeedResults,
          BigInt.parse,
        );
      });

      test('sequence', () {
        var mt = MersenneTwisterEngine.w32()
          ..initFromSequence(
            sequence.map(Int64.new).toList(),
          );
        _compareReferenceOutput(
          mt.call,
          resources.sequenceResults,
          BigInt.parse,
        );
      });
    });

    group('mt19937-64:', () {
      test('default seed', () {
        var mt = MersenneTwisterEngine.w64();
        _compareReferenceOutput(
          mt.call,
          resources.defaultSeed64Results,
          BigInt.parse,
        );
      });

      test('max seed', () {
        var seed = Int64(-1);
        var mt = MersenneTwisterEngine.w64()..init(seed);
        _compareReferenceOutput(
          mt.call,
          resources.maxSeed64Results,
          BigInt.parse,
        );
      });

      test('sequence', () {
        var mt = MersenneTwisterEngine.w64()
          ..initFromSequence(
            sequence64.map(Int64.new).toList(),
          );
        _compareReferenceOutput(
          mt.call,
          resources.sequence64Results,
          BigInt.parse,
        );
      });
    });
  });
}

void _compareReferenceOutput<T>(
  T Function() generator,
  List<String> expectedValues,
  T Function(String) parser,
) {
  var i = 0;
  for (var expectedValue in expectedValues.map(parser)) {
    var actualValue = generator();
    expect(actualValue, expectedValue, reason: 'iteration: $i');
    i += 1;
  }
}
