#include <cassert>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <limits>
#include <random>

extern "C" {
  #include "mt19937.h"
}


template<typename T, size_t n>
inline size_t length(const T(&array)[n]) { return n; }

/** Generates reference output for MT19937 and MT19937-64.
  *
  * This uses the original C implementations of MT19937 and MT19937-64 instead
  * of using `std::mt19937`/`std::mt19937_64` because initializing them from
  * seed sequences seems to be different from the original
  * `init_by_array`/`init_by_array64` functions.
  */
void generate_output(const std::filesystem::path mt19937_root,
                     const std::filesystem::path mt19937_64_root,
                     const std::string& filename) {
  constexpr auto openMode = std::ofstream::out | std::ofstream::trunc;

  auto output32 = std::ofstream(mt19937_root / filename, openMode);
  auto output64 = std::ofstream(mt19937_64_root / filename, openMode);

  constexpr size_t iterations = 10000;

  for (auto i = 0; i < iterations; ++i) {
    output32 << genrand_int32() << "\n";
    output64 << genrand64_int64() << "\n";
  }
}


int main() {
  const auto mt19937_root = std::filesystem::path("mt19937");
  const auto mt19937_64_root = std::filesystem::path("mt19937-64");

  std::filesystem::create_directory(mt19937_root);
  std::filesystem::create_directory(mt19937_64_root);

  generate_output(mt19937_root, mt19937_64_root, "default.txt");

  init_genrand(std::numeric_limits<uint32_t>::max());
  init_genrand64(std::numeric_limits<uint64_t>::max());
  generate_output(mt19937_root, mt19937_64_root, "max_seed.txt");

  unsigned long init[] = {0x123, 0x234, 0x345, 0x456};
  unsigned long long init64[] = {0x12345ULL, 0x23456ULL, 0x34567ULL, 0x45678ULL};

  init_by_array(init, length(init));
  init_by_array64(init64, length(init64));
  generate_output(mt19937_root, mt19937_64_root, "sequence.txt");

  return 0;
}
