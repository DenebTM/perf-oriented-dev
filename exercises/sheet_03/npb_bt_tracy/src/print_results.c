#include <math.h>
#include <stdio.h>
#ifdef _OPENMP
#include <omp.h>
#endif

void print_results(const char *name, char cls, int n1, int n2, int n3,
                   int niter, double t, double mops, const char *optype,
                   bool verified, const char *npbversion,
                   const char *compiletime, const char *cs1, const char *cs2,
                   const char *cs3, const char *cs4, const char *cs5,
                   const char *cs6, const char *cs7) {
  char size[16];
  int j;
  int num_threads, max_threads;

  max_threads = 1;
  num_threads = 1;

  // figure out number of threads used
#ifdef _OPENMP
  max_threads = omp_get_max_threads();
#pragma omp parallel shared(num_threads)
  {
#pragma omp master
    num_threads = omp_get_num_threads();
  }
#endif

  printf("\n\n %s Benchmark Completed.\n", name);
  printf(" Class           =             %12c\n", cls);

  // If this is not a grid-based problem (EP, FT, CG), then
  // we only print n1, which contains some measure of the
  // problem size. In that case, n2 and n3 are both zero.
  // Otherwise, we print the grid size n1xn2xn3

  if ((n2 == 0) && (n3 == 0)) {
    if ((name[0] == 'E') && (name[1] == 'P')) {
      sprintf(size, "%15.0lf", pow(2.0, n1));
      j = 14;
      if (size[j] == '.') {
        size[j] = ' ';
        j--;
      }
      size[j + 1] = '\0';
      printf(" Size            =          %15s\n", size);
    } else {
      printf(" Size            =             %12d\n", n1);
    }
  } else {
    printf(" Size            =           %4dx%4dx%4d\n", n1, n2, n3);
  }

  printf(" Iterations      =             %12d\n", niter);
  // printf( " Time in seconds =             %12.2lf\n", t );

  printf(" Total threads   =             %12d\n", num_threads);
  printf(" Avail threads   =             %12d\n", max_threads);
  if (num_threads != max_threads)
    printf(" Warning: Threads used differ from threads available\n");

  // printf( " Mop/s total     =          %15.2lf\n", mops );
  // printf( " Mop/s/thread    =          %15.2lf\n", mops/(double)num_threads
  // );

  printf(" Operation type  = %24s\n", optype);
  if (verified)
    printf(" Verification    =             %12s\n", "SUCCESSFUL");
  else
    printf(" Verification    =             %12s\n", "UNSUCCESSFUL");
  printf(" Version         =             %12s\n", npbversion);
  printf(" Compile date    =             %12s\n", compiletime);

  printf("\n Compile options:\n"
         "    CC           = %s\n",
         cs1);
  printf("    CLINK        = %s\n", cs2);
  printf("    C_LIB        = %s\n", cs3);
  printf("    C_INC        = %s\n", cs4);
  printf("    CFLAGS       = %s\n", cs5);
  printf("    CLINKFLAGS   = %s\n", cs6);
  printf("    RAND         = %s\n", cs7);

  printf("\n--------------------------------------\n"
         " Please send all errors/feedbacks to:\n"
         " Center for Manycore Programming\n"
         " cmp@aces.snu.ac.kr\n"
         " http://aces.snu.ac.kr\n"
         "--------------------------------------\n\n");
}
