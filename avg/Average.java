import java.util.ArrayList;
import java.util.Random;

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
        ArrayList<Double> data = new ArrayList<>(100000000);

        Random rng = new Random();

        for (int i = 0; i < 100000000; i++) {
            data.add(rng.nextDouble() * 200 - 100);  // range: -100 to 100
        }

        double avg = average(data);
        System.out.println("average = " + avg);
    }
}
