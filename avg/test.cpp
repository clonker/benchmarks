#include <ranges>
#include <type_traits>
#include <vector>
#include <random>
#include <iostream>
#include <utility>
#include <chrono>
#include <iomanip>

template <std::ranges::input_range R>
auto average(R&& r)
{
    using value_t = std::ranges::range_value_t<R>;
    using acc_t   = std::common_type_t<value_t, double>;

    acc_t sum = 0;
    std::size_t count = 0;

    for (auto&& v : r) {
        sum += v;
        ++count;
    }

    return sum / count;
}

int main()
{
    auto start_total = std::chrono::high_resolution_clock::now();

    auto start_create = std::chrono::high_resolution_clock::now();
    std::vector<int> data;
    data.reserve(100000000);

    std::mt19937 rng{std::random_device{}()};
    std::uniform_real_distribution<double> dist(-100, 100);

    for (int i = 0; i < 100000000; ++i) {
        data.push_back(dist(rng));
    }
    auto end_create = std::chrono::high_resolution_clock::now();

    auto start_average = std::chrono::high_resolution_clock::now();
    double avg = average(data);
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
}

