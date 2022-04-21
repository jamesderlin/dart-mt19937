@TestOn('vm')

import 'dart:convert';
import 'dart:io' as io;

import 'package:fixnum/fixnum.dart';
import 'package:mt19937/src/mt19937_engine.dart';
import 'package:mt19937/src/mt19937_fixnum.dart' as mtfn;
import 'package:mt19937/src/mt19937_vm.dart';
import 'package:test/test.dart';

/// Returns the absolute path to this `.dart` file.
///
/// Returns `null` if the path could not be determined.
///
/// Note that [io.Platform.script] does not work in tests and also will not
/// work for `import`ed files.
String? _getScriptPath() {
  var filePathRegExp = RegExp(r'(file://.+\.dart)');
  var stackLineIterator = LineSplitter.split(StackTrace.current.toString());
  var match = filePathRegExp.firstMatch(stackLineIterator.first);
  if (match == null) {
    return null;
  }
  return Uri.parse(match.group(1)!).toFilePath();
}

Future<void> main() async {
  var scriptPath = _getScriptPath();
  if (scriptPath != null) {
    io.Directory.current = io.File(scriptPath).parent.parent;
  }

  const sequence = [0x123, 0x234, 0x345, 0x456];
  const sequence64 = [0x12345, 0x23456, 0x34567, 0x45678];

  group('mt19937:', () {
    group('VM implementation:', () {
      test('default seed', () async {
        var mt = MersenneTwister();
        await _compareReferenceOutput(
          () => BigInt.from(mt()),
          'reference/mt19937/default.txt',
          BigInt.parse,
        );
      });

      test('max seed', () async {
        var seed = (1 << 32) - 1;
        var mt = MersenneTwister(seed: seed);
        await _compareReferenceOutput(
          () => BigInt.from(mt()),
          'reference/mt19937/max_seed.txt',
          BigInt.parse,
        );
      });

      test('sequence', () async {
        var mt = MersenneTwister.from(sequence);
        await _compareReferenceOutput(
          () => BigInt.from(mt()),
          'reference/mt19937/sequence.txt',
          BigInt.parse,
        );
      });
    });

    group('fixnum implementation:', () {
      test('default seed', () async {
        var mt = mtfn.MersenneTwister();
        await _compareReferenceOutput(
          () => BigInt.from(mt()),
          'reference/mt19937/default.txt',
          BigInt.parse,
        );
      });

      test('max seed', () async {
        var seed = -1;
        var mt = mtfn.MersenneTwister(seed: seed);
        await _compareReferenceOutput(
          () => BigInt.from(mt()),
          'reference/mt19937/max_seed.txt',
          BigInt.parse,
        );
      });

      test('sequence', () async {
        var mt = mtfn.MersenneTwister.from(sequence);
        await _compareReferenceOutput(
          () => BigInt.from(mt()),
          'reference/mt19937/sequence.txt',
          BigInt.parse,
        );
      });
    });
  });

  group('MersenneTwisterEngine:', () {
    group('mt19937:', () {
      test('default seed', () async {
        var mt = MersenneTwisterEngine.w32();
        await _compareReferenceOutput(
          mt.call,
          'reference/mt19937/default.txt',
          BigInt.parse,
        );
      });

      test('max seed', () async {
        var seed = Int64((1 << 32) - 1);
        var mt = MersenneTwisterEngine.w32()..init(seed.toInt64());
        await _compareReferenceOutput(
          mt.call,
          'reference/mt19937/max_seed.txt',
          BigInt.parse,
        );
      });

      test('sequence', () async {
        var mt = MersenneTwisterEngine.w32()
          ..initFromSequence(
            sequence.map(Int64.new).toList(),
          );
        await _compareReferenceOutput(
          mt.call,
          'reference/mt19937/sequence.txt',
          BigInt.parse,
        );
      });
    });

    group('mt19937-64:', () {
      test('default seed', () async {
        var mt = MersenneTwisterEngine.w64();
        await _compareReferenceOutput(
          mt.call,
          'reference/mt19937-64/default.txt',
          BigInt.parse,
        );
      });

      test('max seed', () async {
        var seed = Int64(-1);
        var mt = MersenneTwisterEngine.w64()..init(seed);
        await _compareReferenceOutput(
          mt.call,
          'reference/mt19937-64/max_seed.txt',
          BigInt.parse,
        );
      });

      test('sequence', () async {
        var mt = MersenneTwisterEngine.w64()
          ..initFromSequence(
            sequence64.map(Int64.new).toList(),
          );
        await _compareReferenceOutput(
          mt.call,
          'reference/mt19937-64/sequence.txt',
          BigInt.parse,
        );
      });
    });
  });
}

Future<void> _compareReferenceOutput<T>(
  T Function() generator,
  String path,
  T Function(String) parser,
) async {
  var expectedValues = io.File(path)
      .openRead()
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .map(parser);

  var i = 0;
  await for (var expectedValue in expectedValues) {
    var actualValue = generator();
    expect(actualValue, expectedValue, reason: 'iteration: $i');
    i += 1;
  }
}
