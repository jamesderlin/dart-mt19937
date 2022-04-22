import 'package:fixnum/fixnum.dart';
import 'package:mt19937/mt19937.dart';

void main() {
  // Provides a raw MT19937 generator.
  var mt = MersenneTwister();
  print(List<int>.generate(10, (_) => mt()));

  // Also provides [Random] interfaces.
  var random = RandomMt19937();
  print(List<int>.generate(10, (_) => random.nextInt(100)));
  print(List<double>.generate(10, (_) => random.nextDouble()));

  var random64 = RandomMt19937_64();
  print(
    List<BigInt>.generate(
      10,
      (_) => random64.nextBigInt(random64.exclusiveMax),
    ),
  );

  // Also provides a configurable engine that is preconfigured for
  // MT19937 (32-bit words) and MT19937-64 (64-bit words).
  var seed = DateTime.now().millisecondsSinceEpoch;
  var mt64 = MersenneTwisterEngine.w64()..init(Int64(seed));
  print(List<BigInt>.generate(10, (_) => mt64()));
}
