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
