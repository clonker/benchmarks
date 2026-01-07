import java.util.ArrayList;
import java.util.Random;
import java.util.Locale;

public class Average {
    public static double average(ArrayList<Double> data) {
        double sum = 0.0;
        int count = 0;

        for (double v : data) {
            sum += v;
            count++;
        }

        return sum / count;
    }

    public static void main(String[] args) {
        long startTotal = System.nanoTime();

        long startCreate = System.nanoTime();
        ArrayList<Double> data = new ArrayList<>(100000000);

        Random rng = new Random();

        for (int i = 0; i < 100000000; i++) {
            data.add(rng.nextDouble() * 200 - 100);  // range: -100 to 100
        }
        long endCreate = System.nanoTime();

        long startAverage = System.nanoTime();
        double avg = average(data);
        long endAverage = System.nanoTime();

        long endTotal = System.nanoTime();

        double createTime = (endCreate - startCreate) / 1_000_000_000.0;
        double averageTime = (endAverage - startAverage) / 1_000_000_000.0;
        double totalTime = (endTotal - startTotal) / 1_000_000_000.0;


        System.out.println(Locale.US+ "average = " + avg);
        System.out.printf(Locale.US, "Data creation: %.6f seconds%n", createTime);
        System.out.printf(Locale.US, "Averaging:     %.6f seconds%n", averageTime);
        System.out.printf(Locale.US, "Total:         %.6f seconds%n", totalTime);
    }
}
