#include <ranges>
#include <type_traits>
#include <vector>
#include <random>
#include <iostream>
#include <utility>

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
    std::vector<int> data;
    data.reserve(100000000);

    std::mt19937 rng{std::random_device{}()};
    std::uniform_real_distribution<double> dist(-100, 100);

    for (int i = 0; i < 100000000; ++i) {
        data.push_back(dist(rng));
    }

    double avg = average(data);
    std::cout << "average = " << avg << '\n';
}

