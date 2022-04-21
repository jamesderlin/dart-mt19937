// ignore_for_file: public_member_api_docs

// Original implementation copyright (C) 2004, Makoto Matsumoto and Takuji
// Nishimura.  All rights reserved.
//
// Port to Dart copyright (C) 2022 James D. Lin.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//
//   1. Redistributions of source code must retain the above copyright
//      notice, this list of conditions and the following disclaimer.
//
//   2. Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//
//   3. The names of its contributors may not be used to endorse or promote
//      products derived from this software without specific prior written
//      permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER
// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import 'package:fixnum/fixnum.dart';

/// A configurable implementation of the Mersenne Twister.
///
/// This implementation is portable for both the Dart VM and for Dart for the
/// Web.
class MersenneTwisterEngine {
  /// Word size.
  final int w;

  /// Mask for [w] bits.
  late final _wordMask = (Int64.ONE << w) - Int64.ONE;

  /// The maximum value that returnable by [call()].
  late final max = _wordMask.toUnsignedBigInt();

  /// Separation point of a word (the "twist value").
  final int r;

  /// Least-significant `r` bits.
  late final _lowerMask = (Int64.ONE << r) - Int64.ONE;

  /// Most significant `w - r` bits.
  late final _upperMask = _wordMask & ~_lowerMask;

  /// Degree of recurrence.
  final int n;

  /// Recurrence offset.
  final int m;

  /// Coefficients of the rational normal form twist matrix.
  final Int64 a;

  /// Tempering right shift amount.
  final int u;

  /// Tempering mask.
  final Int64 d;

  /// Tempering left shift amount.
  final int s;

  /// Tempering mask.
  final Int64 b;

  /// Tempering left shift amount.
  final int t;

  /// Tempering mask.
  final Int64 c;

  /// Tempering right shift amount.
  final int l;

  /// Initialization multiplier.
  final Int64 f;

  /// Initialization multiplier when seeding from a sequence.
  final Int64 f1;

  /// Initialization multiplier when seeding from a sequence.
  final Int64 f2;

  static const defaultSeed = 5489;

  static const _sequenceInitialSeed = 19650218;

  /// The state vector.
  late final _state = List<Int64>.filled(n, Int64.ZERO);

  // `n + 1` is a sentinel value to indicate that `_state` is not initialized.
  late int _stateIndex = n + 1;

  // Constructs a Mersenne Twister generator.
  MersenneTwisterEngine.custom({
    required this.w,
    required this.r,
    required this.n,
    required this.m,
    required this.a,
    required this.u,
    required this.d,
    required this.s,
    required this.b,
    required this.t,
    required this.c,
    required this.l,
    required this.f,
    required this.f1,
    required this.f2,
  });

  // Constructs an MT19937 generator.
  MersenneTwisterEngine.w32()
      : this.custom(
          w: 32,
          r: 31,
          n: 624,
          m: 397,
          a: Int64(0x9908B0DF),
          u: 11,
          d: Int64(0xFFFFFFFF),
          s: 7,
          b: Int64(0x9D2C5680),
          t: 15,
          c: Int64(0xEFC60000),
          l: 18,
          f: Int64(1812433253),
          f1: Int64(1664525),
          f2: Int64(1566083941),
        );

  // Constructs an MT19937-64 generator.
  MersenneTwisterEngine.w64()
      : this.custom(
          w: 64,
          r: 31,
          n: 312,
          m: 156,
          a: Int64.parseHex('B5026F5AA96619E9'),
          u: 29,
          d: Int64.parseHex('5555555555555555'),
          s: 17,
          b: Int64.parseHex('71D67FFFEDA60000'),
          t: 37,
          c: Int64.parseHex('FFF7EEE000000000'),
          l: 43,
          f: Int64.parseInt('6364136223846793005'),
          f1: Int64.parseInt('3935559000370003845'),
          f2: Int64.parseInt('2862933555777941757'),
        );

  /// Initializes the [MersenneTwisterEngine] from a seed.
  void init(Int64 seed) {
    _state[0] = seed;
    for (_stateIndex = 1; _stateIndex < n; _stateIndex += 1) {
      // See Knuth TAOCP Vol2. 3rd Ed. P.106 for multiplier.
      _state[_stateIndex] = f *
              (_state[_stateIndex - 1] ^
                  (_state[_stateIndex - 1].shiftRightUnsigned(w - 2))) +
          Int64(_stateIndex);
      _state[_stateIndex] &= _wordMask;
    }
  }

  /// Initializes the [MersenneTwisterEngine] from a sequence.
  void initFromSequence(List<Int64> key) {
    init(Int64(_sequenceInitialSeed));

    var i = 1;
    var j = 0;
    for (var k = n > key.length ? n : key.length; k != 0; k -= 1) {
      _state[i] = (_state[i] ^
              ((_state[i - 1] ^ (_state[i - 1].shiftRightUnsigned(w - 2))) *
                  f1)) +
          key[j] +
          Int64(j); // Non-linear.
      _state[i] &= _wordMask;
      i += 1;
      j += 1;
      if (i >= n) {
        _state[0] = _state[n - 1];
        i = 1;
      }
      if (j >= key.length) {
        j = 0;
      }
    }
    for (var k = n - 1; k != 0; k -= 1) {
      _state[i] = (_state[i] ^
              ((_state[i - 1] ^ (_state[i - 1].shiftRightUnsigned(w - 2))) *
                  f2)) -
          Int64(i); // Non-linear.
      _state[i] &= _wordMask;
      i += 1;
      if (i >= n) {
        _state[0] = _state[n - 1];
        i = 1;
      }
    }

    // MSB is 1; assuring non-zero initial array.
    _state[0] = Int64.ONE << (w - 1);
  }

  /// Returns the next random number.
  ///
  /// Note this potentially returns a signed integer that is potentially
  /// negative.  To match values from Mersenne Twister implementations that
  /// operate over unsigned integers, call [UnsignedInt64.toUnsignedBigInt] on
  /// the result.
  Int64 call() {
    // Generate [n] words at one time.
    if (_stateIndex >= n) {
      if (_stateIndex == n + 1) {
        init(Int64(defaultSeed));
      }

      int i;
      for (i = 0; i < n - m; i += 1) {
        var x = (_state[i] & _upperMask) | (_state[i + 1] & _lowerMask);
        _state[i] =
            _state[i + m] ^ (x.shiftRightUnsigned(1)) ^ ((x & Int64.ONE) * a);
      }
      for (; i < n - 1; i += 1) {
        var x = (_state[i] & _upperMask) | (_state[i + 1] & _lowerMask);
        _state[i] = _state[i + m - n] ^
            (x.shiftRightUnsigned(1)) ^
            ((x & Int64.ONE) * a);
      }
      var x = (_state[n - 1] & _upperMask) | (_state[0] & _lowerMask);
      _state[n - 1] =
          _state[m - 1] ^ (x.shiftRightUnsigned(1)) ^ ((x & Int64.ONE) * a);

      _stateIndex = 0;
    }

    var x = _state[_stateIndex];
    _stateIndex += 1;

    // Tempering.
    x ^= (x.shiftRightUnsigned(u)) & d;
    x ^= (x << s) & b;
    x ^= (x << t) & c;
    x ^= x.shiftRightUnsigned(l);
    return x;
  }
}

extension UnsignedInt64 on Int64 {
  /// Returns the unsigned 64-bit integer that corresponds to this [Int64]'s
  /// two's-complement bit representation.
  BigInt toUnsignedBigInt() => BigInt.parse(toStringUnsigned());
}
