# mt19937

An implementation of the [Mersenne Twister 19937] pseudo-random number
generator.

Provides MT19937, MT19937-64, and configurable implementations for both native
and web platforms.

## Usage

```dart
import 'package:fixnum/fixnum.dart';
import 'package:mt19937/mt19937.dart';

void main() {
  // Provides a raw generator.
  var mt = MersenneTwister();
  print(List<int>.generate(10, (_) => mt()));

  // Also provides a [Random] interface.
  var random = RandomMt19937();
  print(List<int>.generate(10, (_) => random.nextInt(100)));
  print(List<double>.generate(10, (_) => random.nextDouble()));

  // MT19937-64 is implemented with a slightly different interface.
  var seed = DateTime.now().millisecondsSinceEpoch;
  var mt64 = MersenneTwisterEngine.w64()..init(Int64(seed));
  print(List<BigInt>.generate(10, (_) => mt64()));
}
```

## A note on MT19937-64

Why is the MT19937-64 implementation different?  The MT19937-64 implementation
is provided as part of a *general* [`MersenneTwisterEngine`] implementation.
From a different perspective, an equivalent question is: why is the 32-bit
MT19937 implementation different?

This package provides a specialized implementation for MT19937 because
* It's able to provide a portable `int`-based interface, which is more
  convenient to use.
* It's able to provide an `int`-based *implementation* for Dart VM platforms,
  which is *significantly* faster.

In contrast, those factors would not apply to a specialized MT19937-64
implementation:
* Dart does not have a 64-bit unsigned integer type, whether as a built-in type
  from `dart:core` or as a type from [`package:fixnum`].  To return non-negative
  values that use the full 64-bit range, the MT19937-64 implementation therefore
  must return `BigInt`s.
* Returning `BigInt`s negates all performance benefits from an `int`-based
  implementation.

Providing and maintaining specialized `int` (for Dart VM platforms) and `Int64`
(for Dart for the Web) implementations of MT19937-64 therefore does not seem to
be worthwhile.

[Mersenne Twister 19937]: https://en.wikipedia.org/wiki/Mersenne_twister
[`package:fixnum`]: https://pub.dev/packages/fixnum
