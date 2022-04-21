import 'dart:math';

import '../mt19937.dart';

/// An implementation of [Random] that is backed by a lower-level random number
/// generator.
class WrappedRandom implements Random {
  /// The raw random number generator.
  ///
  /// Expected to return a number in the range \[0, exclusiveMax).
  final int Function() generator;

  /// The exclusive maximum value returnable by [generator].
  final int exclusiveMax;

  /// Constructor.
  WrappedRandom(this.generator, this.exclusiveMax);

  @override
  int nextInt(int max) {
    if (!(max > 0 && max <= exclusiveMax)) {
      throw RangeError(
        'max must be in range 0 < max ≤ $exclusiveMax, was $max',
      );
    }

    // Avoid bias if [max] does not evenly divide [exclusiveMax].
    //
    // Rescale [max] to be the largest multiple of [max] <= [exclusiveMax] and
    // reject all values outside of the rescaled range.
    var scale = exclusiveMax ~/ max;
    assert(scale > 0);

    max *= scale;
    while (true) {
      var result = generator();
      if (result < max) {
        return result ~/ scale;
      }
    }
  }

  @override
  double nextDouble() => nextInt(exclusiveMax) / exclusiveMax;

  @override
  bool nextBool() => nextInt(2) == 0;
}

/// An implementation of [Random] that is backed by a lower-level random number
/// generator that returns [BigInt]s.
class WrappedRandomBigInt implements Random {
  /// The raw random number generator.
  ///
  /// Expected to return a number in the range \[0, exclusiveMax).
  final BigInt Function() generator;

  /// The exclusive maximum value returnable by [generator].
  final BigInt exclusiveMax;

  /// Constructor.
  WrappedRandomBigInt(this.generator, this.exclusiveMax);

  /// TOOD
  BigInt nextBigInt(BigInt max) {
    if (!(max > BigInt.zero && max <= exclusiveMax)) {
      throw RangeError(
        'max must be in range 0 < max ≤ $exclusiveMax, was $max',
      );
    }

    // Avoid bias if [max] does not evenly divide [exclusiveMax].
    //
    // Rescale [max] to be the largest multiple of [max] <= [exclusiveMax] and
    // reject all values outside of the rescaled range.
    var scale = exclusiveMax ~/ max;
    assert(scale > BigInt.zero);

    max *= scale;
    while (true) {
      var result = generator();
      if (result < max) {
        return result ~/ scale;
      }
    }
  }

  @override
  int nextInt(int max) => nextBigInt(BigInt.from(max)).toInt();

  @override
  double nextDouble() => nextBigInt(exclusiveMax) / exclusiveMax;

  @override
  bool nextBool() => nextBigInt(BigInt.two) == BigInt.zero;
}

/// A [Random] implementation that uses [MersenneTwister] (MT19937) as a
/// source for pseudo-random numbers.
class RandomMt19937 extends WrappedRandom {
  /// Constructs a [RandomMt19937] with an optional seed.
  RandomMt19937({int? seed})
      : super(MersenneTwister(seed: seed).call, MersenneTwister.max + 1);
}
