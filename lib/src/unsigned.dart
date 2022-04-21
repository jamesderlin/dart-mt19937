import 'package:fixnum/fixnum.dart';

// ignore: public_member_api_docs
extension UnsignedInt on int {
  /// Returns the unsigned 32-bit integer that corresponds to this [int]'s
  /// two's-complement bit representation.
  int toUint32() {
    return this >= 0 ? this : (this + 0xFFFFFFFF + 1);
  }
}

// ignore: public_member_api_docs
extension UnsignedInt64 on Int64 {
  /// Returns the unsigned 64-bit integer that corresponds to this [Int64]'s
  /// two's-complement bit representation.
  BigInt toUnsignedBigInt() => BigInt.parse(toStringUnsigned());
}
