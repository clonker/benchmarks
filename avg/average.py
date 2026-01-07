import random
import numpy as np
import time

def average(data):
    total = 0.0
    count = 0

    for v in data:
        total += v
        count += 1

    return total / count

def main():
    start_total = time.perf_counter()

    start_create = time.perf_counter()
    data = []

    random.seed()

    for i in range(100_000_000):
        data.append(random.uniform(-100, 100))
    end_create = time.perf_counter()

    start_average = time.perf_counter()
    avg = np.mean(data)
    end_average = time.perf_counter()

    end_total = time.perf_counter()

    create_time = end_create - start_create
    average_time = end_average - start_average
    total_time = end_total - start_total

    print(f"average = {avg}")
    print(f"Data creation: {create_time:.6f} seconds")
    print(f"Averaging:     {average_time:.6f} seconds")
    print(f"Total:         {total_time:.6f} seconds")

if __name__ == "__main__":
    main()
