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
extern int ( /* missing proto */  gcd)() ;
extern int ( /* missing proto */  atoi)() ;
int main(int argc , char **argv ) 
{ 
  int tmp ;
  int tmp___0 ;
  int tmp___1 ;

  {
  {
  if (_coverage_fout == 0) {
    {
    _coverage_fout = fopen("/home/soyeon/genprog-code-new/genprog-code/test/gcd-multi-test/coverage/coverage.path",
                           "wb");
    }
  }
  }
  {
  fprintf(_coverage_fout, "1\n");
  fflush(_coverage_fout);
  }
  tmp = atoi(*(argv + 2));
  {
  fprintf(_coverage_fout, "2\n");
  fflush(_coverage_fout);
  }
  tmp___0 = atoi(*(argv + 1));
  {
  fprintf(_coverage_fout, "3\n");
  fflush(_coverage_fout);
  }
  tmp___1 = gcd(tmp___0, tmp);
  {
  fprintf(_coverage_fout, "4\n");
  fflush(_coverage_fout);
  }
  return (tmp___1);
}
}
