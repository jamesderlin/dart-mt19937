import 'package:fixnum/fixnum.dart';

// ignore: public_member_api_docs
extension UnsignedInt64 on Int64 {
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

// ignore: public_member_api_docs
extension UnsignedRightShift32 on Int32 {
  // ignore: public_member_api_docs
  Int32 operator >>>(int n) => shiftRightUnsigned(n);
}

// ignore: public_member_api_docs
extension UnsignedRightShift64 on Int64 {
  // ignore: public_member_api_docs
  Int64 operator >>>(int n) => shiftRightUnsigned(n);
}
