# Average Computation Benchmarks

Performance comparison of computing the average of 100 million doubles across different languages and optimization levels.

## Prerequisites

- **C++**: g++ with C++20 support
- **Java**: JDK 8 or newer
- **Zig**: Zig compiler (tested with latest version)
- **Python**: Python 3.x with NumPy

## Building

### C++ Implementations

```bash
# Standard C++ version
g++ -O3 -std=c++20 test.cpp -o average_cpp

# Optimized C++ with aggressive flags
g++ -O3 -march=native -ffast-math -std=c++20 test_optimized.cpp -o average_cpp_opt

# Aligned memory version
g++ -O3 -march=native -ffast-math -std=c++20 test_aligned.cpp -o average_cpp_aligned
```

**Key flags:**
- `-O3`: Maximum optimization
- `-march=native`: Target your specific CPU (enables AVX-512 on supported CPUs)
- `-ffast-math`: Aggressive floating-point optimizations (~30% speedup)
- `-std=c++20`: C++20 standard (required for ranges)

### Java Implementations

```bash
# Standard version
javac Average.java

# Optimized version (uses primitive arrays instead of ArrayList)
javac AverageOptimized.java
```

No special flags needed - JIT handles optimization at runtime.

### Zig Implementations

```bash
# Standard version
zig build-exe average.zig -O ReleaseFast

# SIMD optimized version
zig build-exe average_optimized.zig -O ReleaseFast -mcpu=native
mv average_optimized average_zig_opt

# Minimal SIMD version
zig build-exe average_minimal.zig -O ReleaseFast -mcpu=native
```

**Key flags:**
- `-O ReleaseFast`: Maximum performance, safety checks disabled
- `-mcpu=native`: Target your specific CPU architecture

### Python

No compilation needed - uses NumPy for vectorized operations:

```bash
pip install numpy
```

## Running

### Individual Programs

```bash
# C++
./average_cpp
./average_cpp_opt
./average_cpp_aligned

# Java
java Average
java AverageOptimized

# Zig
./average
./average_zig_opt

# Python
python average.py          # Pure Python (slow)
python average_numpy.py    # NumPy vectorized
```

### Benchmark Suite

Run all implementations 5 times each and compare:

```bash
python benchmark.py
```

This will output detailed statistics including min, max, mean, median, and standard deviation for each implementation.

## Implementation Details

### Standard Implementations
- **test.cpp**: C++ using ranges and standard accumulation
- **Average.java**: Java using ArrayList<Double> (boxing overhead)
- **average.zig**: Zig with simple loop
- **average.py**: Pure Python (very slow)

### Optimized Implementations
- **test_optimized.cpp**: 8-way manual loop unrolling, compiler auto-vectorizes to AVX-512
- **AverageOptimized.java**: Primitive double[] array + manual unrolling
- **average_optimized.zig**: Explicit SIMD using `@Vector(8, f64)` with multiple accumulators
- **average_numpy.py**: NumPy's vectorized operations

### Special Versions
- **test_aligned.cpp**: 64-byte aligned memory allocation for AVX-512
- **average_minimal.zig**: Simple SIMD without excessive unrolling

## Expected Performance (AMD Ryzen 9 9950X3D)

From fastest to slowest:

1. **C++ Opt**: ~0.22s (baseline)
2. **Zig SIMD**: ~0.41s (1.9x slower)
3. **NumPy**: ~0.42s (1.9x slower)
4. **C++ Standard**: ~0.43s (2x slower)
5. **Zig Standard**: ~0.43s (2x slower)
6. **Java Opt**: ~0.83s (3.8x slower)
7. **Java Standard**: ~1.78s (8x slower)
8. **Python**: ~9.6s (43x slower)

## Key Findings

### Why C++ Optimized is Fastest

1. **Tight loop**: Single AVX-512 instruction per iteration
2. **-ffast-math**: Relaxes IEEE 754 for aggressive optimization
3. **Minimal unrolling**: GCC creates a 6-instruction loop body
4. **AVX-512**: Processes 8 doubles per instruction

### Why Zig SIMD is Slower

Zig's compiler aggressively unrolls loops (32x), creating:
- Large instruction cache footprint
- Frontend decode bottleneck
- Complex dependency chains

The C++ version has a tiny loop (6 instructions) while Zig generates 32+ instructions per iteration.

### Optimization Techniques Used

- **C++**: Loop unrolling + `__restrict__` + `-march=native -ffast-math`
- **Java**: Primitive arrays (avoid boxing) + manual unrolling
- **Zig**: Explicit SIMD vectors `@Vector(8, f64)`
- **Python**: NumPy (C backend with BLAS/vectorization)

## Compilation Commands Reference

### C++ Variants

```bash
# Without -ffast-math (IEEE 754 compliant, ~30% slower)
g++ -O3 -march=native -std=c++20 test_optimized.cpp -o average_cpp_opt_nofastmath

# Debug build
g++ -g -std=c++20 test_optimized.cpp -o average_cpp_debug
```

### Zig Build Modes

```bash
# Debug mode
zig build-exe average.zig

# ReleaseSafe (optimized with safety checks)
zig build-exe average.zig -O ReleaseSafe

# ReleaseFast (maximum speed, no safety)
zig build-exe average.zig -O ReleaseFast

# ReleaseSmall (optimize for size)
zig build-exe average.zig -O ReleaseSmall
```

## Assembly Inspection

View generated assembly to verify SIMD usage:

```bash
# C++
objdump -d average_cpp_opt | grep -A 20 "average_optimized"

# Zig
objdump -d average_zig_opt | grep -A 50 "averageSimd"

# Look for AVX-512 instructions
objdump -d average_cpp_opt | grep "vaddpd.*%zmm"
```

## License

Public domain - use freely for benchmarking and learning.
