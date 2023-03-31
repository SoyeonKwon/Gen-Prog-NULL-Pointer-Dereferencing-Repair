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
  i = 0;
  while (i < ARR_SIZE) {
    *(nums + i) = i + 1;
    *(ptr + i) = nums + i;
    i ++;
  }
  printf("i___0 = %d\n", i___0);
  printf("NUM_NEGTESTS = %d\n", NUM_NEGTESTS);
  printf("%d\n", i___0 < NUM_NEGTESTS);
  while (i___0 < NUM_NEGTESTS) {
    printf("The second while loop, %d\n", i___0);
    *(ptr + null_indices[i___0]) = (int *)0;
    i___0 ++;
  }
  printf("%d\n", *(*(ptr + arg_index)));
  return (0);
}
}
