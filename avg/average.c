#include <stdio.h>
#include <stdlib.h>
#include <time.h>

double average(double *data, size_t count) {
    double sum = 0.0;
    for (size_t i = 0; i < count; i++)
        sum += data[i];
    return sum / count;
}

int main(void) {
    const size_t N = 100000000;
    double *data = malloc(N * sizeof(double));
    if (data == NULL) {
        fprintf(stderr, "Memory allocation failed\n");
        return 1;
    }

    srand((unsigned)time(NULL));

    clock_t startCreate = clock();
    for (size_t i = 0; i < N; i++)
        data[i] = ((double)rand() / RAND_MAX) * 200.0 - 100.0;
    clock_t endCreate = clock();

    clock_t startAverage = clock();
    double avg = average(data, N);
    clock_t endAverage = clock();

    clock_t endTotal = clock();

    double createTime = (double)(endCreate - startCreate) / CLOCKS_PER_SEC;
    double averageTime = (double)(endAverage - startAverage) / CLOCKS_PER_SEC;
    double totalTime = (double)(endTotal - startCreate) / CLOCKS_PER_SEC;

    printf("average = %f\n", avg);
    printf("Data creation: %.6f seconds\n", createTime);
    printf("Averaging:     %.6f seconds\n", averageTime);
    printf("Total:         %.6f seconds\n", totalTime);

    free(data);
    return 0;
}
