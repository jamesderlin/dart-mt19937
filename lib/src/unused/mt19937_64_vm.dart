// ignore_for_file: public_member_api_docs
// ignore_for_file: avoid_js_rounded_ints

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

import 'dart:typed_data';

/// An implementation of Mersenne Twister 19937-64.
class MersenneTwister64 {
  /// Word size.
  static const w = 64;

  /// Mask for [w] bits.
  static const _wordMask = -1;

  /// The maximum value returnable by [call()].
  static final max = _wordMask.toUnsignedBigInt();

  /// Separation point of a word (the "twist value").
  static const r = 31;

  /// Least-significant `r` bits.
  static const _lowerMask = (1 << r) - 1;

  /// Most significant `w - r` bits.
  static const _upperMask = _wordMask & ~_lowerMask;

  /// Degree of recurrence.
  static const n = 312;

  /// Recurrence offset.
  static const m = 156;

  /// Coefficients of the rational normal form twist matrix.
  static const a = 0xB5026F5AA96619E9;

  /// Tempering right shift amount.
  static const u = 29;

  /// Tempering mask.
  static const d = 0x5555555555555555;

  /// Tempering left shift amount.
  static const s = 17;

  /// Tempering mask.
  static const b = 0x71D67FFFEDA60000;

  /// Tempering left shift amount.
  static const t = 37;

  /// Tempering mask.
  static const c = 0xFFF7EEE000000000;

  /// Tempering right shift amount.
  static const l = 43;

  /// Initialization multiplier.
  static const f = 6364136223846793005;

  /// Initialization multiplier when seeding from a sequence.
  static const f1 = 3935559000370003845;

  /// Initialization multiplier when seeding from a sequence.
  static const f2 = 2862933555777941757;

  static const defaultSeed = 5489;

  static const _sequenceInitialSeed = 19650218;

  /// The state vector.
  final _state = Uint64List(n);
  int _stateIndex = n;

  /// Initializes the random number generator from an optional seed.
  MersenneTwister64({int? seed}) {
    _state[0] = (seed ?? defaultSeed) & _wordMask;
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
  factory MersenneTwister64.from(List<int> key) {
    var mt = MersenneTwister64(seed: _sequenceInitialSeed);
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
    mt._state[0] = 1 << (w - 1);
    return mt;
  }

  /// Returns the next random number in the range [0, max].
  ///
  /// This returns a [BigInt] instead of an [int] to guarantee that all
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
  int nextInt64() {
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

extension on int {
  /// Returns the [BigInt] for the 64-bit unsigned integer corresponding to this
  /// [int]'s bit representation.
  BigInt toUnsignedBigInt() {
    var bigInt = BigInt.from(this);
    return (bigInt.isNegative) ? ((BigInt.one << 64) + bigInt) : bigInt;
  }
}
