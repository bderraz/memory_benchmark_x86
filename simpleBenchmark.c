#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N (1<<20)

void copy(double *a, double *b, int n) {
  int i;
  for (i = 0; i < n; i++) {
    b[i] = a[i];
  }
}

int main() {
  double *a, *b;
  double t;
  int i;

  a = (double*)malloc(N*sizeof(double));
  b = (double*)malloc(N*sizeof(double));

  for (i = 0; i < N; i++) {
    a[i] = (double)i;
  }

  t = clock();
  copy(a, b, N);
  t = (clock() - t)/CLOCKS_PER_SEC;

  printf("copy time: %f\n", t);

  free(a);
  free(b);

  return 0;
}