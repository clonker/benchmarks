#include <vector>
#include <random>
#include <iostream>
#include <chrono>
#include <iomanip>

inline double average_optimized(const double* __restrict__ data, size_t n) {
    double sum0 = 0.0, sum1 = 0.0, sum2 = 0.0, sum3 = 0.0;
    double sum4 = 0.0, sum5 = 0.0, sum6 = 0.0, sum7 = 0.0;

    size_t i = 0;
    const size_t unroll_limit = n - (n % 8);

    for (; i < unroll_limit; i += 8) {
        sum0 += data[i];
        sum1 += data[i + 1];
        sum2 += data[i + 2];
        sum3 += data[i + 3];
        sum4 += data[i + 4];
        sum5 += data[i + 5];
        sum6 += data[i + 6];
        sum7 += data[i + 7];
    }

    double sum = sum0 + sum1 + sum2 + sum3 + sum4 + sum5 + sum6 + sum7;

    for (; i < n; ++i) {
        sum += data[i];
    }

    return sum / static_cast<double>(n);
}

int main() {
    auto start_total = std::chrono::high_resolution_clock::now();

    auto start_create = std::chrono::high_resolution_clock::now();
    constexpr size_t n = 100'000'000;
    std::vector<double> data(n);

    std::mt19937 rng{std::random_device{}()};
    std::uniform_real_distribution<double> dist(-100.0, 100.0);

    for (size_t i = 0; i < n; ++i) {
        data[i] = dist(rng);
    }
    auto end_create = std::chrono::high_resolution_clock::now();

    auto start_average = std::chrono::high_resolution_clock::now();
    double avg = average_optimized(data.data(), n);
    auto end_average = std::chrono::high_resolution_clock::now();

    auto end_total = std::chrono::high_resolution_clock::now();

    auto create_time = std::chrono::duration<double>(end_create - start_create).count();
    auto average_time = std::chrono::duration<double>(end_average - start_average).count();
    auto total_time = std::chrono::duration<double>(end_total - start_total).count();

    std::cout << "average = " << avg << '\n';
    std::cout << std::fixed << std::setprecision(6);
    std::cout << "Data creation: " << create_time << " seconds\n";
    std::cout << "Averaging:     " << average_time << " seconds\n";
    std::cout << "Total:         " << total_time << " seconds\n";

    return 0;
}
