import java.util.Random;

public class AverageOptimized {
    // Optimized with loop unrolling and primitive array
    public static double average(double[] data) {
        int n = data.length;

        // 8-way loop unrolling
        double sum0 = 0.0, sum1 = 0.0, sum2 = 0.0, sum3 = 0.0;
        double sum4 = 0.0, sum5 = 0.0, sum6 = 0.0, sum7 = 0.0;

        int i = 0;
        int unrollLimit = n - (n % 8);

        for (; i < unrollLimit; i += 8) {
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

        // Handle remaining elements
        for (; i < n; i++) {
            sum += data[i];
        }

        return sum / n;
    }

    public static void main(String[] args) {
        long startTotal = System.nanoTime();

        long startCreate = System.nanoTime();
        final int n = 100_000_000;
        double[] data = new double[n];

        Random rng = new Random();

        for (int i = 0; i < n; i++) {
            data[i] = rng.nextDouble() * 200.0 - 100.0;
        }
        long endCreate = System.nanoTime();

        long startAverage = System.nanoTime();
        double avg = average(data);
        long endAverage = System.nanoTime();

        long endTotal = System.nanoTime();

        double createTime = (endCreate - startCreate) / 1_000_000_000.0;
        double averageTime = (endAverage - startAverage) / 1_000_000_000.0;
        double totalTime = (endTotal - startTotal) / 1_000_000_000.0;

        System.out.println("average = " + avg);
        System.out.printf("Data creation: %.6f seconds%n", createTime);
        System.out.printf("Averaging:     %.6f seconds%n", averageTime);
        System.out.printf("Total:         %.6f seconds%n", totalTime);
    }
}
