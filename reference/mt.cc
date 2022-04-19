#include <fstream>
#include <iostream>
#include <limits>
#include <random>

int main() {
  std::mt19937 gen32;
  std::mt19937_64 gen64;
  std::mt19937 gen32maxSeed(
    std::numeric_limits<std::mt19937::result_type>::max()
  );
  std::mt19937_64 gen64maxSeed(
    std::numeric_limits<std::mt19937_64::result_type>::max()
  );

  const auto openMode = std::ofstream::out | std::ofstream::trunc;
  std::ofstream output32("expected_mt19937_default.txt", openMode);
  std::ofstream output64("expected_mt19937_64_default.txt", openMode);
  std::ofstream output32maxSeed("expected_mt19937_max_seed.txt", openMode);
  std::ofstream output64maxSeed("expected_mt19937_64_max_seed.txt", openMode);

  for (auto i = 0; i < 10000; ++i) {
    output32 << gen32() << "\n";
    output64 << gen64() << "\n";
    output32maxSeed << gen32maxSeed() << "\n";
    output64maxSeed << gen64maxSeed() << "\n";
  }

  return 0;
}
