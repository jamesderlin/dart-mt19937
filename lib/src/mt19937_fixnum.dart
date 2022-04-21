// ignore_for_file: public_member_api_docs

// Original implementation copyright (C) 1997 - 2002, Makoto Matsumoto and
// Takuji Nishimura.  All rights reserved.
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

/// An implementation of Mersenne Twister 19937.
///
/// This implementation is portable for both the Dart VM and for Dart for the
/// Web.
class MersenneTwister {
  /// Word size.
  static const w = 32;

  /// Mask for [w] bits.
  static final _wordMask = Int32(-1);

  /// The maximum value that returnable by [call()].
  static final max = _wordMask;

  /// Separation point of a word (the "twist value").
  static const r = 31;

  /// Least-significant `r` bits.
  static final _lowerMask = (Int32.ONE << r) - Int32.ONE as Int32;

  /// Most significant `w - r` bits.
  static final _upperMask = _wordMask & ~_lowerMask;

  /// Degree of recurrence.
  static const n = 624;

  /// Recurrence offset.
  static const m = 397;

  /// Coefficients of the rational normal form twist matrix.
  static final a = Int32.parseHex('9908B0DF');

  /// Tempering right shift amount.
  static const u = 11;

  /// Tempering mask.
  static final d = Int32.parseHex('FFFFFFFF');

  /// Tempering left shift amount.
  static const s = 7;

  /// Tempering mask.
  static final b = Int32.parseHex('9D2C5680');

  /// Tempering left shift amount.
  static const t = 15;

  /// Tempering mask.
  static final c = Int32.parseHex('EFC60000');

  /// Tempering right shift amount.
  static const l = 18;

  /// Initialization multiplier.
  static final f = Int32(1812433253);

  /// Initialization multiplier when seeding from a sequence.
  static final f1 = Int32(1664525);

  /// Initialization multiplier when seeding from a sequence.
  static final f2 = Int32(1566083941);

  static const defaultSeed = 5489;

  static const _sequenceInitialSeed = 19650218;

  /// The state vector.
  final _state = List<Int32>.filled(n, Int32.ZERO);
  int _stateIndex = n;

  /// Initializes the random number generator from an optional seed.
  MersenneTwister({Int32? seed}) {
    _state[0] = (seed ?? Int32(defaultSeed)) & _wordMask;
    for (_stateIndex = 1; _stateIndex < n; _stateIndex += 1) {
      // See Knuth TAOCP Vol2. 3rd Ed. P.106 for multiplier.
      _state[_stateIndex] = f *
              (_state[_stateIndex - 1] ^
                  (_state[_stateIndex - 1].shiftRightUnsigned(w - 2))) +
          _stateIndex as Int32;
      _state[_stateIndex] &= _wordMask;
    }
  }

  /// Initializes the random number generator from a sequence.
  factory MersenneTwister.from(List<int> key) {
    var mt = MersenneTwister(seed: Int32(_sequenceInitialSeed));
    var i = 1;
    var j = 0;
    for (var k = n > key.length ? n : key.length; k != 0; k -= 1) {
      mt._state[i] = (mt._state[i] ^
              ((mt._state[i - 1] ^
                      (mt._state[i - 1].shiftRightUnsigned(w - 2))) *
                  f1)) +
          key[j] +
          j as Int32; // Non-linear.
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
              ((mt._state[i - 1] ^
                      (mt._state[i - 1].shiftRightUnsigned(w - 2))) *
                  f2)) -
          i as Int32; // Non-linear.
      mt._state[i] &= _wordMask;
      i += 1;
      if (i >= n) {
        mt._state[0] = mt._state[n - 1];
        i = 1;
      }
    }

    // MSB is 1; assuring non-zero initial array.
    mt._state[0] = Int32(1 << (w - 1));
    return mt;
  }

  /// Returns the next random number.
  ///
  /// Note this potentially returns a signed integer that is potentially
  /// negative.  To match values from Mersenne Twister implementations that
  /// operate over unsigned integers, call [UnsignedInt32.toUnsignedBigInt] on
  /// the result.
  Int32 call() {
    // Generate [n] words at one time.
    if (_stateIndex == n) {
      int i;
      for (i = 0; i < n - m; i += 1) {
        var x = (_state[i] & _upperMask) | (_state[i + 1] & _lowerMask);
        _state[i] = _state[i + m] ^ x.shiftRightUnsigned(1) ^ ((x & 0x1) * a);
      }
      for (; i < n - 1; i += 1) {
        var x = (_state[i] & _upperMask) | (_state[i + 1] & _lowerMask);
        _state[i] =
            _state[i + m - n] ^ x.shiftRightUnsigned(1) ^ ((x & 0x1) * a);
      }
      var x = (_state[n - 1] & _upperMask) | (_state[0] & _lowerMask);
      _state[n - 1] = _state[m - 1] ^ x.shiftRightUnsigned(1) ^ ((x & 0x1) * a);

      _stateIndex = 0;
    }

    var x = _state[_stateIndex];
    _stateIndex += 1;

    // Tempering.
    x ^= x.shiftRightUnsigned(u) & d;
    x ^= (x << s) & b;
    x ^= (x << t) & c;
    x ^= x.shiftRightUnsigned(l);
    return x;
  }
}

extension UnsignedInt32 on Int32 {
  /// Returns the unsigned 32-bit integer that corresponds to this [Int32]'s
  /// two's-complement bit representation.
  BigInt toUnsignedBigInt() {
    var bigInt = BigInt.parse(toString());
    return bigInt.isNegative ? ((BigInt.one << 32) + bigInt) : bigInt;
  }
}
