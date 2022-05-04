## 0.1.0

* Replacement for the original mt19937 package.  Notable differences:
  * Compatible with Dart 2.
  * Provides an MT19937-64 implementation.
  * Uses native `int` types for Dart VM platforms, which is significantly faster
    than using `Int64`.
