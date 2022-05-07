import 'package:mt19937/src/unused/mt19937_64_bigint.dart' as mtbi;
import 'package:mt19937/src/unused/mt19937_64_fixnum.dart' as mtfn;
import 'package:mt19937/src/unused/mt19937_64_vm.dart' as mtvm;

void _time(String name, void Function() callback, int iterationCount) {
  var stopwatch = Stopwatch()..start();
  for (var i = 0; i < iterationCount; i += 1) {
    callback();
  }
  print('$name ${stopwatch.elapsed}');
}

/// Prints the result of [n]th iteration of the generator.
///
/// This is meant to verify correctness and doesn't care about speed, so it uses
/// `dynamic` types for duck-typing.
void _testCorrectness(String name, dynamic mt, int n) {
  for (var i = 1; i < n; i += 1) {
    // ignore: avoid_dynamic_calls
    mt();
  }
  // ignore: avoid_dynamic_calls
  dynamic result = mt();

  // ignore: avoid_dynamic_calls
  print('$name $result');
}

void main() {
  // Basic check for correctness.
  {
    const iterationCount = 10000;
    print('Expect: 9981545732273789042');
    _testCorrectness('VM int:', mtvm.MersenneTwister64(), iterationCount);
    _testCorrectness('Int64: ', mtfn.MersenneTwister64(), iterationCount);
    _testCorrectness('BigInt:', mtbi.MersenneTwister64(), iterationCount);
  }

  print('');

  // Benchmarks.
  {
    const iterationCount = 100000;
    _time(
      'int (signed):  ',
      mtvm.MersenneTwister64().nextInt64,
      iterationCount,
    );
    _time(
      'Int64 (signed):',
      mtfn.MersenneTwister64().nextInt64,
      iterationCount,
    );
    _time(
      'BigInt:        ',
      mtbi.MersenneTwister64().call,
      iterationCount,
    );
  }
}
