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

/// An implementation of Mersenne Twister 19937-64.
class MersenneTwister64 {
  /// Word size.
  static const w = 64;

  /// Mask for [w] bits.
  static final _wordMask = Int64(-1);

  /// The maximum value returnable by [call()].
  static final max = _wordMask.toUnsignedBigInt();

  /// Separation point of a word (the "twist value").
  static const r = 31;

  /// Least-significant `r` bits.
  static final _lowerMask = (Int64.ONE << r) - Int64.ONE;

  /// Most significant `w - r` bits.
  static final _upperMask = _wordMask & ~_lowerMask;

  /// Degree of recurrence.
  static const n = 312;

  /// Recurrence offset.
  static const m = 156;

  /// Coefficients of the rational normal form twist matrix.
  static final a = Int64.parseHex('B5026F5AA96619E9');

  /// Tempering right shift amount.
  static const u = 29;

  /// Tempering mask.
  static final d = Int64.parseHex('5555555555555555');

  /// Tempering left shift amount.
  static const s = 17;

  /// Tempering mask.
  static final b = Int64.parseHex('71D67FFFEDA60000');

  /// Tempering left shift amount.
  static const t = 37;

  /// Tempering mask.
  static final c = Int64.parseHex('FFF7EEE000000000');

  /// Tempering right shift amount.
  static const l = 43;

  /// Initialization multiplier.
  static final f = Int64.parseInt('6364136223846793005');

  /// Initialization multiplier when seeding from a sequence.
  static final f1 = Int64.parseInt('3935559000370003845');

  /// Initialization multiplier when seeding from a sequence.
  static final f2 = Int64.parseInt('2862933555777941757');

  static const defaultSeed = 5489;

  static const _sequenceInitialSeed = 19650218;

  /// The state vector.
  final _state = List<Int64>.filled(n, Int64.ZERO);
  int _stateIndex = n;

  /// Initializes the random number generator from an optional seed.
  MersenneTwister64({Int64? seed}) {
    _state[0] = (seed ?? Int64(defaultSeed)) & _wordMask;
    for (_stateIndex = 1; _stateIndex < n; _stateIndex += 1) {
      // See Knuth TAOCP Vol2. 3rd Ed. P.106 for multiplier.
      _state[_stateIndex] = f *
              (_state[_stateIndex - 1] ^
                  (_state[_stateIndex - 1] >>> (w - 2))) +
          _stateIndex;
      _state[_stateIndex] &= _wordMask;
    }
  }

  /// Initializes the random number generator from a sequence.
  factory MersenneTwister64.from(List<Int64> key) {
    var mt = MersenneTwister64(seed: Int64(_sequenceInitialSeed));
    var i = 1;
    var j = 0;
    for (var k = n > key.length ? n : key.length; k != 0; k -= 1) {
      mt._state[i] = (mt._state[i] ^
              ((mt._state[i - 1] ^ (mt._state[i - 1] >>> (w - 2))) * f1)) +
          key[j] +
          j; // Non-linear.
      mt._state[i] &= _wordMask;
      i += 1;
      j += 1;
      if (i >= n) {
        mt._state[0] = mt._state[n - 1];
        i = 1;
      }
      if (j >= key.length) {
        j = 0;
      }
    }
    for (var k = n - 1; k != 0; k -= 1) {
      mt._state[i] = (mt._state[i] ^
              ((mt._state[i - 1] ^ (mt._state[i - 1] >>> (w - 2))) * f2)) -
          i; // Non-linear.
      mt._state[i] &= _wordMask;
      i += 1;
      if (i >= n) {
        mt._state[0] = mt._state[n - 1];
        i = 1;
      }
    }

    // MSB is 1; assuring non-zero initial array.
    mt._state[0] = Int64.ONE << (w - 1);
    return mt;
  }

  /// Returns the next random number in the range [0, max].
  ///
  /// This returns a [BigInt] instead of an [Int64] to guarantee that all
  /// results will be non-negative.
  ///
  /// Callers that don't care about the sign of the result and care only about
  /// the random bits can call [nextInt64] instead, which is faster.
  BigInt call() => nextInt64().toUnsignedBigInt();

  /// Returns the next random number.
  ///
  /// Note this potentially returns a signed integer that is potentially
  /// negative.  To match values from Mersenne Twister implementations that
  /// operate over unsigned integers, use [call()] instead.
  Int64 nextInt64() {
    // Generate [n] words at one time.
    if (_stateIndex == n) {
      int i;
      for (i = 0; i < n - m; i += 1) {
        var x = (_state[i] & _upperMask) | (_state[i + 1] & _lowerMask);
        _state[i] = _state[i + m] ^ (x >>> 1) ^ ((x & 0x1) * a);
      }
      for (; i < n - 1; i += 1) {
        var x = (_state[i] & _upperMask) | (_state[i + 1] & _lowerMask);
        _state[i] = _state[i + m - n] ^ (x >>> 1) ^ ((x & 0x1) * a);
      }
      var x = (_state[n - 1] & _upperMask) | (_state[0] & _lowerMask);
      _state[n - 1] = _state[m - 1] ^ (x >>> 1) ^ ((x & 0x1) * a);

      _stateIndex = 0;
    }

    var x = _state[_stateIndex];
    _stateIndex += 1;

    // Tempering.
    x ^= (x >>> u) & d;
    x ^= (x << s) & b;
    x ^= (x << t) & c;
    x ^= x >>> l;
    return x;
  }
}

extension on Int64 {
  /// Returns the unsigned 64-bit integer that corresponds to this [Int64]'s
  /// two's-complement bit representation.
  BigInt toUnsignedBigInt() {
    // Multiple implementations were considered:
    //
    // 1. `BigInt.parse(toStringUnsigned())`.
    // 2. Building a `BigInt` from each element of `toBytes()`.
    //
    // The current implementation empirically seems ~4x faster than approach
    // #1 and ~2x faster than approach #2 when compiled to native.
    var lower = this & Int64(0xFFFFFFFF);
    var upper = this >>> 32;
    return BigInt.from(lower.toInt()) | (BigInt.from(upper.toInt()) << 32);
  }
}

extension on Int64 {
  Int64 operator >>>(int n) => shiftRightUnsigned(n);
}
