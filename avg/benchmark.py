#!/usr/bin/env python3
import subprocess
import time
import statistics

def run_benchmark(command, name, runs=5):
    """Run a benchmark command multiple times and collect timing data."""
    times = []
    print(f"\n{'='*60}")
    print(f"Benchmarking {name} ({runs} runs)...")
    print(f"{'='*60}")

    for i in range(runs):
        print(f"  Run {i+1}/{runs}... ", end='', flush=True)
        start = time.perf_counter()
        result = subprocess.run(
            command,
            shell=True,
            capture_output=True,
            text=True
        )
        end = time.perf_counter()
        elapsed = end - start
        times.append(elapsed)
        print(f"{elapsed:.3f}s")

        if result.returncode != 0:
            print(f"    Error: {result.stderr}")

    return times

def print_results(results):
    """Print summary statistics for all benchmarks."""
    print(f"\n{'='*60}")
    print("SUMMARY")
    print(f"{'='*60}")
    print(f"{'Language':<12} {'Min':<10} {'Max':<10} {'Mean':<10} {'Median':<10} {'StdDev':<10}")
    print("-" * 60)

    baseline_mean = None
    for name, times in results.items():
        min_time = min(times)
        max_time = max(times)
        mean_time = statistics.mean(times)
        median_time = statistics.median(times)
        stddev = statistics.stdev(times) if len(times) > 1 else 0

        if baseline_mean is None:
            baseline_mean = mean_time

        print(f"{name:<12} {min_time:<10.3f} {max_time:<10.3f} {mean_time:<10.3f} {median_time:<10.3f} {stddev:<10.3f}")

    print(f"\n{'='*60}")
    print("RELATIVE PERFORMANCE (mean time)")
    print(f"{'='*60}")
    for name, times in results.items():
        mean_time = statistics.mean(times)
        relative = mean_time / baseline_mean
        print(f"{name:<12} {relative:>6.2f}x  ({mean_time:.3f}s)")

def main():
    benchmarks = [
        ("./average_cpp", "C++"),
        ("./average_cpp_opt", "C++ Opt"),
        ("./average_cpp_aligned", "C++ Aligned"),
        ("./average", "Zig"),
        ("./average_zig_opt", "Zig SIMD"),
        ("java Average", "Java"),
        ("java AverageOptimized", "Java Opt"),
        ("python average_numpy.py", "NumPy"),
    ]

    results = {}

    for command, name in benchmarks:
        times = run_benchmark(command, name, runs=5)
        results[name] = times

    print_results(results)

if __name__ == "__main__":
    main()
