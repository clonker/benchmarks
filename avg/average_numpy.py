import numpy as np

def main():
    # Generate 100 million random doubles using numpy (vectorized)
    data = np.random.uniform(-100, 100, size=100_000_000)

    # Calculate average using numpy
    avg = np.mean(data)
    print(f"average = {avg}")

if __name__ == "__main__":
    main()
