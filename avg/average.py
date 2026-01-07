import random
import numpy as np

def average(data):
    total = 0.0
    count = 0

    for v in data:
        total += v
        count += 1

    return total / count

def main():
    data = []

    random.seed()

    for i in range(100_000_000):
        data.append(random.uniform(-100, 100))

    avg = np.mean(data)
    print(f"average = {avg}")

if __name__ == "__main__":
    main()
