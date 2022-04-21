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

import 'dart:typed_data';

import 'mt19937_fixnum.dart' as base;

/// An implementation of the [Mersenne Twister 19937][1] pseudo-random number
/// generator.
///
/// This implementation should be used only for the Dart VM, not for Dart for
/// the Web.
///
/// [1]: https://en.wikipedia.org/wiki/Mersenne_twister
class MersenneTwister implements base.MersenneTwister {
  /// Word size.
  static const _w = 32;

  /// Mask for [_w] bits.
  static const _wordMask = (1 << _w) - 1;

  /// The maximum value that returnable by [call()].
  static const max = _wordMask;

  /// Separation point of a word (the "twist value").
  static const _r = 31;

  /// Least-significant `r` bits.
  static const _lowerMask = (1 << _r) - 1;

  /// Most significant `w - r` bits.
  static const _upperMask = _wordMask & ~_lowerMask;

  /// Degree of recurrence.
  static const _n = 624;

  /// Recurrence offset.
  static const _m = 397;

  /// Coefficients of the rational normal form twist matrix.
  static const _a = 0x9908B0DF;

  /// Tempering right shift amount.
  static const _u = 11;

  /// Tempering mask.
  static const _d = 0xFFFFFFFF;

  /// Tempering left shift amount.
  static const _s = 7;

  /// Tempering mask.
  static const _b = 0x9D2C5680;

  /// Tempering left shift amount.
  static const _t = 15;

  /// Tempering mask.
  static const _c = 0xEFC60000;

  /// Tempering right shift amount.
  static const _l = 18;

  /// Initialization multiplier.
  static const _f = 1812433253;

  /// Initialization multiplier when seeding from a sequence.
  static const _f1 = 1664525;

  /// Initialization multiplier when seeding from a sequence.
  static const _f2 = 1566083941;

  static const defaultSeed = 5489;

  static const _sequenceInitialSeed = 19650218;

  /// The state vector.
  final _state = Uint32List(_n);
  int _stateIndex = _n;

  /// Initializes the random number generator from an optional seed.
  MersenneTwister({int? seed}) {
    _state[0] = (seed ?? defaultSeed) & _wordMask;
    for (_stateIndex = 1; _stateIndex < _n; _stateIndex += 1) {
      // See Knuth TAOCP Vol2. 3rd Ed. P.106 for multiplier.
      _state[_stateIndex] = _f *
              (_state[_stateIndex - 1] ^
                  (_state[_stateIndex - 1] >>> (_w - 2))) +
          _stateIndex;
      _state[_stateIndex] &= _wordMask;
    }
  }

  /// Initializes the random number generator from a sequence.
  factory MersenneTwister.from(List<int> key) {
    var mt = MersenneTwister(seed: _sequenceInitialSeed);
    var i = 1;
    var j = 0;
    for (var k = _n > key.length ? _n : key.length; k != 0; k -= 1) {
      mt._state[i] = (mt._state[i] ^
              ((mt._state[i - 1] ^ (mt._state[i - 1] >>> (_w - 2))) * _f1)) +
          key[j] +
          j; // Non-linear.
      mt._state[i] &= _wordMask;
      i += 1;
      j += 1;
      if (i >= _n) {
        mt._state[0] = mt._state[_n - 1];
        i = 1;
      }
      if (j >= key.length) {
        j = 0;
      }
    }
    for (var k = _n - 1; k != 0; k -= 1) {
      mt._state[i] = (mt._state[i] ^
              ((mt._state[i - 1] ^ (mt._state[i - 1] >>> (_w - 2))) * _f2)) -
          i; // Non-linear.
      mt._state[i] &= _wordMask;
      i += 1;
      if (i >= _n) {
        mt._state[0] = mt._state[_n - 1];
        i = 1;
      }
    }

    // MSB is 1; assuring non-zero initial array.
    mt._state[0] = 1 << (_w - 1);
    return mt;
  }

  /// Returns the next random number in the range [0, max].
  @override
  int call() {
    // Generate [n] words at one time.
    if (_stateIndex == _n) {
      int i;
      for (i = 0; i < _n - _m; i += 1) {
        var x = (_state[i] & _upperMask) | (_state[i + 1] & _lowerMask);
        _state[i] = _state[i + _m] ^ (x >>> 1) ^ ((x & 0x1) * _a);
      }
      for (; i < _n - 1; i += 1) {
        var x = (_state[i] & _upperMask) | (_state[i + 1] & _lowerMask);
        _state[i] = _state[i + _m - _n] ^ (x >>> 1) ^ ((x & 0x1) * _a);
      }
      var x = (_state[_n - 1] & _upperMask) | (_state[0] & _lowerMask);
      _state[_n - 1] = _state[_m - 1] ^ (x >>> 1) ^ ((x & 0x1) * _a);

      _stateIndex = 0;
    }

    var x = _state[_stateIndex];
    _stateIndex += 1;

    // Tempering.
    x ^= (x >>> _u) & _d;
    x ^= (x << _s) & _b;
    x ^= (x << _t) & _c;
    x ^= x >>> _l;
    return x.toUnsigned(32);
  }
}
