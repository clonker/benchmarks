#include <vector>
#include <random>
#include <iostream>

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
    constexpr size_t n = 100'000'000;
    std::vector<double> data(n);

    std::mt19937 rng{std::random_device{}()};
    std::uniform_real_distribution<double> dist(-100.0, 100.0);

    for (size_t i = 0; i < n; ++i) {
        data[i] = dist(rng);
    }

    double avg = average_optimized(data.data(), n);
    std::cout << "average = " << avg << '\n';

    return 0;
}
