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

/// An implementation of Mersenne Twister 19937-64.
class MersenneTwister64 {
  /// Word size.
  static const w = 64;

  /// Mask for [w] bits.
  static final _wordMask = (BigInt.one << w) - BigInt.one;

  /// The maximum value returnable by [call()].
  static final max = _wordMask;

  /// Separation point of a word (the "twist value").
  static const r = 31;

  /// Least-significant `r` bits.
  static final _lowerMask = (BigInt.one << r) - BigInt.one;

  /// Most significant `w - r` bits.
  static final _upperMask = _wordMask & ~_lowerMask;

  /// Degree of recurrence.
  static const n = 312;

  /// Recurrence offset.
  static const m = 156;

  /// Coefficients of the rational normal form twist matrix.
  static final a = BigInt.parse('B5026F5AA96619E9', radix: 16);

  /// Tempering right shift amount.
  static const u = 29;

  /// Tempering mask.
  static final d = BigInt.parse('5555555555555555', radix: 16);

  /// Tempering left shift amount.
  static const s = 17;

  /// Tempering mask.
  static final b = BigInt.parse('71D67FFFEDA60000', radix: 16);

  /// Tempering left shift amount.
  static const t = 37;

  /// Tempering mask.
  static final c = BigInt.parse('FFF7EEE000000000', radix: 16);

  /// Tempering right shift amount.
  static const l = 43;

  /// Initialization multiplier.
  static final f = BigInt.parse('6364136223846793005');

  /// Initialization multiplier when seeding from a sequence.
  static final f1 = BigInt.parse('3935559000370003845');

  /// Initialization multiplier when seeding from a sequence.
  static final f2 = BigInt.parse('2862933555777941757');

  static const defaultSeed = 5489;

  static const _sequenceInitialSeed = 19650218;

  /// The state vector.
  final _state = List<BigInt>.filled(n, BigInt.zero);
  int _stateIndex = n;

  /// Initializes the random number generator from an optional seed.
  MersenneTwister64({BigInt? seed}) {
    _state[0] = (seed ?? BigInt.from(defaultSeed)) & _wordMask;
    for (_stateIndex = 1; _stateIndex < n; _stateIndex += 1) {
      // See Knuth TAOCP Vol2. 3rd Ed. P.106 for multiplier.
      _state[_stateIndex] = f *
              (_state[_stateIndex - 1] ^
                  (_state[_stateIndex - 1] >>> (w - 2))) +
          BigInt.from(_stateIndex);
      _state[_stateIndex] &= _wordMask;
    }
  }

  /// Initializes the random number generator from a sequence.
  factory MersenneTwister64.from(List<BigInt> key) {
    var mt = MersenneTwister64(seed: BigInt.from(_sequenceInitialSeed));
    var i = 1;
    var j = 0;
    for (var k = n > key.length ? n : key.length; k != 0; k -= 1) {
      mt._state[i] = (mt._state[i] ^
              ((mt._state[i - 1] ^ (mt._state[i - 1] >>> (w - 2))) * f1)) +
          key[j] +
          BigInt.from(j); // Non-linear.
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
          BigInt.from(i); // Non-linear.
      mt._state[i] &= _wordMask;
      i += 1;
      if (i >= n) {
        mt._state[0] = mt._state[n - 1];
        i = 1;
      }
    }

    // MSB is 1; assuring non-zero initial array.
    mt._state[0] = BigInt.one << (w - 1);
    return mt;
  }

  /// Returns the next random number in the range [0, max].
  BigInt call() {
    // Generate [n] words at one time.
    if (_stateIndex == n) {
      int i;
      for (i = 0; i < n - m; i += 1) {
        var x = (_state[i] & _upperMask) | (_state[i + 1] & _lowerMask);
        _state[i] = _state[i + m] ^ (x >>> 1) ^ ((x & BigInt.one) * a);
      }
      for (; i < n - 1; i += 1) {
        var x = (_state[i] & _upperMask) | (_state[i + 1] & _lowerMask);
        _state[i] = _state[i + m - n] ^ (x >>> 1) ^ ((x & BigInt.one) * a);
      }
      var x = (_state[n - 1] & _upperMask) | (_state[0] & _lowerMask);
      _state[n - 1] = _state[m - 1] ^ (x >>> 1) ^ ((x & BigInt.one) * a);

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

extension on BigInt {
  /// Unsigned right-shift.
  ///
  /// This is unnecessary for [BigInt] but we use it to minimize differences
  /// with the VM and `package:fixnum` implementations.
  BigInt operator >>>(int n) => this >> n;
}
