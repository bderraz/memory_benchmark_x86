#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N (1<<20)
#define SCALE_FACTOR 2.0

void copy(double *a, double *b, int n) {
  int i;
  for (i = 0; i < n; i++) {
    b[i] = a[i];
  }
}

void scale(double *a, double *b, double q, int n) {
  int i;
  for (i = 0; i < n; i++) {
    b[i] = q*a[i];
  }
}

void add(double *a, double *b, double *c, int n) {
  int i;
  for (i = 0; i < n; i++) {
    a[i] = b[i] + c[i];
  }
}

void triad(double *a, double *b, double *c, double q, int n) {
  int i;
  for (i = 0; i < n; i++) {
    a[i] = b[i] + q*c[i];
  }
}

int main() {
  double *a, *b, *c;
  double t_copy, t_scale, t_add, t_triad;
  int i;

  a = (double*)malloc(N*sizeof(double));
  b = (double*)malloc(N*sizeof(double));
  c = (double*)malloc(N*sizeof(double));

  for (i = 0; i < N; i++) {
    b[i] = (double)i;
    c[i] = (double)i;
  }

  t_copy = clock();
  copy(b, a, N);
  t_copy = (clock() - t_copy); // b = a / b

  printf("copy time: %d\n", t_copy);

  t_scale = clock();
  scale(b, a, SCALE_FACTOR, N);
  t_scale = (clock() - t_scale);

  printf("scale time: %d\n", t_scale);

  t_add = clock();
  add(a, b, c, N);
  t_add = (clock() - t_add);

  printf("add time: %d\n", t_add);

  t_triad = clock();
  triad(a, b, c, SCALE_FACTOR, N);
  t_triad = (clock() - t_triad);

  printf("triad time: %d\n", t_triad);

  free(a);
  free(b);
  free(c);

  return 0;
}
