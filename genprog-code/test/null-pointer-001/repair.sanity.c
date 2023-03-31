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
  int negIndex ;
  int i ;
  int j ;

  {
  ARR_SIZE = 10;
  tmp = atoi(*(argv + 1));
  arg_index = tmp;
  NUM_NEGTESTS = 3;
  null_indices[0] = 3;
  null_indices[1] = 6;
  null_indices[2] = 9;
  __lengthofptr = (unsigned long )ARR_SIZE;
  tmp___0 = __builtin_alloca(sizeof(*ptr) * __lengthofptr);
  ptr = (int **)tmp___0;
  __lengthofnums = (unsigned long )ARR_SIZE;
  tmp___1 = __builtin_alloca(sizeof(*nums) * __lengthofnums);
  nums = (int *)tmp___1;
  negIndex = 0;
  i = 0;
  while (i < ARR_SIZE) {
    *(nums + i) = i + 1;
    j = 0;
    while (j < NUM_NEGTESTS) {
      if (i == null_indices[j]) {
        negIndex = 1;
      } else {

      }
      j ++;
    }
    if (negIndex == 1) {
      *(ptr + i) = (int *)((void *)0);
      *(ptr + i) = (int *)1;
    } else {
      *(ptr + i) = nums + i;
    }
    negIndex = 0;
    i ++;
  }
  printf("%d\n", *(*(ptr + arg_index)));
  return (0);
}
}
