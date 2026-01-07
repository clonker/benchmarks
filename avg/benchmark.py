#!/usr/bin/env python3
import subprocess
import time
import statistics
import re
import os

def compile_benchmarks():
    """Compile all benchmarks."""
    print("="*60)
    print("Compiling benchmarks...")
    print("="*60)

    # Create build directory
    os.makedirs("build", exist_ok=True)

    commands = [
        ("javac -d build Average.java", "Java - Basic"),
        ("javac -d build AverageOptimized.java", "Java - Optimized"),
        ("zig build-exe average.zig -O ReleaseFast -femit-bin=build/average_zig", "Zig - Basic"),
        ("zig build-exe average_optimized.zig -O ReleaseFast -femit-bin=build/average_optimized_zig", "Zig - Optimized"),
        ("zig build-exe average_minimal.zig -O ReleaseFast -femit-bin=build/average_minimal_zig", "Zig - Minimal"),
        ("zig build-exe average_nounroll.zig -O ReleaseFast -femit-bin=build/average_nounroll_zig", "Zig - NoUnroll"),
        ("zig build-exe average_scalar_unroll.zig -O ReleaseFast -femit-bin=build/average_scalar_unroll_zig", "Zig - ScalarUnroll"),
        ("g++ -O3 -march=native -std=c++20 test.cpp -o build/test_cpp", "C++ - Basic"),
        ("g++ -O3 -march=native -std=c++20 test_optimized.cpp -o build/test_optimized_cpp", "C++ - Optimized"),
        ("g++ -O3 -march=native -std=c++20 test_aligned.cpp -o build/test_aligned_cpp", "C++ - Aligned"),
    ]

    for cmd, name in commands:
        print(f"  {name}... ", end='', flush=True)
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        if result.returncode != 0:
            print(f"FAILED\n    Error: {result.stderr}")
            return False
        else:
            print("OK")

    print("\nCompilation complete!\n")
    return True

def run_benchmark(command, name, runs=5):
    """Run a benchmark command multiple times and collect timing data."""
    data_creation_times = []
    averaging_times = []
    total_times = []

    print(f"\n{'='*60}")
    print(f"Benchmarking {name} ({runs} runs)...")
    print(f"{'='*60}")

    for i in range(runs):
        print(f"  Run {i+1}/{runs}... ", end='', flush=True)
        result = subprocess.run(
            command,
            shell=True,
            capture_output=True,
            text=True
        )

        if result.returncode != 0:
            print(f"FAILED\n    Error: {result.stderr}")
            continue

        # Parse output for timing information
        # Zig uses stderr for debug output, so check both stdout and stderr
        output = result.stdout + result.stderr

        # Extract timing values using regex
        data_creation_match = re.search(r'Data creation:\s+([\d.]+)\s+seconds', output)
        averaging_match = re.search(r'Averaging:\s+([\d.]+)\s+seconds', output)
        total_match = re.search(r'Total:\s+([\d.]+)\s+seconds', output)

        if data_creation_match and averaging_match and total_match:
            data_creation = float(data_creation_match.group(1))
            averaging = float(averaging_match.group(1))
            total = float(total_match.group(1))

            data_creation_times.append(data_creation)
            averaging_times.append(averaging)
            total_times.append(total)

            print(f"Total: {total:.3f}s (Create: {data_creation:.3f}s, Avg: {averaging:.3f}s)")
        else:
            print(f"FAILED - Could not parse output")

    return {
        'data_creation': data_creation_times,
        'averaging': averaging_times,
        'total': total_times
    }

def print_results(results):
    """Print summary statistics for all benchmarks."""

    # Print summary for each timing category
    for category in ['total', 'data_creation', 'averaging']:
        print(f"\n{'='*90}")
        print(f"SUMMARY - {category.replace('_', ' ').upper()} TIME")
        print(f"{'='*90}")
        print(f"{'Benchmark':<20} {'Min':<14} {'Max':<14} {'Mean':<14} {'Median':<14} {'StdDev':<14}")
        print("-" * 90)

        baseline_mean = None
        for name, timings in results.items():
            times = timings[category]
            if not times:
                continue

            min_time = min(times)
            max_time = max(times)
            mean_time = statistics.mean(times)
            median_time = statistics.median(times)
            stddev = statistics.stdev(times) if len(times) > 1 else 0

            if baseline_mean is None:
                baseline_mean = mean_time

            print(f"{name:<20} {min_time:<14.6f} {max_time:<14.6f} {mean_time:<14.6f} {median_time:<14.6f} {stddev:<14.6f}")

        # Print relative performance
        print(f"\n{'='*90}")
        print(f"RELATIVE PERFORMANCE - {category.replace('_', ' ').upper()} (baseline = 1.00x)")
        print(f"{'='*90}")

        for name, timings in results.items():
            times = timings[category]
            if not times:
                continue
            mean_time = statistics.mean(times)
            relative = mean_time / baseline_mean
            speedup = baseline_mean / mean_time
            print(f"{name:<20} {relative:>6.3f}x  ({speedup:>7.3f}x faster)  ({mean_time:.6f}s)")

def main():
    # Compile benchmarks first
    if not compile_benchmarks():
        print("Compilation failed. Exiting.")
        return

    benchmarks = [
        ("cd build && java Average", "Java-Basic"),
        ("cd build && java AverageOptimized", "Java-Optimized"),
        ("./build/average_zig", "Zig-Basic"),
        ("./build/average_optimized_zig", "Zig-SIMD"),
        ("./build/average_minimal_zig", "Zig-Minimal"),
        ("./build/average_nounroll_zig", "Zig-NoUnroll"),
        ("./build/average_scalar_unroll_zig", "Zig-ScalarUnroll"),
        ("./build/test_cpp", "C++-Basic"),
        ("./build/test_optimized_cpp", "C++-Optimized"),
        ("./build/test_aligned_cpp", "C++-Aligned"),
        ("python3 average.py", "Python-Basic"),
        ("python3 average_numpy.py", "Python-NumPy"),
    ]

    results = {}

    for command, name in benchmarks:
        timings = run_benchmark(command, name, runs=3)
        results[name] = timings

    print_results(results)

if __name__ == "__main__":
    main()
