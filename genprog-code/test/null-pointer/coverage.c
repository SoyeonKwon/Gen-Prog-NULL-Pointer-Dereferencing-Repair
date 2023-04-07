struct _IO_FILE ; extern int fclose(struct _IO_FILE *__stream ) ;
extern  __attribute__((__nothrow__)) void *( __attribute__((__nonnull__(1),
__leaf__)) memset)(void *__s , int __c , unsigned long __n ) ;
struct _IO_FILE ;
extern int fprintf(struct _IO_FILE * __restrict  __stream ,
                   char const   * __restrict  __format  , ...) ;
extern struct _IO_FILE *fopen(char const   * __restrict  __filename ,
                              char const   * __restrict  __modes )  __attribute__((__malloc__(fclose,1),
__malloc__)) ;
extern int fflush(struct _IO_FILE *__stream ) ;
extern int fclose(struct _IO_FILE *__stream ) ;
struct _IO_FILE *_coverage_fout  ;
extern int ( /* missing proto */  atoi)() ;
extern int ( /* missing proto */  printf)() ;
int main(int argc , char **argv ) 
{ 
  int ARR_SIZE ;
  int arg_index ;
  int tmp ;
  int NUM_NEGTESTS ;
  int null_indices[3] ;
  int **ptr ;
  unsigned long __lengthofptr ;
  void *tmp___0 ;
  int *nums ;
  unsigned long __lengthofnums ;
  void *tmp___1 ;
  int i ;
  int i___0 ;

  {
  {
  if (_coverage_fout == 0) {
    {
    _coverage_fout = fopen("/home/soyeon/Gen-Prog-NULL-Pointer-Dereferencing-Repair/genprog-code/test/null-pointer/./coverage.path",
                           "wb");
    }
  }
  }
  {
  fprintf(_coverage_fout, "1\n");
  fflush(_coverage_fout);
  }
  ARR_SIZE = 10;
  {
  fprintf(_coverage_fout, "2\n");
  fflush(_coverage_fout);
  }
  tmp = atoi(*(argv + 1));
  {
  fprintf(_coverage_fout, "3\n");
  fflush(_coverage_fout);
  }
  arg_index = tmp;
  {
  fprintf(_coverage_fout, "4\n");
  fflush(_coverage_fout);
  }
  NUM_NEGTESTS = 3;
  {
  fprintf(_coverage_fout, "5\n");
  fflush(_coverage_fout);
  }
  null_indices[0] = 3;
  {
  fprintf(_coverage_fout, "6\n");
  fflush(_coverage_fout);
  }
  null_indices[1] = 6;
  {
  fprintf(_coverage_fout, "7\n");
  fflush(_coverage_fout);
  }
  null_indices[2] = 9;
  {
  fprintf(_coverage_fout, "8\n");
  fflush(_coverage_fout);
  }
  __lengthofptr = (unsigned long )ARR_SIZE;
  {
  fprintf(_coverage_fout, "9\n");
  fflush(_coverage_fout);
  }
  tmp___0 = __builtin_alloca(sizeof(*ptr) * __lengthofptr);
  {
  fprintf(_coverage_fout, "10\n");
  fflush(_coverage_fout);
  }
  ptr = (int **)tmp___0;
  {
  fprintf(_coverage_fout, "11\n");
  fflush(_coverage_fout);
  }
  __lengthofnums = (unsigned long )ARR_SIZE;
  {
  fprintf(_coverage_fout, "12\n");
  fflush(_coverage_fout);
  }
  tmp___1 = __builtin_alloca(sizeof(*nums) * __lengthofnums);
  {
  fprintf(_coverage_fout, "13\n");
  fflush(_coverage_fout);
  }
  nums = (int *)tmp___1;
  {
  fprintf(_coverage_fout, "14\n");
  fflush(_coverage_fout);
  }
  i = 0;
  {
  fprintf(_coverage_fout, "15\n");
  fflush(_coverage_fout);
  }
  while (1) {
    {
    fprintf(_coverage_fout, "16\n");
    fflush(_coverage_fout);
    }
    if (i < ARR_SIZE) {
      {
      fprintf(_coverage_fout, "17\n");
      fflush(_coverage_fout);
      }

    } else {
      break;
    }
    {
    fprintf(_coverage_fout, "19\n");
    fflush(_coverage_fout);
    }
    *(nums + i) = i + 1;
    {
    fprintf(_coverage_fout, "20\n");
    fflush(_coverage_fout);
    }
    *(ptr + i) = nums + i;
    {
    fprintf(_coverage_fout, "21\n");
    fflush(_coverage_fout);
    }
    i ++;
  }
  {
  fprintf(_coverage_fout, "22\n");
  fflush(_coverage_fout);
  }
  i___0 = 0;
  {
  fprintf(_coverage_fout, "23\n");
  fflush(_coverage_fout);
  }
  while (1) {
    {
    fprintf(_coverage_fout, "24\n");
    fflush(_coverage_fout);
    }
    if (i___0 < NUM_NEGTESTS) {
      {
      fprintf(_coverage_fout, "25\n");
      fflush(_coverage_fout);
      }

    } else {
      break;
    }
    {
    fprintf(_coverage_fout, "27\n");
    fflush(_coverage_fout);
    }
    *(ptr + null_indices[i___0]) = (int *)0;
    {
    fprintf(_coverage_fout, "28\n");
    fflush(_coverage_fout);
    }
    i___0 ++;
  }
  {
  fprintf(_coverage_fout, "29\n");
  fflush(_coverage_fout);
  }
  printf("%d\n", *(*(ptr + arg_index)));
  {
  fprintf(_coverage_fout, "30\n");
  fflush(_coverage_fout);
  }
  return (0);
}
}
